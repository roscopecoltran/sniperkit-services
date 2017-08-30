from datetime import datetime
from hashlib import md5
import sqlalchemy as sa
from sqlalchemy.schema import CreateTable
import asyncpg


meta = sa.MetaData()

#     password = wlr.TextField(primary_key=True)
#     master_token = wlr.TextField(index=True)
#     user_token = wlr.TextField(index=True)
#     expire_time = wlr.DateTimeField()

#     current_song = wlr.IntegerField(default=0)  # 0 means no song
#     proposed_songs = wlr.SetField()
#     connected_users = wlr.SetField()


party = sa.Table(
    'party', meta,
    # Max length of password is 16 symbols
    sa.Column('password', sa.String(16), primary_key=True),
    sa.Column('master_token', sa.String(32)),
    sa.Column('user_token', sa.String(32)),
)



async def create_tables_sql(app):
    async with app['pool'].acquire() as conn:
        try:
            await conn.execute(CreateTable(party))
        except asyncpg.exceptions.DuplicateTableError:
            pass


async def get_party_by_password(pool, password):
    query = party.select().where(party.c.password == password)

    async with pool.transaction() as conn:
        party_row = await conn.fetchrow(query)

    if not party_row:
        return None
    else:
        return {
            'user_token': party_row.user_token,
            'master_token': party_row.master_token,
        }


async def create_party_by_password(pool, password):
    creation_time = datetime.now()
    party_hash = md5(str(creation_time).encode('utf-8')).hexdigest()
    master_token = party_hash[::2]
    user_token = party_hash[1::2]

    query = party.insert().values(
        password=password,
        master_token=master_token,
        user_token=user_token,
    )

    async with pool.transaction() as conn:
        await conn.fetchrow(query)

    return {
        'user_token': user_token,
        'master_token': master_token,
    }


async def get_party_by_token(pool, token):
    query = party.select().where(party.c.user_token == token)

    async with pool.transaction() as conn:
        party_row = await conn.fetchrow(query)

    if party_row:
        return {
            'password': party_row.password,
            'master': False
        }

    query = party.select().where(party.c.master_token == token)

    async with pool.transaction() as conn:
        party_row = await conn.fetchrow(query)

    if party_row:
        return {
            'password': party_row.password,
            'master': True
        }

    return None