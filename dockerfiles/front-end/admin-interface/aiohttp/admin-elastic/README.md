![Coverage](https://codecov.io/gh/maqquettex/sps_async/branch/dev/graph/badge.svg)
![TravisBuild](https://travis-ci.org/maqquettex/sps_async.svg?branch=dev)
# sps_async
Song Party Service v2 (powered by asyncio and aiohttp)

# Usage for my dear frontender

## Requirements:

 * docker ( ``` sudo pacman -S docker ``` )
 * docker-compose ( ``` sudo pip3 install docker-compose ``` )

Run:

 * ``` make conf_dev ``` for copying conf files to root dir (conf files in root dir are in .gitignore, so you  could change them to make own configuration)
 * ``` make ``` for running server (0.0.0.0:4000)
 * ``` make restart ``` if python backend changes and you want to reload it
 * ``` make stop ``` to stop all services
 * ``` make clean ``` to stop all services and clean images/volumes etc

