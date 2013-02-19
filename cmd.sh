#!/bin/bash

function ECHO
{
   message=$1

   echo $message | tee -a $logfile
}

logfile="/var/log/cmdsh.log"

sudo touch $logfile
sudo chmod 666 $logfile

echo "cmd.sh | Todd Mosier -- Jacob Hayes" > $logfile
echo "Logfile: logfile"
echo "See for detailed info and debug info"

if [[ -f /etc/yum.repos.d/epel-nodejs.repo ]]
then
   ECHO "Enabling the epel-nodejs repo..."
   sudo wget http://repos.fedorapeople.org/repos/lkundrak/nodejs/epel-nodejs.repo -o /etc/yum.repos.d/epel-nodejs.repo >> $logfile
fi

ECHO "Installing stuff..."
sudo yum install -y bind-utils mlocate vim emacs tree man nodejs mod_ssl php-gd php-cgi php-mysql php-intl php-curl libmcrypt redis bc >> $logfile

ECHO "Configuring \"redis\""
sudo sed -i 's/^# maxmemory <bytes>/# 5 MB\nmaxmemory 5242880/' /etc/redis.conf >> $logfile
ECHO "Chkconfig enabling \"redis\""
sudo chkconfig --level 2345 redis on >> $logfile

ECHO "Opening HTTP and HTTPS ports..."
sudo iptables -I INPUT 4 -j ACCEPT -p tcp --dport 80 >> $logfile
sudo iptables -I INPUT 4 -j ACCEPT -p tcp --dport 443 >> $logfile
sudo service iptables save >> $logfile

ECHO "Installing Development Tools and Git"
sudo yum -y groupinstall "Development Tools" >> $logfile
sudo yum install git --disablerepo=rpmforge >> $logfile

# wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm; rpm -Uhv rpmforge-release*.rf.x86_64.rpm
# sudo yum install -y htop
# wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm; wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm; sudo rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm

###
## CHANGE PWD
#

# echo \"GRANT ALL PRIVILEGES ON *.* TO 'db_user'@'localhost' IDENTIFIED BY PASSWORD 'mypwdSHA'\" | mysql -uroot -piloverandompasswordbutthiswilldo

# Install reasonably recent version of nodejs
#Need to add support for 'node: command not found'
if [[ `node -v` != 'v.0.8.20' ]] 
then
    sudo wget http://nodejs.org/dist/v0.8.20/node-v0.8.20.tar.gz -O /usr/local/src/node.tar.gz
    sudo tar -xvf /usr/local/src/node.tar.gz
    cd /usr/local/src/node-v0.8.20
    sudo /usr/local/src/node-v0.8.20/configure
    sudo make
    sudo make install
fi

sudo gem install net-ssh capistrano

sudo useradd user
sudo usermod -aG apache user
sudo mkdir /home/user/.ssh
echo 'my_pub_ssh_key' >> /tmp/authorized_keys 
sudo cp /tmp/authorized_keys /home/user/.ssh/authorized_keys 
sudo chown -R user.user /home/user/.ssh
sudo chmod 600 /home/user/.ssh/authorized_keys
sudo chmod 644 /home/user/.ssh

# setting up apache to have same ssh keys as user
sudo cp -r /home/user/.ssh /home/apache/
sudo usermod -d /home/apache apache
sudo chown -R apache.apache /home/apache/.ssh
