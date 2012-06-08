# Class: jira
#
# This module manages jira
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class jira (
	$user = "jira",	
	$database_name = "confluence",
	$database_driver = "org.postgresql.Driver",
	$database_driver_jar = "postgresql-9.1-902.jdbc4.jar",
	$database_driver_source = "puppet:///modules/confluence/db/postgresql-9.1-902.jdbc4.jar",
	$database_url = "jdbc:postgresql://localhost/confluence",
	$database_user = "confluence",
	$database_pass = "confluence",
	$number = 2,
	$version = "5.0.6",
	$contextroot = "jira",
	$webapp_base = "/srv"
){
	
# configuration
	$jira_build = "atlassian-jira-${version}" 
	$tarball = "${jira_build}-war.tar.gz"
	$download_dir = "/tmp"
	$downloaded_tarball = "${download_dir}/${tarball}"
	$download_url = "http://www.atlassian.com/software/jira/downloads/binary/${tarball}"
	$build_parent_dir = "${webapp_base}/${user}/build"
	$build_dir = "${build_parent_dir}/${version}"
	$jira_dir = "${webapp_base}/${user}"
	$jira_home = "${webapp_base}/${user}/jira-home"
	
	$webapp_context = $contextroot ? {
	  '/' => '',	
      '' => '',
      default  => "/${contextroot}"
    }
    
    $webapp_war = $contextroot ? {
    	'' => "ROOT.war",
    	'/' => "ROOT.war",
    	default => "${contextroot}.war"	
    }
	
# download the WAR-EAR distribution of JIRA
	exec { "download-jira":
		command => "/usr/bin/wget -O ${downloaded_tarball} ${download_url}",
		require => Tomcat::Webapp::User[$user],
		creates => $downloaded_tarball,
		timeout => 1200,	
	}
	
	file { $downloaded_tarball :
		require => Exec["download-jira"],
		ensure => file,
	}
	
	file { $build_parent_dir:
		ensure => directory,
		owner => $user,
		group => $user,
		require => Tomcat::Webapp::User[$user],
	}
	
	exec { "extract-jira":
		command => "/bin/tar -xvzf ${tarball} && mv ${jira_build}-war ${build_dir}",
		cwd => $download_dir,
		user => $user,
		creates => "${build_dir}/build.sh",
		timeout => 1200,
		require => [File[$downloaded_tarball],File[$build_parent_dir]],	
	}

	file { $build_dir:
		ensure => directory,
		owner => $user,
		group => $user,
		require => Exec["extract-jira"],
	}
	
	
	file { $jira_home:
		ensure => directory,
		mode => 0755,
		owner => $user,
		group => $user,
		require => Java::Webapp::User[$user],
	}
	
	file { "jira.properties":
		path => "${build_dir}/edit-webapp/WEB-INF/classes/jira-application.properties",
		content => template("jira/jira-application.properties.erb"),
		require => Exec["extract-jira"],
	}
	
	file { "dbconfig.xml" :
		path => "${jira_home}/dbconfig.xml",
		content => template("jira/dbconfig.xml.erb"),
		require => Exec["extract-jira"],
	}
	
	database::postgres::user { $user:
		username => $user,
		password => $database_pass,
	}
	
	database::postgres::db { $database :
		dbname => $user,
		dbowner => $user,
		require => Database::Postgres::User[$user],
	}
	
	exec { "build-jira":
		command => "/bin/sh build.sh && mv ${build_dir}/dist/${jira_build}.war ${webapp_base}/${user}/tomcat/webapps/${webapp_war}",
		user => $user,
		creates => "${webapp_base}/${user}/tomcat/webapps/${webapp_war}",
		cwd => $build_dir,
		require => [
			File["jira.properties"],
			File["dbconfig.xml"],
			Java::Webapp::Tomcat[$user],
			Database::Postgres::Db[$database]
		],
	}
	
	file { "${webapp_base}/${user}/tomcat/webapps/${webapp_war}" :
		ensure => file,
		owner => $user,
		group => $user,
		require => Exec["build-jira"],
	}
	
	exec { "download-extra-jira-libs":
		
	}

	tomcat::webapp { "${user}" :
		username => $user, 
		number => $number,
		webapp_base => $webapp_base,
		java_opts => "-server -Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true -Dmail.mime.decodeparameters=true -Xms128m -Xmx512m -XX:MaxPermSize=256m -Djava.awt.headless=true",
		server_host_config => template("jira/context.erb"),
		service_require => [File['confluence-war'], File['confluence-db-driver'], File[$confluence_home]],
		require => Class["tomcat"],
	}
	

}
