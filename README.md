# cassandra

#### Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with cassandra](#setup)
    * [What cassandra affects](#what-cassandra-affects)
    * [Beginning with cassandra](#beginning-with-cassandra)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [External Links](#external-links)

## Overview

This module installs and configures Apache Cassandra.  The installation steps
were taken from the installation documentation prepared by DataStax [1] and
the configuration parameters are the same as those for the Puppet module
developed by msimonin [2].

## Setup

### What cassandra affects

* Installs the Cassandra package (default **dsc21**).
* Ensures that the Cassandra service is enabled and running.
* Optionally installs the Cassandra support tools (e.g. cassandra21-tools).
* Optionally configures a Yum repository to install the Cassandra packages
  from.
* Optionally installs a JRE/JDK package (e.g. java-1.7.0-openjdk).
* Configures settings in */etc/cassandra/default.conf/cassandra.yaml*.

### Beginning with cassandra

This most basic example would attempt to install the default Cassandra package
(assuming there is an available repository).  See the following section for
more realistic scenarios.

```puppet
node 'example' {
  include '::cassandra'
}
```

## Usage

To install Cassandra in a two node cluster called 'Foobar Cluster' where
node1 (192.168.42.1) is the seed and a second node called node2
192.168.42.2 is also to be a member, do something similar to this:

```puppet
node 'node1' {
  class { 'cassandra':
    cluster_name               => 'Foobar Cluster',
    listen_address             => "${::ipaddress}",
    seeds                      => "${::ipaddress}",
    cassandra_package_name     => 'dsc21',
    cassandra_opt_package_name => 'cassandra21-tools',
    java_package_name          => 'java-1.7.0-openjdk',
    java_package_ensure        => 'latest',
    manage_dsc_repo            => true
  }
}

node 'node2' {
  class { 'cassandra':
    cluster_name               => 'Foobar Cluster',
    listen_address             => "${::ipaddress}",
    seeds                      => '192.168.42.1',
    cassandra_package_name     => 'dsc21',
    cassandra_opt_package_name => 'cassandra21-tools',
    java_package_name          => 'java-1.7.0-openjdk',
    java_package_ensure        => 'latest',
    manage_dsc_repo            => true
  }
}
```

### Class: cassandra

Currently this is the only class within this module.


#### Parameters

[*cassandra_opt_package_ensure*]
The status of the package specified in **cassandra_opt_package_name**.  Can be
*present*, *latest* or a specific version number.  If
*cassandra_opt_package_name* is *undef*, this option has no effect (default
**present**).

[*cassandra_opt_package_name*]
Optionally specify a support package (e.g. cassandra21-tools).  Nothing is
executed if the default value of **undef** is unchanged.

[*cassandra_package_ensure*]
The status of the package specified in **cassandra_package_name**.  Can be
*present*, *latest* or a specific version number (default **present**).

[*cassandra_package_name*]
The name of the Cassandra package.  Must be installable from a repository
(default **dsc21**).

[*cluster_name*]
The name of the cluster. This is mainly used to prevent machines in one logical
cluster from joining another (default **Test Cluster**).

[*java_package_ensure*]
The status of the package specified in **java_package_name**.  Can be
*present*, *latest* or a specific version number.  If
*java_package_name* is *undef*, this option has no effect (default
**present**).

[*java_package_name*]
Optionally specify a JRE/JDK package (e.g. java-1.7.0-openjdk).  Nothing is
executed if the default value of **undef** is unchanged.

[*listen_address*]
Address or interface to bind to and tell other Cassandra nodes to connect to
(default **localhost**).

[*manage_dsc_repo*]
If set to true then a repository will be setup so that packages can be
downloaded from the DataStax community edition (default **false**).

[*seeds*]
Addresses of hosts that are deemed contact points.  Cassandra nodes use this list of hosts to find each other and
learn the topology of the ring.  You must change this if you are running multiple nodes!  Seeds is actually a
comma-delimited list of addresses (default **127.0.0.1**).

## Reference

This module uses the package type to install the Cassandra package and the
optional Cassandra tools and Java package.

It uses the service type to enable the cassandra service and ensure it is
running.

It also uses the yumrepo type on the RedHat family of operating systems to
(optionally) install the *DataStax Repo for Apache Cassandra*.

## Limitations

This module currently has **VERY** basic functionality.  More parameters and configuration parameters will
be added later.

Tested on CentOS 7, Puppet (CE) 3.7.5 and DSC 2.1.5.

## External Links

[1] - *Installing DataStax Community on RHEL-based systems*, available at
http://docs.datastax.com/en/cassandra/2.1/cassandra/install/installRHEL_t.html, accessed 25th May 2015.

[2] - *msimonin/cassandra: Puppet module to install Apache Cassandra from
the DataStax distribution. Forked from gini/cassandra*, available at
https://forge.puppetlabs.com/msimonin/cassandra, acessed 17th March 2015.
