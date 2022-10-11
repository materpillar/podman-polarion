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

## Installation script answer file

Actual Polarion installation is done during Container building phase.
An answer text file is piped into the installation to fill in the interactive
prompts shown by the installation file. Each line in the `install-*.answers.txt` corresponds to one prompt:

The prompts of the manual installation:

1. Press "Enter" to continue with manual installation...
   Or press "Ctrl+C" to stop the installation.
2. Do you want use a new local SVN repository with default settings?:
   Type answer <yes|no>, default [yes] 

For reference, even though not used anymore during container build, the prompts of the automated installation:

1.  Press "Enter" to continue with a clean installation... 
    Or press "Ctrl+C" to stop the installation.
2.  Do you want use a new local SVN repository with default settings?:
    Type answer <yes|no>, default [yes] 
3.  Would you like to check and install the prerequisities?
    Type answer <yes|no>, default [yes] 
4.  Do you want to copy predefined conf. files into /etc/httpd?
    Type answer <yes|no>, default [no] 
5.  Do you want to initialize and configure PostgreSQL database for Polarion?
    Type answer <yes|no>, default [yes] 
6.  Please, set a password for user 'polarion' through which Polarion will connect to the database:
    Password:
7.  When you are done press Enter to continue. 
    Or press "Ctrl+C" to halt the script. You can re-run it later.
8.  Do you want initialize the repository now?
    Type answer <yes|no>, default [yes] 
9.  Would you like install Polarion sample data?
    Type answer <yes|no>, default [yes]
10. Do you want start Polarion now?
    Type answer <yes|no>, default [yes] 