# OCI Container

## Local Build Instructions

To build run the following in the root of the repository.

```sh
sudo docker build . -t ibex -f container/Dockerfile
```

## Using the Container

To run the container,
use the following command in the root of the repository.

```sh
sudo docker run -it --rm \
  -p 6080:6080 \
  -p 3333:3333 \
  -v $(pwd):/home/dev/demo:Z \
  ibex
```

To access the container go to [http://localhost:6080/vnc.html](http://localhost:6080/vnc.html).

## Using run the container rootless with podman

```sh
# build
podman build . -t ibex -f container/Dockerfile
# change repository ownership to container user
podman unshare chown 1000:1000 -R .
# run
podman run -it --rm \
  -p 6080:6080 \
  -p 3333:3333 \
  -v $(pwd):/home/dev/demo:Z \
  ibex
# change repository ownership back to host user
podman unshare chown 0:0 -R .
```
