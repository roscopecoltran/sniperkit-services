import asyncio
import logging
import aiohttp
from aiohttp import web
from auth.utils import login_required
import aiodocker
from aiodocker.docker import Docker
from aiodocker.exceptions import DockerError

log = logging.getLogger(__name__)

@login_required
async def websocket_handler(request, user_id):

    ws = web.WebSocketResponse()
    await ws.prepare(request)
    request.app['websockets'][user_id].add(ws)
    task = request.app.loop.create_task(
        listen_to_docker(ws))

    try:
        async for msg in ws:
            # handle incoming messages
            if msg.type == aiohttp.WSMsgType.close:
                log.debug('websocket connection closed')
                await ws.close()
                break
            elif msg.type == aiohttp.WSMsgType.error:
                log.debug('ws connection closed with exception %s' % ws.exception())
                break
            elif msg.type == aiohttp.WSMsgType.text:
                log.debug(msg)
                await ws.send_str('ECHO')
            else:
                print('ws connection received unknown message type %s' % msg.type)

    except asyncio.CancelledError:
        log.debug('websocket cancelled')
    finally:
        request.app['websockets'][user_id].remove(ws)
    await ws.close()
    return ws


docker = Docker()
subscriber = docker.events.subscribe()

async def listen_to_docker(ws):
    log.debug("Running Listening Docker")
    try:
        while True:
            event = await subscriber.get()
            log.debug(event)
            # Forward message to all connected websockets:
            if event['Type'] == 'container':
                log.debug(ws)
                await ws.send_str('Message from docker')
                log.debug("Message sent")
    except asyncio.CancelledError:
        pass
    finally:
        await docker.close()
    log.debug("Outside the loop!")