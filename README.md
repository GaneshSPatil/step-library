# STEP-Library

###Setup For Development
## Install RVM
`\curl -sSL https://get.rvm.io | bash`

## Install rails
`gem install rails`

## Clone repository and start application server using following commands
git clone [https://github.com/tw-step/STEP-Library.git](https://github.com/tw-step/STEP-Library.git)
<br/>
`cd step-library`
<br/>
either run `rails server` (for HTTP)
<br/>
or run `thin start --ssl  --ssl-key-file ssl/localhost.ssl.key  --ssl-cert-file ssl/localhost.ssl.cert` (for HTTPS)
<br/>
and visit `http://localhost:3000/`
* It requires Ruby 2.2.0
