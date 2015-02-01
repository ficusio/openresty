# OpenResty Docker image

This repository contains Dockerfiles for [ficusio/openresty](https://registry.hub.docker.com/u/ficusio/openresty/) image, which has two flavors.

### Flavors

The main one is [Alpine linux](https://registry.hub.docker.com/u/alpinelinux/base/)-based `ficusio/openresty:latest`. Its virtual size is just 39MB, yet it contains a fully functional [OpenResty](http://openresty.org) bundle  v1.7.7.1 and [`apk` package manager](http://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management), which allows you to easily install [lots of  pre-built packages](http://forum.alpinelinux.org/packages).

The other flavor is `ficusio/openresty:debian`. It is based on `debian:wheezy` and thus is much bigger in size (256MB). It is mostly useful for NginX profiling, as it may not be easy to build different profiling tools with [`musl` libc](http://www.musl-libc.org/), which is used in Alpine Linux.

### Paths & config

NginX is configured with `/opt/openresty/nginx` [prefix path](http://nginx.org/en/docs/configure.html), which means that, by default, it loads configuration from `/opt/openresty/nginx/conf/nginx.conf` file. The default HTML root path is `/opt/openresty/nginx/html/`.

OpenResty bundle includes several useful Lua modules, which are located in `/opt/openresty/lualib/` directory. This directory is already added to Lua package path, so you don't need to specify it in NginX `lua_package_path` directive.

NginX is built with LuaJIT 2.1, which is also available as stand-alone `lua` binary.

### `ONBUILD` hook

This image uses [`ONBUILD` hook](https://docs.docker.com/reference/builder/#onbuild) that automatically copies all files and subdirectories from the `nginx/` directory located at the root of Docker build context (i.e. next to your `Dockerfile`) into `/opt/openresty/nginx/`. The minimal configuration needed to get NginX running is the following:

```coffee
project_root/
 ├ nginx/ # all subdirs/files will be copied to /opt/openresty/nginx/
 |  └ conf/
 |     └ nginx.conf # your NginX configuration file
 └ Dockerfile
```

Dockerfile:

```dockerfile
FROM ficusio/openresty:latest
EXPOSE 8080
```

Check [the sample application](https://github.com/ficusio/openresty/tree/master/_example) for more complete example.

### Command-line parameters

NginX is launched with the `nginx -g 'daemon off; error_log /dev/stderr info;'` command. This means that you should not specify the `daemon` directive in your `nginx.conf` file, because it will lead to NginX config check error (duplicate directive).

No-daemon mode is needed to allow host OS' service manager, like `systemd`, or [Docker itself](https://docs.docker.com/reference/commandline/cli/#restart-policies) to detect that NginX has exited and restart the container. Otherwise in-container service manager would be required.

Error log is redirected to `stderr` to simplify debugging and log collection with tools like [progruim/logspout](https://github.com/progrium/logspout).

If you wish to run it with different command-line options, you can add `CMD` directive to your Dockerfile. It will override the command provided in this image. Another option is to pass a command to `docker run` directly:

```text
$ docker run --rm -it --name test ficusio/openresty bash
root@06823698db68:/opt/openresty/nginx $ ls -l
total 12
drwxr-xr-x    2 root     root          4096 Feb  1 14:48 conf
drwxr-xr-x    2 root     root          4096 Feb  1 14:48 html
drwxr-xr-x    2 root     root          4096 Feb  1 14:48 sbin
```

### Usage during development

To aviod rebuilding your Docker image after each modification of Lua code or NginX config, you can add a simple script that mounts config/content directories to appropriate locations and starts NginX:

```bash
#!/usr/bin/env bash

exec docker run --rm -it \
  --name my-app-dev \
  -v "$(pwd)/nginx/conf":/opt/openresty/nginx/conf \
  -v "$(pwd)/nginx/lualib":/opt/openresty/nginx/lualib \
  -p 8080:8080 \
  ficusio/openresty:latest "$@"

# you may add more -v options to mount another directories, e.g. nginx/html/

# do not do -v "$(pwd)/nginx":/opt/openresty/nginx because it will hide
# the NginX binary located at /opt/openresty/nginx/sbin/nginx
```

Place it next to your `Dockerfile`, make executable and use during development. You may also want to temporarily disable [Lua code cache](https://github.com/openresty/lua-nginx-module#lua_code_cache) to allow testing code modifications without re-starting NginX.
