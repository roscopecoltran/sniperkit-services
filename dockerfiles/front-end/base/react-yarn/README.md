# docker-react-yarn

Make a react template app with yarn command 

```
docker volume create --driver local --name node_modules
docker run -it --rm -v $(pwd):/code -v node_modules:/code/node_modules smizy/nodejs sh
> /code # yarn add --dev react-scripts
> /code # yarn add react react-dom
> /code # exit

# Run dev server
docker run -it --rm -v $(pwd):/code -v node_modules:/code/node_modules -p 3000:3000 smizy/nodejs yarn start  

# Run build
docker run --rm -v $(pwd):/code -v node_modules:/code/node_modules smizy/nodejs yarn build 

# Run built page
docker run --rm -v $(pwd):/code -v node_modules:/code/node_modules smizy/nodejs yarn add --dev http-server
docker run -it --rm -v $(pwd):/code -v node_modules:/code/node_modules -w /code/build -p 8080:8080 smizy/nodejs hs

```