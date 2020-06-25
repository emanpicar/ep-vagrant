
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

function initialize {
    # enter as superuser
    sudo su

    # upgrade all of system software as well as their dependencies to the latest version
    yum update -y

    yum install -y dos2unix wget git
}

function install_docker {
    # setup docker repo
    yum install -y yum-utils
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    # Install the 17.12.1 version of Docker CE and containerd
    yum install -y docker-ce docker-ce-cli containerd.io

    # Configure Docker to start on boot
    systemctl enable docker

    # # Use Docker as a non-root user "vagrant"
    # usermod -aG docker vagrant

    # Install docker-compose
    curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
}

function prepare_docker {
    # add configuration for proxy settings

    # Reload the systemctl configuration
    systemctl daemon-reload

    # Start Docker
    systemctl start docker
}

function install_java {
    yum install -y java-11-openjdk-devel

    java_home=$(update-alternatives --display java | grep -oP '(?<=link currently points to ).*(?=bin/java)')
    add_envar_via_bashrc JAVA_HOME "$java_home"
}

function install_maven {
    MAVEN_VERSION=3.6.3
    wget http://mirror.rise.ph/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
    tar -C /opt -xzf apache-maven-$MAVEN_VERSION-bin.tar.gz && rm apache-maven-$MAVEN_VERSION-bin.tar.gz
    add_envar_via_bashrc M2_HOME /opt/apache-maven-$MAVEN_VERSION/bin
    add_to_path_via_bashrc /opt/apache-maven-$MAVEN_VERSION/bin
}

function install_node {
    curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
    yum install -y nodejs
}

function install_golang {
    wget https://dl.google.com/go/go1.14.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.14.linux-amd64.tar.gz

    add_to_path_via_bashrc /usr/local/go/bin
    add_envar_via_bashrc GOPATH /usr/local/src/projects/GoWorkspace
}

function install_python_and_pip {
    yum install -y python3

    pip3 install --upgrade pip
    pip3 install virtualenv
}

# Utility methods
function add_to_path_via_bashrc {
    dir=$1

    # If dir is not yet in $PATH
    if [[ $PATH != *"$dir"* ]]; then
        if grep -qF "export PATH=" ~/.bashrc
        then
            # If PATH is already exported in .bashrc, append $dir to it
            sed -ie '/export PATH=/s~$~:'"${dir}"'~' ~/.bashrc
        else
            # Otherwise, write 'export PATH' in .bashrc with $dir appended
            echo "export PATH=\$PATH:$dir" >> ~/.bashrc
        fi
    fi
}

function add_envar_via_bashrc {
    var=$1
    value=$2
    grep -qF "export $var=" ~/.bashrc || echo "export $var=$value" >> ~/.bashrc
}

function sync_bashrcs {
    # Activate .bash_aliases inside .bash_rc
    echo "if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
    fi" >> ~/.bashrc

    # Copy .bash_aliases from 'vagrant' home to 'root' as well
    # This is the .bash_aliases provisioned through Vagrantfile
    dos2unix /home/vagrant/.bash_aliases
    cp -f /home/vagrant/.bash_aliases ~/

    # Copy updated .bashrc from 'root' to 'vagrant' home as well
    cp -f ~/.bashrc /home/vagrant
}


# Execute functions
initialize
install_docker
prepare_docker
install_java
install_maven
install_node
install_golang
install_python_and_pip

sync_bashrcs

# Exit superuser
exit

# Include bash configs as non-superuser (vagrant)
source ~/.bashrc