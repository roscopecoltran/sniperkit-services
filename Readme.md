# Docker image for running spark 2.1 jobs

  * Java 8

  Based on image frolvlad/alpine-oraclejdk8:8.131.11-cleaned

Added spark support:
  * scala 2.10.1
  * scala spark 2.1.1

Added libraries to enable using AWS KPL (C++ libraries)
  * bash
  * libuuid
  * libidn
  * curl (needed to send metrics to AWS)
  * ca-certificate (needed for SSL)

Docker Image: https://hub.docker.com/r/drosenstark/alpine-spark2/

## Usage
at top of your Dockerfile:

    FROM drosenstark/alpine-spark2

## Maintainers
  * David Rosenstark <drosenstark@gmail.com>
