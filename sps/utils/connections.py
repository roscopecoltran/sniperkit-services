"""
Here connections to databases (SQL and NoSQL) are created
Functions defined here should take care of:
 * configuring connection
 * creating connection
 * gracefully closing connections
"""
import os
import aioredis
import asyncpgsa
from aioes import Elasticsearch


async def init_redis(app, loop):
    # Configuring
    conf = (
        'redis',  # Host
        6379      # Port
    )

    # Creating pool
    redis = await aioredis.create_redis(conf, loop=loop)
    app['redis'] = redis

    # Grateful shutdown
    async def close_redis():
        redis.close()
    app.on_cleanup.append(close_redis)


async def init_postgres(app, loop):
    # Configuring
    conf = {
        'user': os.getenv('POSTGRES_USER'),
        'password': os.getenv('POSTGRES_PASSWORD'),
        'port': os.getenv('POSTGRES_PORT', 5432),
        'database': os.getenv('POSTGRES_DB'),
        'host': 'postgres',  # Hardcoded as docker-linked service
    }

    # Creating pool
    app['pool'] = await asyncpgsa.create_pool(**conf, loop=loop)

    # Saving config for aiohttp_admin
    app['conf'] = app.get('conf', {})
    app['conf'].update({
        'postgres': conf
    })

    # Grateful shutdown
    app.on_cleanup.append(app['pool'].close)


async def init_elasticsearch(app, loop):
    # Creating pool
    app['elastic'] = Elasticsearch(['elastic:9200'], loop=loop)
