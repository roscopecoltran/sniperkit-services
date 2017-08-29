Docker compose file for artemis

the instances are listed in artemis_instances_list.yml

the file docker-artemis-instance.yml has been generated using j2cli (cf. general readme)

`j2 docker-instances.jinja2 artemis/artemis_instances_list.yml > artemis/docker-artemis-instance.yml`


To start artemis:

`docker-compose -f docker-compose.yml -f artemis/docker-artemis-instance.yml up`

# TODO
for the moment we just have the artemis platform with this, we'll need to add an artemis container and change artemis:
 - to be able to launch the binarization from another container (either by using an http call to tyr or by running `docker exec tyr_container manage.py load_data`)
 - to find a way around the `service kraken_toto start|stop` (I think we can just change artemis to work if the kraken is already started)
 - to find a way around the `service apache2 start|stop` (likewise, I think we can make artemis work with the jormungandr already started)
