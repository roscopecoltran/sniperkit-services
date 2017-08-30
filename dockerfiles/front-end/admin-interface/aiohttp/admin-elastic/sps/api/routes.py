from .views import SongsApiView, ArtistsApiView, search_api_view


def setup_routes(app, prefix=None):
    SongsApiView.add_routes(app, prefix)
    ArtistsApiView.add_routes(app, prefix)
    app.router.add_get('/' + prefix + '/search', search_api_view, name='api-search')
