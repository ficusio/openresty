# [OpenResty](http://openresty.org) Docker image

This repository contains Dockerfiles for [ficusio/openresty](https://registry.hub.docker.com/u/ficusio/openresty/) image, which has two flavors.

The main one is [Alpine linux](https://registry.hub.docker.com/u/alpinelinux/base/)-based `ficusio/openresty:latest`. Its virtual size is just 39MB, yet it contains a fully functional OpenResty v1.7.7.1 bundle and [`apk` package manager](http://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management), which allows you to easily install [lots of  pre-built packages](http://forum.alpinelinux.org/packages).

The other flavor is `ficusio/openresty:debian`, which uses `debian:wheezy` as a base image and is much bigger in size (256MB).
