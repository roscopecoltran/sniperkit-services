import os
import asyncio
from aiohttp import web

import api
import parties
import utils.middlewares
import utils.admin
import utils.jinja
import utils.connections
import utils.elastic


async def init_application(loop):

    middlewares = [
        # List of middlewares is here
        utils.middlewares.cors_headers_middleware,
        utils.middlewares.trailing_slash_redirect_middleware,
        # elastic_index_middleware,
    ]
    app = web.Application(loop=loop, middlewares=middlewares)

    await utils.connections.init_postgres(app, loop)
    await utils.connections.init_redis(app, loop)
    await utils.connections.init_elasticsearch(app, loop)

    await utils.elastic.update_all_indexes(app['elastic'], app['pool'])

    # SECTION: sub-apps
    app['apps'] = {}  # dictionary for apps to store any info at
    # Registering apps
    api.register_in_app(app, prefix='api')
    parties.register_in_app(app, prefix='party')

    utils.jinja.setup_jinja2(app, __file__)

    # Admin should be inited only after all sub-apps are connected

    await utils.admin.init_admin(app, loop)
    return app


def main():
    loop = asyncio.get_event_loop()

    app = loop.run_until_complete(init_application(loop))
    web.run_app(app,
                host=os.getenv('SERVER_HOST', '127.0.0.1'),
                port=int(os.getenv('SERVER_PORT', 4000)))


if __name__ == '__main__':
    main()
