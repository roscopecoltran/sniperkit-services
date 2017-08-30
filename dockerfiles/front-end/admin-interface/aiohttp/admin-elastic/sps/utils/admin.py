import json
import aiopg.sa
import aiohttp_security
import aiohttp_admin
from aiohttp_admin.layout_utils import generate_config
from aiohttp_admin.backends.sa import PGResource
from aiohttp_admin.security import DummyAuthPolicy, DummyTokenIdentityPolicy


from api.db import song, artist
from parties.db import party
from utils.elastic import update_song_by_artist, update_song_by_id


__all__ = ('init_admin', )


async def init_admin(app, loop):
    admin = await get_admin_subapp(app, loop)
    app.add_subapp('/admin', admin)


async def get_admin_subapp(app, loop):
    pg = await init_admin_engine(loop, app['conf']['postgres'])
    es = app['elastic']

    async def close_pg(app):
        pg.close()
        await pg.wait_closed()

    app.on_cleanup.append(close_pg)

    admin_config_path = str(aiohttp_admin.PROJ_ROOT / 'static' / 'js')
    admin = setup_admin(app, pg, es, admin_config_path)
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


class ElasticResource(PGResource):
    def __init__(self, db, es, table, primary_key='id', url=None):
        self._es = es
        super().__init__(db, table, primary_key, url)

    async def update(self, request):
        response = await super().update(request)
        await self.index_elastic(response)
        return response

    async def create(self, request):
        response = await super().create(request)
        await self.index_elastic(response)
        return response


class SongResource(ElasticResource):
    async def index_elastic(self, response):
        await update_song_by_id(
            pg=self._db, es=self._es,
            id=json.loads(response.body)['id']
        )


class ArtistResource(ElasticResource):
    async def index_elastic(self, response):
        await update_song_by_artist(
            pg=self._db, es=self._es,
            artist_id=json.loads(response.body)['id']
        )


def setup_admin(app, pg, es, admin_config_path):
    resources = (ArtistResource(pg, es, artist, url='artist'),
                 SongResource(pg, es, song, url='song'),
                 PGResource(pg, party, url='party', primary_key='password'))
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
        ('party', 'password', party)
    ]

    config_str = generate_config(entities, base_url)
    config_path = str(aiohttp_admin.PROJ_ROOT / 'static/js/new_ng_config.js')
    print('New config saved at {}'.format(config_path))

    with open(config_path, 'w') as file:
        file.write(config_str)
    print('Configuration successfully created, exiting ')
