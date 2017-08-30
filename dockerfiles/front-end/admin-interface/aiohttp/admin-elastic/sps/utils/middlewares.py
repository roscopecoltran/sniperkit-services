from aiohttp import web
from .elastic import update_all_indexes


async def trailing_slash_redirect_middleware(app, handler):
    async def redirect_handler(request):
        if request.path.endswith('/'):

            redirect_url = request.path[:-1]
            # redirecting with GET-params of origin url
            if request.query_string:
                redirect_url += '?' + request.query_string

            return web.HTTPFound(redirect_url)
        return await handler(request)
    return redirect_handler


async def cors_headers_middleware(app, handler):
    async def redirect_handler(request):
        response = await handler(request)
        response.headers["Access-Control-Allow-Origin"] = "*"
        response.headers["Access-Control-Allow-Methods"] = "POST, GET, OPTIONS"
        response.headers["Access-Control-Max-Age"] = "1000"
        response.headers["Access-Control-Allow-Headers"] = "*"
        return response
    return redirect_handler


async def elastic_index_middleware(app, handler):
    async def elastic_index_handler(request):
        if request.method == 'PUT' or request.method == 'POST':
            if request.path.startswith('/admin'):
                # I think this one should be implemented better
                # In matter of urgency, doing it with the silly way
                await update_all_indexes(
                    es=app['elastic'], pg=app['pool']
                )
        return await handler(request)
    return elastic_index_handler
