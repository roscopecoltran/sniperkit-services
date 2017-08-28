## /Pipeline template/

Plantilla para /pipelines/ usando **Luigi** + **Docker**

### Prerequisitos

- `pyenv`
- `python version 3.5.2`
- `ag`
- `hub`
- `git flow`
- `docker`
- `docker-compose`
- `docker-machine`

### Instalando

1. Instala y ejecuta el pipeline mediante el comando

``` sh
./iniciar_pipeline.sh
```

Este archivo ejecutará las siguientes tareas:
  1. Crea maquinas con docker localmente
  2. Crea un swarm utilizando esas maquinas 
  3. Instala las imagenes necesarias
  4. Por último ejecuta el pipeline. 

Para poder visualizar el resultado graficamente con Luigi es necesario iniciar un servidor de Luigi:
``` sh
luigid
```
En [localhost](http://localhost:8082/), podremos observar el grafo dirigido aciclico (DAG) de iris pipeline.

![Image of IrisPipeline](https://github.com/eduardomtz/magicloop/blob/master/images/irispipeline.png)

Los archivos resultantes de la ejecución se encontrarán en /data/

![Image of IrisPipeline resultado json](https://github.com/eduardomtz/magicloop/blob/master/images/output.png)

De acuerdo a las siguientes especificaciones:

#### Tarea 3  (Grupal)

``` org

 Our old friend: *The Magic loop*, Ahora en su presentación de /pipeline/

 1.  Vamos a partir del =iris= /dataset/ y vamos a entrenar varios modelos para predecir la variable del tipo de flor.

 2. Estos modelos *no* pueden entrenar en serie. Cada modelo entrenará  en un =Task=, con parámetros: 
   - Nombre del algoritmo
   - Hiperparámetros

 3. La salida de los =Task= debe de ser un archivo =pickle= llamado =nombre_algoritmo/nombre_algoritmo-lista-hiperparámetros.pl= 
   y un archivo =json= con la siguiente estructura:

 {
   "algoritmo": "nombre_algoritmo",
   "hiperparametros": {
       "hiperparametro_1": valor,
       "hiperparametro_1": valor,
       ...
   "path": "path_al_archivo_pickle"
   }     
  
 }

```


>"El archivo necesario colocar iris.csv en la carpeta data (para este ejemplo ya debe estar ahí)."

Basado en el proyecto [pipeline-template](https://github.com/nanounanue/pipeline-template)
