#
Automated installation fails because requires apache to start which it will do for port 80.
We can reconfigure it for port 8080 but that cause other problems.

# Build images

## Manual actions to do before building images

Download the `PolarionALM_22_R1_linux.zip` from the Siemens servers and place it in the root folder of the repository.
Then execute:

```bash
unzip PolarionALM_22_R1_linux.zip -d container/app
patch -s -p0 < patch-unpacked-polarion.patch
```
(Patch created with `diff -ur container/app/Polarion container/app/Polarion.patched > patch-unpacked-polarion.patch`)

## Build app and postgres images
```bash
podman build -t polarion-app -f app.Containerfile container/app
podman build -t polarion-postgres -f postgres.Containerfile container/postgres
```

# Run containers

First start postgres container and create the pod:

```bash
podman run -d --restart=always --pod new:polarion_pod --name polarion-postgres -p 8080:80-e POSTGRES_PASSWORD=mysecretpassword polarion-postgres
```

Then add the polarion-app container to the pod:

```bash
podman run --pod polarion_pod --name polarion-app -ti polarion-app /bin/bash
```
Execute `./init.sh` inside the container.