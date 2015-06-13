# STEP-Library

###Setup For Development

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


  
    
   
    
   
    

