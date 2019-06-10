# HA Cluster bootstrap salt formula

Formulas for bootstrapping and managing a high availability cluster
using crmsh.

Mainly adapted to SUSE / openSUSE Linux distributions, but should be
usable on other distributions with minor modifications.

## Usage

To use, configure the cluster options using pillar data as described
in `pillar.example`. To create multiple clusters, different pillar
data can be applied to different groups of nodes with different nodes
as the init node.

**Important!** The hostnames and minion names of cluster nodes need to
be the same for the cluster join procedure to work correctly, and the
nodes need to be able to reach each other by hostname / minion
name. To see an example of how this is configured, see
`test/salt/common/hosts.sls` in this repository.

## Integration with other formulas

The following formula pillars support HA cluster bootstrap-

* [firewalld-formula](https://github.com/saltstack-formulas/firewalld-formula)

``` yaml
    extends:
       firewalld:
         services:
           cluster-formula:
             short: hacluster
             description: HA cluster firewall rules
             ports:
               tcp:
                 - 30865
                 - 5560
                 - 7630
                 - 21064
               udp:
                 - 5405
                 - 5407
         zones:
           public:
             services:
               - hacluster
```

* [packages-formula](https://github.com/saltstack-formulas/packages-formula>)

``` yaml     
     extends:
       packages:
         pkgs:
           wanted:
             - crmsh
             - resource-agents
             - fence-agents
             - sbd
```

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

### Known issues
* Failure running [join-the-cluster](./cluster/join.sls):

> Note: The current solution is to query **hawk** status. This doesn't exactly
> represent the state of **pacemaker** (hawk initialization is independent).
> Increasing the `join_timer` to wait pacemaker may help in some cases.

TODO: Replace to query **hawk** by checking **pacemaker** directly.
