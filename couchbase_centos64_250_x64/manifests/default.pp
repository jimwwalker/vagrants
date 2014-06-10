
# ===
# Install and Run Couchbase Server
# ===

$version = "2.5.0"
$stem = "couchbase-server-enterprise_$version"
$suffix = $operatingsystem ? {
    Ubuntu => ".deb",
    CentOS => "_x86_64.rpm",
}
$filename = "$stem$suffix"

# Download the Sources
exec { "couchbase-server-source":
    command => "/usr/bin/wget http://packages.couchbase.com/releases/2.5.0/couchbase-server-enterprise_2.5.0_x86_64.rpm" ,
    cwd => "/vagrant/",
    creates => "/vagrant/$filename",
    before => Package['couchbase-server']
}

# Install libssl dependency
package { "libssl0.9.8":
    name => $operatingsystem ? {
        Ubuntu => "libssl0.98",
        CentOS => "openssl098e",
    },
    ensure => present
}

# Install Couchbase Server
package { "couchbase-server":
    provider => $operatingsystem ? {
        Ubuntu => dkpg,
        CentOS => rpm,
    },
    ensure => installed,
    source => "/vagrant/$filename",
    require => Package["libssl0.9.8"]
}

# Ensure firewall rules are flushed (brute force, some CentOS images have firewall
# on by default).
exec { "disable-firewall":
    command => "/sbin/iptables --flush",
    before => Service["couchbase-server"]
}

# Ensure the service is running
service { "couchbase-server":
	ensure => "running",
	require => Package["couchbase-server"]
}
