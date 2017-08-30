
async def get_by_title(es, query):

    body_query = {
        "match_phrase_prefix": {
            "title": {
                "query": query
            }
        }
    }

    res = await es.search(
        index='library',
        doc_type='song',
        body={"query": body_query, },
        _source=False
    )

    return [(hit['_id'], hit['_score']) for hit in res['hits']['hits']]


async def get_by_artist(es, query):

    body_query = {
        "match_phrase_prefix": {
            "artist": {
                "query": query
            }
        }
    }

    res = await es.search(
        index='library',
        doc_type='song',
        body={"query": body_query},
        _source=False
    )

    return [(hit['_id'], hit['_score']) for hit in res['hits']['hits']]
