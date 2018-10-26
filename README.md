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

In order to deploy a dummy cluster the repository contains a vagrant/salt configuration to see the hacluster formula working and run the desired configuration options.

To run the test follow the next steps:

``` bash
cd habootstrap-formula
vagrant up
vagrant ssh master -- sudo salt '\*' state.highstate
```

These steps will create the cluster nodes (salt master, and two ha cluster nodes). In order to play with the formula, the file `test/pillar/cluster.sls` can be changed to apply different options to the cluster nodes (check the options in `pillar.example`).

**Warning: salt highstate command may fail in the inti node, as the secondary nodes ssh public keys are already authorized in the initial node when pacemaker is started**

To add more nodes to the cluster, new nodes information must be added to `Vagrantfile`, `test/salt/common/hosts.sls` and `test/salt/top.sls` files.

To access to the different nodes and play with them run:

``` bash
vagrant ssh {nodename}
```

### Troubleshooting

To run the test `libvirt` tools must be installed and the daemon running. For that:
``` bash
zypper in libvirt
service libvritd start
```
