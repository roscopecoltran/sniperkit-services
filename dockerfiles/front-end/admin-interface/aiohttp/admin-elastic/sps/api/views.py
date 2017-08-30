import json
import math
from aiohttp import web

from . import db
from . import elastic


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
        app.router.add_get(base_url + '/{id}', SongsApiView.retrieve, name='songs_retrieve')

    @staticmethod
    async def list(request):
        artist = request.query.get('artist', '')

        if artist.isdigit():
            artist_id = int(artist)
            artist_to_text = False
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
        base_url = ArtistsApiView.base_url
        if prefix:
            base_url = '/' + prefix + base_url

        app.router.add_get(base_url, ArtistsApiView.list, name='artists_list')
        app.router.add_get(base_url + '/{id}', ArtistsApiView.retrieve, name='artists_retrieve')

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


async def search_api_view(request):
    es = request.app['elastic']

    query = request.query.get('q', '')

    result_ids = []
    by_param = request.query.get('by', '').strip()

    if by_param == 'artist':
        result_ids.extend(await elastic.get_by_artist(es, query))
    if by_param == 'title':
        result_ids.extend(await elastic.get_by_title(es, query))
    else:
        result_ids.extend(await elastic.get_by_title(es, query))
        result_ids.extend(await elastic.get_by_artist(es, query))

    if result_ids:
        flattened = {}
        for res in result_ids:
            r_value = flattened.get(res[0], 0)
            flattened[res[0]] = r_value + res[1]

        result_ids = list(flattened.items())

        result_ids.sort(key=lambda item: item[1])
        result_ids = [int(res[0]) for res in result_ids]
        results = await db.get_songs_by_ids(request.app['pool'], result_ids)
    else:
        results = []

    page_param = request.query.get('page')
    if page_param and page_param.isdigit() and int(page_param) > 0:
        page = int(page_param)
    else:
        page = 1

    max_pages = int(math.ceil(len(results) / 10)) or 1
    if (max_pages < 2 and page != 1) or page > max_pages:
        return web.HTTPNotFound()

    response_json = {
        "results": results[10 * (page - 1):10 * page],
        "total_items": len(results),
        "pages": {
            'current': page,
            'max': max_pages
        }

    }

    return web.json_response(response_json, dumps=own_dumps)
