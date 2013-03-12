load 'config.rb' if File.exists?('config.rb')

# Set defaults for configs not explicitly set.
HOSTONLY_IP ||= "192.168.64.100"
FORWARD_PORTS ||= {80 => 8080, 443 => 8443}
ROLE ||= 'standalone'
COUNT ||= ''
MYSQL_ROOT_PASSWORD ||= "rootpass"
MYSQL_REPL_PASSWORD ||= "replpass"
DEBIAN_PASSWORD ||= "debpass"
DRUPAL_PASSWORD ||= "drupalpass"
DRUPAL_DIR ||= "/var/www/html"

Vagrant::Config.run do |config|
  config.vm.host_name = "drupal-" + ROLE.downcase + COUNT

  config.vm.box = "centos-6.3-minimal"
  config.vm.box_url = "https://dl.dropbox.com/u/7225008/Vagrant/CentOS-6.3-x86_64-minimal.box"

  config.vm.customize [
                       "modifyvm", :id, 
                       "--memory", "1024",
                       "--cpus", "2"]

  # config.vm.network :bridged
  config.vm.network :hostonly, HOSTONLY_IP

  #These two speed up VM internet. Goes from 5+ second to get connection to .2 seconds...
  config.vm.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
  config.vm.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]

  ###
  ## This is expecting to map these directories to the VM
  #

  FORWARD_PORTS.each do |src, dest|
    config.vm.forward_port src, dest
  end

  config.vm.share_folder("v-root", "/vagrant", ".")
  config.vm.share_folder("cookbooks", "/var/chef/cookbooks", "cookbooks")

  ###
  ## The meat of the config
  #
  config.vm.provision :shell, :path => "cmd.sh"

  config.ssh.max_tries = 40
  config.ssh.timeout   = 120

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "./cookbooks"

    chef.json = {
      :www_root => '/vagrant/public',
      :mysql => {
        :server_root_password => MYSQL_ROOT_PASSWORD,
        :server_repl_password => MYSQL_REPL_PASSWORD,
        :server_debian_password => DEBIAN_PASSWORD
      },
      :drupal => {
        :db => {
          :password => DRUPAL_PASSWORD
        },
        :dir => DRUPAL_DIR
      },
      :hosts => {
        :localhost_aliases => ["drupal.vbox.local", "dev-site.vbox.local"]
      }  
    }

    if ('webserver', 'standalone').include?(ROLE)
      chef.run_list = [
                       "recipe[php]", 
                       "recipe[apache2]", 
                       "recipe[openssl]", 
                       "recipe[drupal]", 
                       "recipe[drupal::drush]"
                      ]
    end
    
    if ROLE == "standalone"
      chef.run_list = [
                       "recipe[mysql]", 
                      ]
    end
  end
end
