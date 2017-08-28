# zxinfo-app
This is the frontend [ZXInfo App](http://sinclair.kolbeck.dk) for the Sinclair Information search engine at http://search.kolbeck.dk

The application is built using the following:
* Node.js
* express
* AngularJS
* Angular Material

and requires the following module to run
* zxinfo-services - backend services for the webapp - [github](https://github.com/thomasheckmann/zxinfo-services)

# Installation
````
> npm install
````

# Running a standalone instance - e.g. for development
To start the server local execute the start.sh script and specify environment (usually production or development):
````
> NODE_ENV=development ./start.sh
````
And point your browser to http://localhost:8000/

# Environment configuration

Check config.json for configuration options. NOTE the container section (should be used if running containers only)

# Local development - nodemon
For development it is recommended to use a tool such as nodemon for automatic restart on changes. As config file is generated on app startup, use the following for starting nodemon - to avoid endless loop:
````
NODE_ENV=development nodemon --ignore public/javascripts/config.js
````

# Bulding Docker for zxinfo-app

## Build Docker image
To build & run the application using docker container:
````
> docker build . -t zxinfo-app
> docker run -d -p 8000:3000 -e "NODE_ENV=development" --name "zxinfo-node-local" zxinfo-app
````
And point your browser to http://localhost:8000/

## Move container to another location

Export/save container
````
> docker save --output zxinfo-app.tar zxinfo-app
````
Copy zxinfo-app.tar to server, and then restore on server

````
> docker load --input zxinfo-app.tar
````

# Docker Compose
The docker-compose contains definitions for the following services required for a full setup:
* zxinfo-es, elasticsearch instance
* zxinfo-services, backend services / API used by the frontend
* zxinfo-app, frontend application

To run it all
````
docker-compose -d
````
The following containers are now running:
* Elasticsearch on port 9200/9300
* Backend Services on port 8300
* Frontend application on port 8200

## Development setup
To run only the backend services zxinfo-services
````
docker-compose run --service-ports zxinfo-services
````
And how you have the following containers running:
* zxinfo-services on port 8300
* zxinfo-es in port 9200 & 9300 (known as zxinfo-es from service container)


# TODO
In not particulary order, stuff that eventually will be implemented.
* Search
	* Filtering on search
	* Facets on search
	* As-you-type suggestions from [Simple Search](http://incubator.kolbeck.dk/sinclair/)
* Add more screenshot
* Links from overview/list page
	* (Hardware should use manufactured instead of publisher - 1000018)
	* (Publiser with strange name fails - 0019066)
* New types of overview/browse
	* Screen, Magazine, Publisher, etc.
* API
	* Barcode search, Identifile (file match)
	* Image search


# Changelog
## 05-2017
* Color change
* Added protectionscheme(s) to detail page
* Added available formats to search result and detail page

## 05-2017
* Added Machine type navigation from detail view
* Added status Yes/Empty for Known errors
* Added subtype overview + type/subtype navigation from detail view

## 05-2017
* Series only shows title of group S
* Rest goes into "Additional Info(features)"
* Navigation by group/feature (e.g. games with Currah Speech)

## 05-2017
* Updated to ZXDB 29.04.2017

## 04-2017
* Added Role(s) info - for example 'Frank N Stein Re-booted - 0026834'

## 04-2017
* Download and filetype_id has changed. see [forum](https://www.worldofspectrum.org/forums/discussion/52951/database-model-zxdb/p24)
* - added as format to addtionals and downloads

## 01-2017
* Small changes related to backend change, which now uses ZXDB to create documents

## 01-2017
* Added alpine build for Docker
* Upgraded nodeJS to v7.4.0
* Upgraded Elasticsearch to v2.4.4

## 01-2017
* Refactored all code according to guidelines from: https://github.com/angular/angular-seed

## 01-2017
* Upgraded to AngularJS 1.6.x
* Added docker-compose support
* Added Side menu
* Added Publisher overview
* Release v1.0.0

## 10-2016
Docker file for building a container...

## 09-2016
* Re-factored searchService.js to remove duplicate code

## 09-2016
* Added slide/carousel with images to detail page

## 09-2016
* Added TABS to detailpage containing
	* Downloads
	* Additionals
	* Magazines
	* Adverts
* Nice flexible mobile friendly solution for tables, see [Respinsive Tables](https://css-tricks.com/responsive-data-tables/)

## 09-2016
* Added links from Detail page
	* Links to compilations
* Refactored - does not require elasticsearch, as API from incubator.kolbeck is used now.
* Backend
	* Rename API to REST standards, see [10 best practices](http://blog.mwaysolutions.com/2014/06/05/10-best-practices-for-better-restful-api/)
	* Search API /games/search
	* New API: Get game by gameid /games/:gameid

## 09-2016
* Added link to games in series on detail page

## 09-2016
* Search by publisher now uses the **/api/zxinfo/publisher** API from http://incubator.kolbeck.dk

## 09-2016
* From overview - publisher is a link, searching for all titles by publisher.

## 09-2016
* Search result HTML refactored to create <zx-search-result> component.
* Minor re-factoring into directives, services and controllers.

## 09-2016
* Added SPOT comments
* Added Series as list of titles
* Show default thumb/image - if first in additionals is not 'Loading screen'

## 09-2016 Initial version
