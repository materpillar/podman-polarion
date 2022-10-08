#
Automated installation fails because requires apache to start which it will do for port 80.
We can reconfigure it for port 8080 but that cause other problems.

# Manual actions to do before building container

Download the `PolarionALM_22_R1_linux.zip` from the Siemens servers and place it in the root folder of the repository.
Then execute:

```bash
unzip PolarionALM_22_R1_linux.zip -d container
patch -s -p0 < patch-unpacked-polarion.patch
```

To build the image run:

```bash
podman build -t polarion -f Containerfile container
```

Run the container with:

```bash
podman run --rm -ti -p 8080:80 polarion /bin/bash  
./init.sh
```