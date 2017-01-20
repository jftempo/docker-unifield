# Requirement

This image build UF on 10.04 and install needs to start devtests and testfield.


# Build

Then you have to build an image from this repository:

     docker build -t uf-tests:10.04 .

Now you have to run the container.

Initialize a local bzr repo:

    Create a local repository /home/template
    bzr init-repo /home/template
    bzr branch lp:unifield-server /home/template/unifield-server
    bzr branch lp:unifield-web /home/template/unifield-web
    bzr branch lp:~unifield-team/unifield-wm/sync-env/ /home/template/sync-env
    mkdir /home/template/tmp
    Copy homere.conf in /home/template/tmp

Start container:

    docker run -d --name uf4 -v /home/template:/home/template uf-tests:10.04

We know that:

  * it will be run in daemon (**-d** option)
  * the name of the container will be **uf4**
  * we mount our local directory */home/template* as */home/template* in our new container
  * on our machine, we use the **uf-tests:10.04** docker base to create this container (we built it previously)

And now you're running PostgreSQL / ssh / apache / postfix for Unifield.

# Access to the container

   docker exec -it uf4 /bin/bash

As SSHD is launched on the machine, we just have to do:
   ssh root@<ip_of_container>


## Use static ports

When you launch your container, just give ports you want. For previous command that run the container, we can have:

    docker run -d -p :5432 -p :22 -p 8000:8061 --name unifield3 -v /home/olivier/projets/Unifield:/opt/Unifield unifield:latest /usr/bin/supervisord

This follow this rule:

    -p IP:host_port:container_port

So we launch the container with 5432 and 22 static ports and 8061 port is redirected to 8000 one.

## List ports for each docker container

Just do this:

    docker ps

And you will see in the "ports" column the ports translations.

