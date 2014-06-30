# Requirement

Local user should be in this group: **docker**

Then fetch this repository:

    git clone git@github.com:TeMPO-Consulting/docker-unifield

And go into this one.

# Build

Then you have to build an image from this repository:

     docker build -t unifield:latest .

Now you have to run the container. But have a look to an example of what could be done:

    docker run -d -P --name unifield3 -v /home/olivier/projets/Unifield:/opt/Unifield unifield:latest /usr/bin/supervisord

We know that:

  * it will be run in daemon (**-d** option)
  * we open all ports given by *EXPOSE* option in the Dockerfile
  * the name of the container will be **unifield3**
  * we mount our local directory */home/olivier/projets/Unifield* as */opt/Unifield* in our new container
  * on our machine, we use the **unifield:latest** docker base to create this container (we built it previously)
  * the default command used when the container is launched is **/usr/bin/supervisord** so that all services will be available (ssh, postgresql, etc.)

And now you're running postgreSQL/ssh for Unifield.

# Access to the container

As SSHD is launched on the machine, we just have to do:

    ssh -p 49153 docker@localhost

And we enter in the container.

> Where do you found that 49153 is the right port for that?

To find the right port, you have some solutions.

## List ports for each docker container

Just do this:

    docker ps

And you will see in the "ports" column the ports translations.

## Use a script

You can find the given port for SSH using this command:

    docker inspect --format='{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostPort}}' unifield3

This will return *49153* for an example.

# Manage containers

If you want to stop the container:

    docker stop unifield3

To run an existing container:

    docker start unifield3

That's all!

# Find 5432 port

Just do this:

    docker inspect --format='{{(index (index .NetworkSettings.Ports "5432/tcp") 0).HostPort}}' unifield

