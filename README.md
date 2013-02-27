Warning
=======

This repo is under active development.

Intent
===========

This config is meant to act as a base config to set up a robust Drupal environment, including multiple servers fulfilling different roles.

Primary roles will include:

* Database
* Web Server
* Redis Server
* Background Runner

Steps Forward
=============

* Build 1 DB Machine (no chef)
* Setup vagrant role to be a drupal web server connecting to DB machine
* Test multiple web servers connecting to single DB
* Build Redis Box
* Update WebServer vagrant config to connect with Redis
* Build Background Runner box (should be similar to WebServer)
* Test background Runner connecting to DB and Redis
* Research deployment options of Vagrant -> AWS
