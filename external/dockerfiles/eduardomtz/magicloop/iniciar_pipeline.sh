
## Levantar maquinas para swarm
export MACHINE_DRIVER=virtualbox
for N in $(seq 1 5); do
   docker-machine create node$N
done

## Iniciar swarm
eval $(docker-machine env node1)

docker swarm init --advertise-addr $(docker-machine ip node1)

TOKEN=$(docker swarm join-token -q manager)
for N in $(seq 2 5); do
  eval $(docker-machine env node$N)
  docker swarm join --token $TOKEN $(docker-machine  ip node1):2377
done

eval $(docker-machine env node1)

## iniciar servicio 
docker service create --name registry --publish 5000:5000 registry:2

## crea infraestructura base
make create

## crea infraestructura de magicloop
make setup

## ejecuta el pipeline
make run
