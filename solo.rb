{
  "run_list": [
               "recipe[php]", 
               "recipe[mysql]", 
               "recipe[apache2]", 
               "recipe[openssl]", 
               "recipe[drupal]", 
               "recipe[drupal::drush]"
              ], 
  "mysql": {
    "server_root_password": "iloverandompasswordsbutthiswilldo",
    "server_repl_password": "iloverandompasswordsbutthiswilldo",
    "server_debian_password": "iloverandompasswordsbutthiswilldo"
  }
}
