![Formula CI](https://github.com/SUSE/habootstrap-formula/workflows/Formula%20CI/badge.svg)

# HA Cluster bootstrap Salt formula

Salt formula to bootstrap and manage a [ClusterLabs](https://clusterlabs.org/) high availability cluster.

Mainly adapted to Linux distributions for SUSE (it is based in
[crmsh](https://github.com/ClusterLabs/crmsh)), but it should be usable on other distributions with
some modifications.

## Features

The formula provides the capability to create and configure a multi node HA cluster. Here are some of the features:
- Initialize a cluster
- Join a node to an existing cluster
- Remove a node from an existing cluster
- Configure the pre-requirements (install required packages, configure `ntp/chrony`, create ssh-keys, etc)
- Auto detect if the cluster is running in a cloud provider (Azure, AWS, or GCP)
- Configure SBD
- Configure Corosync
- Configure the resource agents
- Install and configure the [ha_cluster_exporter](https://github.com/ClusterLabs/ha_cluster_exporter)

## Installation

The project can be installed in many ways, including but not limited to:

1. [RPM](#rpm)
2. [Manual clone](#manual-clone)

### RPM

On openSUSE or SUSE Linux Enterprise use `zypper` package manager:

```shell
zypper install habootstrap-formula
```

**Important!** This will install the formula in `/usr/share/salt-formulas/states/cluster`. In case the formula is used in a masterless mode, make sure that the `/usr/share/salt-formulas/states` entry is correctly configured in the `file_roots` entry of the Salt minion configuration.

Depending on the patch level of the target system and the release cycle of this project, the package in the regular repository might not be the latest one. If you want the latest features, have a look in the test development repositories at SUSE's Open Build Service [network:ha-clustering:sap-deployments:devel/habootstrap-formula](https://build.opensuse.org/package/show/network:ha-clustering:sap-deployments:devel/habootstrap-formula).

### Manual Installation

A manual installation can be done by cloning this repository:

```
git clone https://github.com/SUSE/habootstrap-formula
```

**Important!** This will not install the the formula anywhere where salt can find it.  If the formula is used in a masterless mode, also make sure to copy the complete `netweaver` subdirectory to location defined in `file_roots` entry of your Salt minion configuration.

I. e.:

```
cd habootstrap-formula
cp -R cluster /srv/salt
```

**Important!** The formulas depends on [salt-shaptools](https://github.com/SUSE/salt-shaptools) package. Make sure it is installed properly if you follow the manual installation (the package can be installed as a RPM package too).

## Usage

Follow the next steps to configure the formula execution. After this, the formula can be executed using `master/minion` or `masterless` options:

1. Modify the `top.sls` file (by default stored in `/srv/salt`) including the `cluster` entry.

   Here is an example to execute the cluster formula in all of the nodes:

   ```
   # This file is /srv/salt/top.sls
   base:
     '*':
       - cluster
   ```

2. Customize the execution pillar file. Here an example of a pillar file for this formula with all of the options: [pillar.example](https://github.com/SUSE/habootstrap-formula/blob/master/pillar.example)
The `pillar.example` can be found either as a link to the file in the master branch or a file in the file system at `/usr/share/salt-formulas/metadata/hana/pillar.example`.

3. Set the execution pillar file. For that, modify the `top.sls` of the pillars (by default stored in `/srv/pillar`) including the `cluster` entry and copy your specific `cluster.sls` pillar file in the same folder.

   Here an example to apply the recently created `cluster.sls` pillar file to all of the nodes:

   ```
   # This file is /srv/pillar/top.sls
   base:
     '*':
       - cluster
   ```

4. Execute the formula.

   1. Master/Minion execution.

      `salt '*' state.highstate`

   2. Masterless execution.

      `salt-call --local state.highstate`


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

## Advanced usage

### Native Fencing

If running in the cloud, some cloud providers provide a native way (e.g. through an API) to fence nodes.

#### AWS

SUSE's recommendation is to use the native method to fence cluster nodes in AWS.

The AWS specific implementation is the "AWS STONITH Agent" called `stonith:external/ec2`.

No additional configuration is needed to enable this.

#### Azure

SUSE's recommendation is to use SBD (e.g. via iSCSI) to fence cluster nodes in azure.

The alternative azure specific implementation is the "Azure Fence Agent" called `stonith:fence_azure_arm`.

Please read the Microsoft Azure documentation [Create Azure Fence agent STONITH device](https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse-pacemaker#create-azure-fence-agent-stonith-device) for the detailed steps that are needed in azure.

Look into `pillar.example` for examples on how to configure this in salt.

The pillars will be used by other formulas, e.g. <https://github.com/SUSE/sapnwbootstrap-formula> to configure the needed cluster resources.

#### GCP

TBD

## OBS Packaging

The CI automatically publishes new releases to SUSE's Open Build Service every time a pull request is merged into `master` branch. For that, update the new package version in [_service](https://github.com/SUSE/habootstrap-formula/blob/master/_service) and
add the new changes in [habootstrap-formula.changes](https://github.com/SUSE/habootstrap-formula/blob/master/habootstrap-formula.changes).

The new version is published at:

- https://build.opensuse.org/package/show/network:ha-clustering:sap-deployments:devel/habootstrap-formula
- https://build.opensuse.org/package/show/openSUSE:Factory/habootstrap-formula (only if the spec file version is increased)

## Test

The `test` folder contains a set of tests to check the integrity of the formula. The tests check
if the provided pillar data is correctly rendered to find inconsistencies on the usage of the
user input. The tests don't really check if the `salt` code works properly, they rather test if
the formula uses and renders the states with the correct values.

In order to run the tests execute:

```
cd habootstrap-formula
bash ./test/validate-formula.sh
```

In order to improve or add new tests the pillar example from `test/test_pillars` can be changed (or
add new pillar files).

### Troubleshooting

> Note: This advice is specific to openSUSE / SUSE distributions. For
> other distributions, the specific commands needed may be different.

To run the tests, `libvirt` must be installed and the daemon running:

``` bash
zypper in libvirt
systemctl start libvirtd
```
