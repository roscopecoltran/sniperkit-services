import aiopg.sa
import aiohttp_security
import aiohttp_admin
from aiohttp_admin.layout_utils import generate_config
from aiohttp_admin.backends.sa import PGResource
from aiohttp_admin.security import DummyAuthPolicy, DummyTokenIdentityPolicy


from api.db import song, artist


__all__ = ('init_admin', )


async def init_admin(app, loop):
    admin = await get_admin_subapp(app, loop)
    app.add_subapp('/admin', admin)


async def get_admin_subapp(app, loop):
    pg = await init_admin_engine(loop, app['conf']['postgres'])

    async def close_pg(app):
        pg.close()
        await pg.wait_closed()

    app.on_cleanup.append(close_pg)


    admin_config_path = str(aiohttp_admin.PROJ_ROOT / 'static' / 'js')
    admin = setup_admin(app, pg, admin_config_path)
    return admin

async def init_admin_engine(loop, db_conf):
    engine = await aiopg.sa.create_engine(
        loop=loop,
        database=db_conf.get('database'),
        user=db_conf.get('user'),
        password=db_conf.get('password'),
        host=db_conf.get('host'),
    )
    return engine


def setup_admin(app, pg, admin_config_path):
    resources = (PGResource(pg, artist, url='artist'),
                 PGResource(pg, song, url='song'))
    admin = aiohttp_admin.setup(app, admin_config_path, resources=resources)

    # setup dummy auth and identity
    ident_policy = DummyTokenIdentityPolicy()
    auth_policy = DummyAuthPolicy(username="admin", password="admin")
    aiohttp_security.setup(admin, ident_policy, auth_policy)
    return admin


def generate_ng_admin_config():
    print('Generate admin config')
    base_url = '/admin'

    entities = [
        ('artist', 'id', artist),
        ('song', 'id', song),
    ]

    config_str = generate_config(entities, base_url)
    config_path = str(aiohttp_admin.PROJ_ROOT / 'static' / 'js' / 'new_ng_config.js')
    print('New config saved at {}'.format(config_path))

    with open(config_path, 'w') as file:
        file.write(config_str)
    print('Configuration successfully created, exiting ')
