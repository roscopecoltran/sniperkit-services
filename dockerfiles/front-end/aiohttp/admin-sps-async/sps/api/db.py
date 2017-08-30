import sqlalchemy as sa
from sqlalchemy.schema import CreateTable
import asyncpg


meta = sa.MetaData()

artist = sa.Table(
    'artist', meta,
    sa.Column('id', sa.Integer, primary_key=True, autoincrement=True),
    sa.Column('name', sa.String(200), nullable=False),

)

song = sa.Table(
    'song', meta,
    sa.Column('id', sa.Integer, primary_key=True, autoincrement=True),
    sa.Column('artist_id', sa.ForeignKey('artist.id'), nullable=False),
    sa.Column('title', sa.String(200), nullable=False),
    sa.Column('text', sa.Text(), nullable=False),

)


async def create_tables_sql(app):
    for name, table in meta.tables.items():
        async with app['pool'].acquire() as conn:
            try:
                await conn.execute(CreateTable(table))
            except asyncpg.exceptions.DuplicateTableError:
                pass


async def get_songs(pool, artist_id=None, artists_to_text=None, notext=None):

    query = song.select()


    if artist_id:
        query = query.where(song.c.artist_id == artist_id)

    results = []
    async with pool.acquire() as conn:
        for row in await conn.fetch(query):
            results.append({
                'artist': row.artist_id,
                'title': row.title,
                'id': row.id,
                'text': row.id,
            })

    if artists_to_text is True:
        all_artists = dict()
        async with pool.transaction() as conn:
            for row in await conn.fetch(artist.select()):
                all_artists[row.id] = row.name

        for result in results:
            result['artist'] = all_artists[result['artist']]

    if notext is True:
        for result in results:
            result.pop('text')

    return results

async def get_single_song(pool, song_id, artist_to_text=None):
    query = song.select().where(song.c.id == song_id)
    result_song = dict()
    async with pool.transaction() as conn:
        song_row = await conn.fetchrow(query)

    if not song_row:
        return None

    result_song.update({
        'artist': song_row.artist_id,
        'title': song_row.title,
        'id': song_row.id,
        'text': song_row.text
    })
    if result_song == {}:
        return None

    if artist_to_text:
        artist_query = artist.select().where(artist.c.id == result_song['artist'])
        async with pool.transaction() as conn:
            artist_row = await conn.fetchrow(artist_query)

        result_song['artist'] = artist_row.name
    return result_song


async def get_artists(pool):
    query = artist.select()

    async with pool.transaction() as conn:
        results = await conn.fetch(query)

    return [{'id': row.id,
             'name': row.name,
             } for row in results]

async def get_single_artist(pool, artist_id, select_songs=None, full_songs=None):
    query = artist.select().where(artist.c.id == artist_id)
    async with pool.transaction() as conn:
        row = await conn.fetchrow(query)

    if not row:
        return None

    result_artist = {
        'id': row.id,
        'name': row.name
    }

    if select_songs is True:
        songs = []
        songs_query = song.select().where(song.c.artist_id == artist_id)
        async with pool.transaction() as conn:
            results = await conn.fetch(songs_query)

        for row in results:
            if full_songs is True:
                songs.append({
                    'id': row.id,
                    'title': row.title,
                    'text': row.text,
                })
            else:
                songs.append(row.id)
        result_artist['songs'] = songs

    return result_artist
