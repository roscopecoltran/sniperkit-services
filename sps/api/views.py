import json
from aiohttp import web

from . import db


def own_dumps(*args, **kwargs):
    kwargs['ensure_ascii'] = False
    return json.dumps(*args, **kwargs)


class SongsApiView:

    base_url = '/songs'

    @staticmethod
    def add_routes(app, prefix=None):
        base_url = SongsApiView.base_url
        if prefix:
            base_url = '/' + prefix + base_url

        app.router.add_get(base_url, SongsApiView.list, name='songs_list')
        app.router.add_get(base_url +'/{id}', SongsApiView.retrieve, name='songs_retrieve')

    @staticmethod
    async def list(request):
        artist = request.query.get('artist', '')

        if artist.isdigit():
            artist_id = int(artist)
            artist_to_text=False
        elif artist == 'name':
            artist_id = None
            artist_to_text = True
        else:
            artist_id = None
            artist_to_text = False

        notext = True if 'exclude' == request.query.get('text') else None
        songs = await db.get_songs(request.app['pool'],
                                   artist_id=artist_id,
                                   artists_to_text=artist_to_text,
                                   notext=notext)
        return web.json_response(songs, dumps=own_dumps)

    @staticmethod
    async def retrieve(request):
        song_id = request.match_info['id']
        if song_id.isdigit():
            song_id = int(song_id)
        else:
            return web.HTTPNotFound()

        artist_to_text = True if 'name' == request.query.get('artist') else None
        result = await db.get_single_song(request.app['pool'], song_id, artist_to_text)
        if result is None:
            return web.HTTPNotFound()
        else:
            if request.query.get('text') == 'exclude':
                result.pop('text')
            return web.json_response(result, dumps=own_dumps)


class ArtistsApiView:

    base_url = '/artists'

    @staticmethod
    def add_routes(app, prefix=None):
        base_url = SongsApiView.base_url
        if prefix:
            base_url = '/' + prefix + base_url

        app.router.add_get(base_url, ArtistsApiView.list, name='artists_list')
        app.router.add_get(base_url +'/{id}', ArtistsApiView.retrieve, name='artists_retrieve')

    @staticmethod
    async def list(request):
        artists = await db.get_artists(request.app['pool'])
        return web.json_response(artists, dumps=own_dumps)

    @staticmethod
    async def retrieve(request):
        artist_id = request.match_info['id']
        if artist_id.isdigit():
            artist_id = int(artist_id)
        else:
            return web.HTTPNotFound()

        songs = request.rel_url.query.get('songs', None)
        if songs == 'full':
            artist = await db.get_single_artist(
                request.app['pool'], artist_id, select_songs=True, full_songs=True
            )
        elif songs == 'true':
            artist = await db.get_single_artist(
                request.app['pool'], artist_id, select_songs=True
            )
        else:
            artist = await db.get_single_artist(request.app['pool'], artist_id)

        if artist is None:
            return web.HTTPNotFound()
        else:
            return web.json_response(artist, dumps=own_dumps)
