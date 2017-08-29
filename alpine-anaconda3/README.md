# alpine-anaconda3 / Dockerfile

This Dockerfile builds a Python environment using [Anaconda 3](https://www.continuum.io/) on Alpine Linux.

It is made on the premise of using with Jupyter Notebook. I also make IRuby usable. For IRuby related, the following package is also included.

* pry
* pry-doc
* awesome_print
* gnuplot
* rubyvis
* nyaplot

## Requirements

* [Docker](https://www.docker.com) 1.12.1+

## Usage

To create a Docker image, use the following command.

```text
docker build -t my-anaconda3 .
```

The following command is an example of starting Jupyter Notebook.

```text
docker run -it --rm -v $(pwd):/opt/notebooks -p 8888:8888 my-anaconda3 jupyter notebook --notebook-dir=/opt/notebooks --ip="0.0.0.0" --port=8888 --no-browser
```

When Jupyter Notebook starts up, the following message will be displayed.

```text
The Jupyter Notebook is running at: http://0.0.0.0:8888/?token=************************************************
```

Opening `http://0.0.0.0:8888/?token=************************************************` in your web browser.

## License

This is licensed under the [MIT](https://github.com/asakaguchi/dockerfiles/blob/master/LICENSE) license.