include tomcat
include postgres

package { 'openjdk-6-jdk':
	ensure => present,
}
postgres::user { 'jirauser': 
	username => 'jirauser',
	password => 'jira_secret_password',
}

postgres::db { 'jiradb':
	name => 'jiradb',
	owner => 'jirauser'
}

class { "jira": 
	user => "jira", #the system user that will own the JIRA Tomcat instance
	database_name => "jiradb",
	database_driver => "org.postgresql.Driver",
	database_driver_jar => "postgresql-9.1-902.jdbc4.jar",
	database_driver_source => "puppet:///modules/jira/db/postgresql-9.1-902.jdbc4.jar",
	database_url => "jdbc:postgresql://localhost/jiradb",
	database_user => "jirauser",
	database_pass => "jira_secret_password",
	number => 2, # the Tomcat http port will be 8280
	memory => "1024m",
	version => "5.1.2", # the JIRA version
	jira_jars_version => "5.1",
	contextroot => "/",
	webapp_base => "/opt", # JIRA will be installed in /opt/jira
	require => [
		Postgres::Db['jiradb'],
		Class["tomcat"]
	],
}

exec {
	"apt-update" :
		command => "/usr/bin/apt-get update",
}
Exec["apt-update"] -> Package <| |>

