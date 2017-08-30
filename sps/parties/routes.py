from .views import *


def setup_routes(app, prefix=None):
    app.router.add_get('/party/new/{password}',
                       create_party,
                       name='party-new')
    app.router.add_get('/party/register/{password}',
                       register_in_party,
                       name='party-register')

    app.router.add_get('/party/{token}',
                       websocket_handler,
                       name='party-handler')
