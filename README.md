# HA Cluster bootstrap salt formula

Salt formula to bootstrap and manage a [ClusterLabs](https://clusterlabs.org/) high availability cluster.

Mainly adapted to SUSE / openSUSE Linux distributions (it is based in
[crmsh](https://github.com/ClusterLabs/crmsh)), but it should be usable on other distributions with
some modifications.

## Features

The formula provides the capability to create and configure a multi node HA cluster. Here some
features:
- Initialize a cluster
- Join a node to an existing cluster
- Remove a node from an existing cluster
- Configure the pre-requirements (install required packages, configure `ntp/chrony`, create ssh-keys, etc)
- Auto detect if the cluster is running in a cloud provider (Azure, AWS or GCP)
- Configure sbd
- Configure corosync
- Configure the resource agents
- Install and configure the [ha_cluster_exporter](https://github.com/ClusterLabs/ha_cluster_exporter)

## Installation

The project can be installed in many ways, including but not limited to:

1. [RPM](#rpm)
2. [Manual clone](#manual-clone)

### RPM

On openSUSE or SUSE Linux Enterprise you can just use the `zypper` system package manager:
```shell
zypper install habootstrap-formula
```

**Important!** This will install the formula in `/usr/share/salt-formulas/states/cluster`. Make sure that `/usr/share/salt-formulas/states` entry is correctly configured in your salt minion configuration `file_roots` entry if the formula is used in a masterless mode.

You can find the latest development repositories at [SUSE's Open Build Service](https://build.opensuse.org/package/show/network:ha-clustering:sap-deployments:devel/habootstrap-formula).

### Manual clone

```
git clone https://github.com/SUSE/habootstrap-formula
cp -R cluster /srv/salt
```

**Important!** The formulas depends on `salt-shaptools` package, so make sure it is installed properly if you follow the manual installation.

## Usage

To use the formula the `cluster` entry must be included in the salt execution `top.sls` file. Here an example to execute the cluster formula in all of the nodes:

```
# This file is /srv/salt/top.sls
base:
  '*':
    - cluster
```

To configure the execution a pillar file is needed. Here an example of a pillar file for this formula: [pillar.example](https://github.com/SUSE/habootstrap-formula/blob/master/pillar.example)
This file must be stored in `/srv/pillar` as `cluster.sls` and the same folder must contain a `top.sls` to use it. For example:

```
# This file is /srv/pillar/top.sls
base:
  '*':
    - cluster
```

**Important!** The hostnames and minion names of the cluster nodes need to be the same for the
cluster join procedure to work correctly, and the nodes need to be able to reach each other by
hostname/minion name.

### Salt pillar encryption

Pillars are expected to contain private data such as user passwords required for the automated installation or other operations. Therefore, such pillar data need to be stored in an encrypted state, which can be decrypted during pillar compilation.

SaltStack GPG renderer provides a secure encryption/decryption of pillar data. The configuration of GPG keys and procedure for pillar encryption are desribed in the Saltstack documentation guide:

- [SaltStack pillar encryption](https://docs.saltstack.com/en/latest/topics/pillar/#pillar-encryption)

- [SALT GPG RENDERERS](https://docs.saltstack.com/en/latest/ref/renderers/all/salt.renderers.gpg.html)

**Note:**
- Only passwordless gpg keys are supported, and the already existing keys cannot be used.

- If a masterless approach is used (as in the current automated deployment) the gpg private key must be imported in all the nodes. This might require the copy/paste of the keys.

## OBS Packaging

The CI will automatically publish new releases to SUSE's Open Build Service every time a pull request is merged in the `master` branch. For that, update the new package version in [habootstrap-formula.spec](https://github.com/SUSE/habootstrap-formula/blob/master/habootstrap-formula.spec) and
add the new changes in [habootstrap-formula.changes](https://github.com/SUSE/habootstrap-formula/blob/master/habootstrap-formula.changes).

The new version will published at:
- https://build.opensuse.org/package/show/network:ha-clustering:sap-deployments:devel/habootstrap-formula
- https://build.opensuse.org/package/show/openSUSE:Factory/habootstrap-formula (only if the spec file version is increased)

## Test

The `Vagrantfile` and `test/` folder in this repository provides a
sample cluster configuration that uses the formula to create the HA
cluster.

This has been tested with Vagrant 2.1.2 on openSUSE Leap 15, but
should hopefully work with other versions as well.

``` bash
cd habootstrap-formula
vagrant up
./test/run
```

These steps will create the cluster nodes (salt master, and two ha
cluster nodes). In order to play with the formula, the file
`test/pillar/cluster.sls` can be changed to apply different options to
the cluster nodes (check the options in `pillar.example`).

To add more nodes to the cluster, new nodes information must be added
to `Vagrantfile`, `test/salt/common/hosts.sls` and `test/salt/top.sls`
files.

To access to the different nodes and play with them run:

``` bash
vagrant ssh {nodename}
```

### Troubleshooting

> Note: This advice is specific to openSUSE / SUSE distributions. For
> other distributions, the specific commands needed may be different.

To run the tests, `libvirt` must be installed and the daemon running:

``` bash
zypper in libvirt
systemctl start libvirtd
```
