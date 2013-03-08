#!/usr/bin/env bash

function ECHO
{
   message=$1

   echo $message | tee -a $logfile
}

logfile="/var/log/cmdsh.log"

touch $logfile
chmod 666 $logfile

echo "cmd.sh | Todd Mosier -- Jacob Hayes" > $logfile
echo "Logfile: $logfile"
echo "See for detailed info and debug info"

cd /tmp

ECHO ""
ECHO "Downloading the EPEL repo..."
curl -OLs http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm >> $logfile
curl -OLs http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6 >> $logfile
ECHO "Downloading the REMI repo..."
curl -OLs http://rpms.famillecollet.com/enterprise/remi-release-6.rpm >> $logfile
curl -OLs http://rpms.famillecollet.com/RPM-GPG-KEY-remi >> $logfile
ECHO "Downloading the RPMForge repo..."
curl -OLs http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm >> $logfile
curl -OLs http://apt.sw.be/RPM-GPG-KEY.dag.txt >> $logfile

ECHO "Adding GPG keys..."
rpm --import RPM-GPG-KEY.dag.txt RPM-GPG-KEY-remi RPM-GPG-KEY-EPEL-6 >> $logfile
ECHO "Enabling repos..."
rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm rpmforge-release*.rf.x86_64.rpm &>> $logfile
cp -r /vagrant/enabled_remi.repo /etc/yum.repos.d/remi.repo
rm remi-release-6*.rpm epel-release-6*.rpm rpmforge-release*.rf.x86_64.rpm
rm RPM-GPG-KEY-EPEL-6 RPM-GPG-KEY-remi RPM-GPG-KEY.dag.txt

ECHO ""
ECHO "This may take awhile"
ECHO "Updating yum cache..."
yum makecache &>> $logfile

ECHO ""
ECHO "Installing useful stuff..."
yum install -y bind-utils mlocate vim emacs tree man mod_ssl php-gd php-cgi php-mysql php-intl php-curl libmcrypt redis bc htop &>> $logfile

ECHO ""
ECHO "Configuring 'redis'"
sed -i 's/^# maxmemory <bytes>/# 5 MB\nmaxmemory 5242880/' /etc/redis.conf >> $logfile
ECHO "Chkconfig enabling 'redis'"
chkconfig --level 2345 redis on >> $logfile

ECHO ""
ECHO "Opening HTTP and HTTPS ports..."
iptables -I INPUT 4 -j ACCEPT -p tcp --dport 80 >> $logfile
iptables -I INPUT 4 -j ACCEPT -p tcp --dport 443 >> $logfile
service iptables save >> $logfile

ECHO ""
ECHO "Installing Development Tools and Git"
yum -y groupinstall --disablerepo=rpmforge  "Development Tools" &>> $logfile

###
## CHANGE PWD
#

# ECHO \"GRANT ALL PRIVILEGES ON *.* TO 'db_user'@'localhost' IDENTIFIED BY PASSWORD 'mypwdSHA'\" | mysql -uroot -piloverandompasswordbutthiswilldo

# Install reasonably recent version of nodejs
if [[ -f /usr/local/bin/node ]] 
then
   ECHO ""
   ECHO "Node.JS version: `node -v`"
else
   ECHO ""
   ECHO "Downloading node.js..."
   wget http://nodejs.org/dist/v0.8.20/node-v0.8.20.tar.gz -O /usr/local/src/node.tar.gz &>> $logfile
   ECHO "Unzipping..."
   cd /usr/local/src
   tar -xf /usr/local/src/node.tar.gz >> $logfile
   cd node-v0.8.20
   ECHO "Configuring..."
   /usr/local/src/node-v0.8.20/configure &>> $logfile
   ECHO "Compiling..."
   make &>> $logfile
   ECHO "Installing..."
   make install >> $logfile
fi

ECHO ""
if (( `gem list | grep "net-ssh (2.6.5, 2.2.2)" | wc -l` == 1 ))
then
   ECHO "Net-ssh is already installed."
else
   ECHO "Installing 'net-ssh'"
   gem install net-ssh >> $logfile
fi

if (( `gem list | grep "capistrano" | wc -l` == 1))
then
   ECHO "Capistrano is already installed."
else
   ECHO "Installing 'capistrano'"
   gem install capistrano >> $logfile
fi

ECHO ""
if (( `cat /etc/passwd | grep "/home/user" | wc -l` == 1 )) && [[ -f /home/user/.ssh/authorized_keys  ]]
then
   ECHO "User 'user' already exists..."
else
   ECHO "Adding 'user' user..."
   useradd user >> $logfile
   ECHO "Adding 'user' to 'apache' group..."
   usermod -aG apache user >> $logfile
   ECHO "Setting up ssh pubkeys..."
   mkdir /home/user/.ssh
   echo 'my_pub_ssh_key' >> /tmp/authorized_keys 
   cp /tmp/authorized_keys /home/user/.ssh/authorized_keys 
   chown -R user.user /home/user/.ssh
   chmod 600 /home/user/.ssh/authorized_keys
   chmod 644 /home/user/.ssh
fi

if (( `cat /etc/passwd | grep "/home/apache" | wc -l` == 1 )) && [[ -f /home/apache/.ssh/authorized_keys ]]
then
   ECHO "Apache user already setup"
else
   # setting up apache to have same ssh keys as user
   mkdir -p /home/apache/.ssh
   cp -r /home/user/.ssh/* /home/apache/.ssh
   usermod -d /home/apache apache
   chown -R apache.apache /home/apache/.ssh
fi

ECHO ""
ECHO "#####"
ECHO " Done "
ECHO "#####"
