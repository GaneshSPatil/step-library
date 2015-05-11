# STEP-Library

###Setup For Development
## Install RVM 
`\curl -sSL https://get.rvm.io | bash`

## Install rails
`gem install rails`

## Clone repository and start application server using following commands
git clone [https://github.com/tw-step/STEP-Library.git](https://github.com/tw-step/STEP-Library.git)
<br/>
`cd step-library` && `bundle install`
<br/>
either run `rails server` (for HTTP)
<br/>
or run `thin start --ssl  --ssl-key-file ssl/localhost.ssl.key  --ssl-cert-file ssl/localhost.ssl.cert` (for HTTPS)
<br/>
and visit `http://localhost:3000/`
* It requires Ruby 2.2.0


##Vagrant Box Setup
    
   Copy vagrant box file from **blrfs/TeamShares/STEP/STEP2/Library/library.box** to your local box.
   
###Add Vagrant Box
   
   Run bellow command
   
    vagrant box add library <Path-to-library.box-file> // add box to your box list 
    vagrant up // start the machine
    
   ssh to machine
   
    vagrant ssh 
   goto the project folder
   
    cd /vagrant
    
  run rails server
    
    rails s -b192.168.33.10
    RAILS_ENV=test rails s -b192.168.33.10 (to load application for testing environment)
    
  On your host machine locate your browser to 192.168.33.10:3000
    
   
    
   
    

