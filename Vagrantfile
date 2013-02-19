Vagrant::Config.run do |config|
  config.vm.host_name = "drupal-fullstack"

  config.vm.box = "centos-6.3-minimal"
  config.vm.box_url = "https://dl.dropbox.com/u/7225008/Vagrant/CentOS-6.3-x86_64-minimal.box"

  config.vm.customize [
                       "modifyvm", :id, 
                       "--memory", "1024",
                       "--cpus", "2"]

  # config.vm.network :bridged
  config.vm.network :hostonly, "192.168.64.100"

  ###
  ## This is expecting to map these directories to the VM
  #

  config.vm.forward_port 80, 8080
  config.vm.share_folder("v-root", "/vagrant", ".")
  config.vm.share_folder("cookbooks", "/var/chef/cookbooks", "../cookbooks")
  config.vm.share_folder("src", "/code/myproject", "../code/myproject")

  ###
  ## The meat of the config
  #
#Swapping these until the sudoers issue is fixed.
  config.vm.provision :shell, :path => "test_sudo.sh"
#  config.vm.provision :shell, :path => "cmd.sh"

  config.ssh.max_tries = 40
  config.ssh.timeout   = 120

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "../cookbooks"

    chef.json = {
     :www_root => '/vagrant/public',
     :mysql => {
        :server_root_password => "rootpass",
        :server_repl_password => "replpass",
        :server_debian_password => "debpass"
     },
     :drupal => {
        :db => {
          :password => "drupalpass"
        },
        :dir => "/vagrant/mysite"
      },
      :hosts => {
        :localhost_aliases => ["drupal.vbox.local", "dev-site.vbox.local"]
      }  
    }

    chef.run_list = [
                     "recipe[php]", 
                     "recipe[mysql]", 
                     "recipe[apache2]", 
                     "recipe[openssl]", 
                     "recipe[drupal]", 
                     "recipe[drupal::drush]"
    ]
  end
end
