# boot2docker Vagrant Box [![Circle CI](https://circleci.com/gh/AlbanMontaigu/docker-compose.svg?style=shield)](https://circleci.com/gh/AlbanMontaigu/boot2docker-vagrant-box)

## Introduction

Forked from [AlbanMontaigu/boot2docker-vagrant-box] (https://github.com/AlbanMontaigu/boot2docker-vagrant-box), merci Alban !

My fork adds Docker Compose to the Vagrant box. Place your docker-compose.yml next to your Vagrantfile and you can start with *vagrant up* your Docker container in a Vagrant box.

Forked from [dduportal/boot2docker-vagrant-box](https://github.com/dduportal/boot2docker-vagrant-box), thanks Damien !

My fork is a simplier version (no parallels support) with my personal touch.

This repository contains the scripts necessary to create a Vagrant-compatible
[boot2docker](https://github.com/boot2docker/boot2docker) box and is compatible with Docker v1.10.1

If you work solely with Docker, this box lets you keep your Vagrant workflow and work in the most minimal Docker environment possible.

## Usage

The box is available on [Hashicrop's Atlas](https://atlas.hashicorp.com/sveb/boxes/boot2docker)

### Initialise your Vagrantfile.

    $ vagrant init sveb/boot2docker

### Modify your Vagrantfile
Define the box in your Vagrantfile:
config.vm.box = "sveb/boot2docker"

Add configuration for Docker Compose. Due to slow file sync we have to wait 10 seconds!
config.vm.provision "shell", inline: "sleep 10"
config.vm.provision :docker_compose, yml: "/vagrant/docker-compose.yml", run: "always";

Add your Dockercompose file and start your Vagrant box.

    $ vagrant up

# Further notes from [AlbanMontaigu] (https://github.com/AlbanMontaigu/boot2docker-vagrant-box)

If you want the actual box source file, you can download it from the [tags page](https://github.com/amontaigu/boot2docker-vagrant-box/tags).

## Tips & tricks

* Vagrant synced folder has been tested with :
  * Shared Folder for Virtualbox Desktop: This is default sharing system
  * [rsync](https://docs.vagrantup.com/v2/synced-folders/rsync.html) : add this line to your Vagrantfile (it will overwrite the default vboxsf sync behaviour) :

    ```ruby
config.vm.synced_folder ".", "/vagrant", type: "rsync"
    ```
  * [NFS](https://docs.vagrantup.com/v2/synced-folders/nfs.html) : For now, use environment variable to enable NFS (Mac OS and Linux tested). It will ask for your admin password.

    ```bash
    $ export B2D_NFS_SYNC=1
    $ vagrant up
    ```

* Network considerations :
  * By default, we use a NAT interfaces, which have its ports 2375 and 2376 (Docker IANA ports) forwarded to the loopback (localhost) of your physical host.


* If you want to tune contents (custom profile, install tools inside the VM) that do not fit into the "vagrant provisionning" lifecycle combinded with the un-persistence of boot2docker, the "bootlocal" system has been extended :
  * The [boot2docker FaQ](https://github.com/boot2docker/boot2docker/blob/master/doc/FAQ.md) says that you can provide a custom script, named bootlocal.sh to execute things at the end of the boot.
  * We customize in order to run that script from the /vagrant share when mounted, at the end of the boot.
  * So : just place a "bootlocal.sh" script alongside your Vagrantfile to customize what's inside your b2d VM.


* If you use the VM as a remote Docker daemon in a private networked docker server you need to add in your bootlocal.sh :
(Thanks to @Freyskeyd)

```
# Regenerate certs for the newly created Iprivate network IP
sudo /etc/init.d/docker restart
# Copy tls certs to the vagrant share to allow host to use it
sudo cp -r /var/lib/boot2docker/tls /vagrant/
```

Next, you need to configure your Docker environment :
```
# For VirtualBox provider:
export DOCKER_CERT_PATH=`pwd`/tls
export DOCKER_HOST=tcp://192.168.10.10:2376
export DOCKER_TLS_VERIFY=1
```

## Building the Box

If you want to recreate the box, rather than using the binary, then
you can use the scripts and Packer template within this repository to
do so in seconds.

To build the box, first install the following prerequisites:

  * [Make as workflow engine](http://www.gnu.org/software/make/)
  * [Packer as vagrant basebox builder](http://www.packer.io) (at least version 0.7.5)
  * [VirtualBox](http://www.virtualbox.org) (at least version 4.3.28)
  * [curl for downloading things](http://curl.haxx.se)
  * [bats for testing](https://github.com/sstephenson/bats)

Then run this command to build the box for VirtualBox provider:

```
make virtualbox
```
