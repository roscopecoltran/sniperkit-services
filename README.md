# nav2_docker_compose
docker compose with micro containers, one for each navitia's service

# how to use
You'll need docker and docker-compose (tested with docker v1.12.1 and docker-compose v1.8.1)

run them all

`docker-compose up`

you can then add some data in the `default` coverage:

The input dir in in `tyr_beat` in `/srv/ed/input/<name_of_the_coverage>`.

The easiest way is to copy the data via docker:

`docker cp data/dumb_ntfs.zip navitiadockercompose_tyr_worker_1:/srv/ed/input/default/`

`navitiadockercompose_tyr_worker_1` is the name of the container, it can be different since it's dependant of the directory name.

(or you can change the docker-compose and make a shared volume).

Then you can query jormungandr:

http://localhost:9191/v1/coverage/default/lines

# additional instances
If you need additional instances, you can use the `docker-instances.jinja2` to generate another docker-compose file (if you want to do some shiny service discovery instead of this quick and dirty jinja template, we'll hapilly accept the contribution :wink: )

you'll need to install [j2cli](https://github.com/kolypto/j2cli)

`pip install "j2cli[yaml]"`

You need to provide the list of instances (the easiest way is to give it as a yaml file, check artemis/artemis_instances_list.yml for an example)

`j2 docker-instances.jinja2 my_instances_list.yml > additional_navitia_instances.yml`

Then you need to start the docker-compose with the additional instances

`docker-compose -f docker-compose.yml -f additional_navitia_instances.yml up`

To add data to a given instance, you'll need to do:

`docker cp data/dumb_ntfs.zip navitiadockercompose_tyr_worker_1:/srv/ed/input/<my_instance>`

# TODO
- move the tyr and kraken images to alpine :wink:
