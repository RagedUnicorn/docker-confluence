# docker-confluence

> A docker base to build a container for Confluence based on Alpine Linux

This container is intended to build a base for running Confluence.

### Using the image

#### Start container

The container can be easily started with `docker-compose` command.

```
docker-compose up -d
```

Once the container is running navigate to http://[dockerhost]:8090 and finish the configuration. When setting up the database make sure to set the hostname of the database according to the value in docker-compose.stack.yml (by default postgresql).

#### Stop container

To stop all services from the docker-compose file

```
docker-compose down
```

### Creating a stack

To create a stack the specific `docker-compose.stack.yml` file can be used. It requires that you already built all the images that are consumed by the stack or that they are available in a reachable docker repository.

```
docker-compose build --no-cache
```

**Note:** You will get a warning that external secrets are not supported by docker-compose if you try to use this file with docker-compose.

#### Join a swarm

```
docker swarm init
```

#### Create secrets

**Note:** In this case secrets for all the used images need to be provided. The Confluence container in this case has no passwords by itself but the postgresql container does.

```
echo "app_user" | docker secret create com.ragedunicorn.postgresql.app_user -
echo "app_user_password" | docker secret create com.ragedunicorn.postgresql.app_user_password -
```

#### Deploy stack
```
docker stack deploy --compose-file=docker-compose.stack.yml [stackname]
```

For a production deployment a stack should be deployed.

## Dockery

In the dockery folder are some scripts that help out avoiding retyping long docker commands but are mostly intended for playing around with the container. For production use docker-compose or docker stack should be used.

#### Build image

The build script builds an image with a defined name

```
sh dockery/dbuild.sh
```

#### Run container

Runs the built container. If the container was already run once it will `docker start` the already present container instead of using `docker run`

```
sh dockery/drun.sh
```

#### Attach container

Attaching to the container after it is running

```
sh dockery/dattach.sh
```

#### Stop container

Stopping the running container

```
sh dockery/dstop.sh
```

## Healthcheck

The production and the stack image supports a simple healthcheck showing whether the container is healthy or not. This can be configured inside `docker-compose.yml` or `docker-compose.stack.yml`

## Development

To debug the container and get more insight into the container use the `docker-compose.dev.yml` configuration.

```
docker-compose -f docker-compose.dev.yml up -d
```

By default the launchscript `/docker-entrypoint.sh` will not be used to start Confluence. Instead the container will be setup to keep `stdin_open` open and allocating a pseudo `tty`. This allows for connecting to a shell and work on the container. A shell can be opened inside the container with `docker attach [container-id]`. Confluence itself can be started with `./docker-entrypoint.sh`. This step has to be repeated for the postgresql container.

## Links

Alpine packages database
- https://pkgs.alpinelinux.org/packages

## License

Copyright (C) 2018 Michael Wiesendanger

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
