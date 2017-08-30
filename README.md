# QubeStash / Varnish Cache

[![TravisCI Status Widget]][TravisCI Status] [![Coverage Status Widget]][Coverage Status]

[TravisCI Status]: https://travis-ci.org/qubestash/http-varnish-cache
[TravisCI Status Widget]: https://travis-ci.org/qubestash/http-varnish-cache.svg?branch=master
[Coverage Status]: https://coveralls.io/r/qubestash/http-varnish-cache
[Coverage Status Widget]: https://coveralls.io/repos/github/qubestash/http-varnish-cache/badge.svg?branch=master

## Supported tags

> **Debian Version is not supported yet**

* ~~`4.1.3`, `4.1`, `1`, `latest` (run `make build-latest`) ([Dockerfile](https://github.com/qubestash/http-varnish-cache/blob/master/4.1/Dockerfile))~~
* `4.1.3-alpine`, `4.1-alpine`, `1-alpine`, `alpine` (run `make build-alpine`) ([Dockerfile](https://github.com/qubestash/http-varnish-cache/blob/master/4.1/alpine/Dockerfile))

## ENV

### VCL_USE_CONFIG

> Default: no

### VCL_CONFIG

> Default: /etc/varnish/default.vcl

### VCL_CACHE_SIZE

> Default: 64m

### VCL_BACKEND_ADDRESS

> Default: 0.0.0.0

### VCL_BACKEND_PORT

> Default: 80

## Running 

### docker

```bash
# Clear containers if they exist by any chance
docker rm -f varnish-cache || true
# Run Varnish
docker run -e VCL_BACKEND_ADDRESS=192.168.0.1 --name varnish-cache -d qubestash/varnish-cache:alpine
```