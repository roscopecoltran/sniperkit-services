from api.db import song, artist
from sqlalchemy import select


async def update_all_indexes(es, pg):

    songs = []
    query = song.select()

    async with pg.transaction() as conn:
        results = await conn.fetch(query)

    for row in results:
        songs.append({
            'artist': row.artist_id,
            'title': row.title,
            'id': row.id,
            # Should be uncommented after text search realisation
            # 'text': row.text,
        })

    all_artists = dict()
    async with pg.transaction() as conn:
        for row in await conn.fetch(artist.select()):
            all_artists[row.id] = row.name

    for s in songs:

        await es.index(
            index='library',
            doc_type='song',
            body={
                'title': s['title'].lower(),
                'artist': all_artists[s['artist']].lower(),
            },
            id=s['id']
        )


async def update_song_by_id(pg, es, id):
    query = song.join(artist, song.c.artist_id == artist.c.id)
    query = select([
        song.c.id,
        song.c.title,
        artist.c.name
    ]).where(song.c.id == id).select_from(query)

    async with pg.acquire() as conn:
        song_row = await conn.execute(query)
        song_row = await song_row.fetchone()
    await es.index(
        index='library',
        doc_type='song',
        body={
            'title': song_row[song.c.title].lower(),
            'artist': song_row[artist.c.name].lower(),
        },
        id=song_row[song.c.id]
    )


async def update_song_by_artist(pg, es, artist_id):
    query = song.join(artist, song.c.artist_id == artist.c.id)
    query = select([
        song.c.id,
        song.c.title,
        artist.c.name
    ]).where(song.c.artist_id == artist_id).select_from(query)

    async with pg.acquire() as conn:
        song_rows = await conn.execute(query)

    for song_row in await song_rows.fetchall():
        await es.index(
            index='library',
            doc_type='song',
            body={
                'title': song_row[song.c.title].lower(),
                'artist': song_row[artist.c.name].lower(),
            },
            id=song_row[song.c.id]
        )
