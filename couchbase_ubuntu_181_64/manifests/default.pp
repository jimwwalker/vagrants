# ===
# Install and Run Couchbase Server
# ===

$version = "1.8.1"
$filename = "couchbase-server-enterprise_x86_64_$version.deb"

# Download the Sources
exec { "couchbase-server-source":
    command => "/usr/bin/wget http://packages.couchbase.com/releases/$version/$filename",
    cwd => "/vagrant/",
    creates => "/vagrant/$filename",
    before => Package['couchbase-server']
}

# Update the System
exec { "apt-get update":
	path => "/usr/bin"
}

# Install libssl dependency
package { "libssl0.9.8":
	ensure => present,
	require => Exec["apt-get update"]
}

# Install Couchbase Server
package { "couchbase-server":
    provider => dpkg,
    ensure => installed,
    source => "/vagrant/$filename",
    require => Package["libssl0.9.8"]
}

# Ensure the service is running
service { "couchbase-server":
	ensure => "running",
	require => Package["couchbase-server"]
}
