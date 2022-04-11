#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

sudo apt-get install autoconf bison build-essential libffi-dev libssl-dev
sudo apt-get install libyaml-dev libreadline6 libreadline6-dev zlib1g zlib1g-dev curl git vim


sudo apt-get install g++ flex gperf ruby perl libsqlite3-dev libfontconfig1-dev
sudo apt-get install libicu-dev libfreetype6 libssl-dev libpng-dev libjpeg-dev

cd /usr/local/share
git clone git://github.com/ariya/phantomjs.git
cd phantomjs
git checkout 1.9
./build.sh

sudo ln -sf /usr/local/share/phantomjs/bin/phantomjs /usr/local/bin

wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins

sudo apt-get install mysql-client libmysqlclient-dev mysql-server

mysql --user=root --password=root -e \
  "CREATE USER 'jenkins'@'localhost' IDENTIFIED BY 'jenkins';
   GRANT ALL PRIVILEGES ON * . * TO 'jenkins'@'localhost';
   FLUSH PRIVILEGES;\q"

sudo touch /var/lib/jenkins/sample_database.yml
sudo chmod 755 /var/lib/jenkins/sample_database.yml

cat <<EOT >> /var/lib/jenkins/sample_database.yml
default: &default
  adapter: mysql2
  username: 'jenkins'
  password: 'jenkins'
  host: 'localhost'
  pool: 100
  encoding: utf8
  reconnect: true
test:
  <<: *default
  database: <%= "sample-test-#{ENV['BUILD_TAG']}" %>
EOT