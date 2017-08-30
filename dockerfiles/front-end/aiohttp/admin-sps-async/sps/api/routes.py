from .views import *


def setup_routes(app, prefix=None):
    SongsApiView.add_routes(app, prefix)
    ArtistsApiView.add_routes(app, prefix)
