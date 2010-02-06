#!/usr/local/bin/ruby 
require 'rubygems'
require 'hugo'

config = YAML.load_file(File.join(File.dirname(__FILE__),'htmldocs.yml'))


Hugo do 
  cloud "jackapps" do
    # database "jackdocs_production" do
    #   server "jackhq"
    #   user "jackadmin"
    #   password "jackdogbyte"
    # end
    #   
    #balancer
    
    app "htmldoc" do
      # ec2 private key
      key_name "ec2-keypair"      
      key_path "~/.ec2"
      cookbook "git://github.com/jackhq/hugo-cookbooks.git"
      
      run_list ["role[base-rack-apache]"]
    
      add_recipe 'github_keys', :github => {  
                    :url => "git@github.com:jackhq", 
                    :publickey => config["github"]["publickey"], 
                    :privatekey => config["github"]["privatekey"]
                  }
    
      add_recipe 'apache2'
      add_recipe 'packages', :package_list => config["package_list"]
      add_recipe 'gems', :gem_list => config["gem_list"]

      add_recipe 'apache2::mod_deflate'
      add_recipe 'apache2::mod_rewrite'
      add_recipe 'hugo_deploy', :hugo => {
                :app => {
                  :name => 'htmldoc',
                  :branch => 'HEAD',
                  :migrate => false,
                  :web => { :port => '80', :server_name => 'htmldoc.jackfile.com'} 
                }  
              }
      # New recipe to use the new bundler
      ['install', 'pack', 'lock'].each do |cmd|
        add_recipe 'bundler::' + cmd, :bundler => { :app => 'pdf2swf' }
      end
      
      instance "i-768f9d1e"
      servers 1
    end
    
    deploy
    
    print
  end
end
