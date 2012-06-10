puppet-jira
===========

Puppet module for managing Atlassian JIRA

# Installation #

Clone this repository in /etc/puppet/modules, but make sure you clone it as directory
'jira':

	cd /etc/puppet/modules
	git clone https://github.com/jurgenlust/puppet-jira.git jira

You also need the puppet-tomcat module:

	cd /etc/puppet/modules
	git clone https://github.com/jurgenlust/puppet-tomcat.git tomcat
	
To run the example Vagrant machine, you also need the puppet-postgres module:

	cd /etc/puppet/modules
	git clone https://github.com/jurgenlust/puppet-postgres.git postgres

	
# Usage #

The manifest in the tests directory shows how you can install JIRA.
For convenience, a Vagrantfile was also added, which starts a
Debian Squeeze x64 VM and applies the init.pp. When the virtual machine is ready,
you should be able to access jira at
[http://localhost:8280/](http://localhost:8280/).

Note that the vagrant VM will only be provisioned correctly if the jira,
tomcat and postgres modules are in the same parent directory.
	