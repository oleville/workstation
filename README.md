# Oleville Vagrant Development Environment

## Installation Instructions

 - Download and install [VirtualBox](https://www.virtualbox.org).
 - Download and install [Vagrant](https://www.vagrantup.com).
 - Install the [Vagrant-HostsUpdater](https://github.com/cogitatio/vagrant-hostsupdater) Plugin using this command: `vagrant plugin install vagrant-hostsupdater`
 - Clone this repository to your machine, then navigate to this directory.
 - Grab a copy of the Oleville database, and place it in `database/backups`. Vagrant will look for a database there.
 - Run `vagrant up`. Voila!

## Using the Development Environment

After running the Installation Instructions, a virtual machine has been set up
which contains all of the files and programs oleville needs to run.
