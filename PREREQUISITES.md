### Database

Our production application runs on postgresql.

* Mac OS X: `brew install postgresql`.
* Ubuntu/Debian: `sudo apt-get install postgresql postgresql-contrib`.
* Fedora/Red Hat/CentOS: `sudo yum install postgresql-server postgresql-contrib`.

#### Creating a database

Create a database named crowdai_development using postgresql

* Log into psql server using: `sudo -u postgres psql`.
* You will be prompted with `postgres=#`.
* Create a new database using: `CREATE DATABASE crowdai_development;`.

### Ruby

Install rvm for Ruby management (http://rvm.io)

`curl -L https://get.rvm.io | bash -s stable`

**Note:** At this point during the process, you may want to log out and log back in, or open a new terminal window; RVM will then properly load in your environment.

**Ubuntu users:** You may need to enable `Run command as a login shell` in Ubuntu's Terminal, under `Edit > Profile Preferences > Title and Command`. Then close the terminal and reopen it. You may also want to run `source ~/.rvm/scripts/rvm` to load RVM.

Then, use RVM to install version 2.5.5 of Ruby:

`rvm install 2.5.5`


### Gems with Bundler

Ruby dependencies, or Gems, are managed with Bundler. 

`gem install bundler` - if it's not already installed, but it should be in a basic RVM ruby. 


### Assets with npm

Move into the `AIcrowd` folder using: `cd AIcrowd`.

Install npm using: `sudo apt-get install npm`.

Install npm packages using: `npm install .`.

**NOTE:** If you're having permission issues, please see https://docs.npmjs.com/getting-started/fixing-npm-permissions

**WARNING:** Please refrain from using `sudo npm` as it's not only a bad practice, but may also put your security at a risk. For more on this, read https://pawelgrzybek.com/fix-priviliges-and-never-again-use-sudo-with-npm/

### Localstack

The test suite uses [localstack](https://github.com/localstack/localstack) in place of AWS.  Follow the installation procedure [here](https://github.com/localstack/localstack#installing) and in a separate terminal run:
```
localstack start
```

Another option is to run localstack via docker:

```
docker run -p 4572:4572 localstack/localstack
```

The tests can be run with either Chrome or Firefox drivers.  The default is chrome but if you run into issues (such as the browser hanging during tests) you can install geckodriver from [here](https://github.com/mozilla/geckodriver/releases), make sure `geckodriver` is in your path, and finally add the following line to `application.yml#test`:
```
CAPYBARA_BROWSER_NAME: 'firefox'
```
