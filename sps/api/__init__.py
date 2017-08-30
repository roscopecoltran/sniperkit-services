from .routes import setup_routes
from .db import create_tables_sql, artist, song


def register_in_app(app, prefix=None):
    prefix = prefix.replace('/', '')
    app['apps'].update({
        # api`s app dictionary
        'api': {}
    })

    setup_routes(app, prefix)

    app.on_startup.append(db.create_tables_sql)
