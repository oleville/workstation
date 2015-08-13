# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
    # The most common configuration options are documented and commented below.
    # For a complete reference, please see the online documentation at
    # https://docs.vagrantup.com.

    # Every Vagrant development environment requires a box. You can search for
    # boxes at https://atlas.hashicorp.com/search.
    config.vm.box = "ubuntu/trusty64"

    # Set up the name of the virtual machine as it appears in Vagrant.
    config.vm.define "oleville" do |oleville|
    end

    # Set up the hostname for the virtual environment.
    config.vm.hostname = "oleville.local"

    # Set up the name of the virtual machine as it appears in VirtualBox.
    config.vm.provider "virtualbox" do |vb|
        vb.name = "oleville"
    end

    # SSH Agent Forwarding
    #
    # Enable agent forwarding on vagrant ssh commands. This allows you to use ssh keys
    # on your host machine inside the guest. See the manual for `ssh-add`.
    config.ssh.forward_agent = true

    # ================
    # Network Settings
    # ================

    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    config.vm.network "private_network", ip: "192.168.33.10"

    # Configure the Hosts file to point oleville.local to our virtual machine
    if defined?(VagrantPlugins::HostsUpdater)
        config.hostsupdater.aliases = ["oleville.local"]
        config.hostsupdater.remove_on_suspend = true
    end

    # ======================
    # Synced Folder Settings
    # ======================

    # These settings were largely used from Varying-Vagrant-Vagrants
    # https://github.com/Varying-Vagrant-Vagrants/VVV

    # The following config.vm.synced_folder settings will map directories in your Vagrant
    # virtual machine to directories on your local machine. Once these are mapped, any
    # changes made to the files in these directories will affect both the local and virtual
    # machine versions. Think of it as two different ways to access the same file. When the
    # virtual machine is destroyed with `vagrant destroy`, your files will remain in your local
    # environment.

    # /srv/database/
    #
    # This directory is used to maintain default database scripts as well as backed
    # up mysql dumps (SQL files) that are to be imported automatically on vagrant up
    config.vm.synced_folder "database/", "/srv/database"

    # /srv/config/
    #
    # This directory is currently used to maintain various config files for php and
    # apache as well as any pre-existing database files.
    config.vm.synced_folder "config/", "/srv/config"

    # /srv/log/
    #
    # If a log directory exists in the same directory as your Vagrantfile, a mapped
    # directory inside the VM will be created for some generated log files.
    config.vm.synced_folder "log/", "/srv/log", owner: "www-data"

    # /srv/www/
    #
    # If a www directory exists in the same directory as your Vagrantfile, a mapped directory
    # inside the VM will be created that acts as the default location for apache sites. Put all
    # of your project files here that you want to access through the web server
    config.vm.synced_folder "www/", "/srv/www/", owner: "www-data", mount_options: [ "dmode=775", "fmode=774" ]

    # =====================
    # Provisioning Settings
    # =====================

    # This provision script suppresses an error message that isn't actually an error. See
    # https://github.com/mitchellh/vagrant/issues/1673 for the issue.
    config.vm.provision "fix-no-tty", type: "shell" do |s|
        s.privileged = false
        s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
    end

    # Run the provisioning script, which will install all dependencies on the virtual machine
    # for development. This loads the external file "bootstrap.sh" and runs all of the commands
    # listed there.
    config.vm.provision "shell", path: "provision/bootstrap.sh"

    # These commands always start the webserver on boot, so we do not need to manually load it.
    config.vm.provision "shell", inline: "sudo service mysql restart", run: "always"
    config.vm.provision "shell", inline: "sudo service apache2 restart", run: "always"

    # Run the provisioning script which will grab WordPress and help setup Oleville
    config.vm.provision "shell", path: "provision/wordpress.sh"

    # Run the completed provision script, which provides a message to the user.
    config.vm.provision "shell", path: "provision/complete.sh"
end
