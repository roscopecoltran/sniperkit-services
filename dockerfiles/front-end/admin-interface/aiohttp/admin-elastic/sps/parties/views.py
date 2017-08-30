import json
from datetime import datetime
from aiohttp import web


from . import db


DATETIME_FORMAT = "%Y-%m-%dT%H-%M-%S"


def own_dumps(*args, **kwargs):
    kwargs['ensure_ascii'] = False
    return json.dumps(*args, **kwargs)


async def create_party(request):
    # At every creation - clean expired
    await db.clean_expired(request.app['redis'], request.app['pool'])

    tokens = await db.get_party_by_password(
        pool=request.app['pool'], password=request.match_info['password']
    )
    if tokens is not None:
        return web.json_response({'token': ''}, dumps=own_dumps)

    tokens = await db.create_party_by_password(
        pool=request.app['pool'], password=request.match_info['password']
    )
    request.app['apps']['parties'].update({
        request.match_info['password']: []
    })

    redis = request.app['redis']
    party_key = 'party:{}'.format(request.match_info['password'])

    await redis.set(party_key + ':updated', datetime.now().strftime(DATETIME_FORMAT))
    await redis.set(party_key + ':current', 0)
    await redis.delete(party_key + ':proposed', 0)

    return web.json_response(
        {'token': tokens['master_token']},
        dumps=own_dumps
    )


async def register_in_party(request):
    tokens = await db.get_party_by_password(
        pool=request.app['pool'], password=request.match_info['password']
    )
    if tokens is None:
        return web.json_response({'token': ''}, dumps=own_dumps)

    return web.json_response(
        {'token': tokens['user_token']},
        dumps=own_dumps
    )


async def websocket_handler(request):
    ws = web.WebSocketResponse(autoclose=False)
    await ws.prepare(request)

    token_info = await db.get_party_by_token(
        request.app['pool'], token=request.match_info['token']
    )

    if token_info is None:
        await ws.close()
        return ws

    redis = request.app['redis']
    party_key = 'party:{}'.format(token_info['password'])

    party_waiters = request.app['apps']['parties'][token_info['password']]
    party_waiters.append(ws)

    init_data = {
        'master': token_info['master'],
        'current': int(await redis.get(party_key + ':current')),
        'proposed': [int(id) for id in
                     await redis.smembers(party_key + ':proposed')],
    }
    ws.send_str(json.dumps(init_data))

    try:
        async for msg in ws:
            await redis.set(party_key + ':updated', datetime.now().strftime(DATETIME_FORMAT))

            if msg.tp == web.MsgType.text:
                data = json.loads(msg.data)

                if not token_info['master']:
                    await redis.sadd(party_key + ':proposed', data['song'])
                    for waiter in party_waiters:
                        waiter.send_str(json.dumps({
                            'action': 'propose',
                            'song': data['song'],
                        }))
                elif 'action' in data:
                    if data['action'] == 'ignore' or data['action'] == 'choose':
                        resp_json = ({
                            'action': data['action'],
                            'song': data['song']
                        })
                        await redis.srem(party_key + ':proposed', data['song'])

                        if data['action'] == 'choose':
                            await redis.set(party_key + ':current', data['song'])

                        for waiter in party_waiters:
                            waiter.send_str(json.dumps(resp_json))
                    elif data['action'] == 'delete':
                        for waiter in party_waiters:
                            await waiter.close()

            elif msg.tp == web.MsgType.error:
                print('connection closed with exception {}'.format(ws.exception()))
    finally:
        if ws in party_waiters:
            await ws.close()
            party_waiters.remove(ws)

    return ws
