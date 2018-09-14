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
`test/salt/salt/common/hosts.sls` in this repository.

## Integration with other formulae

The following formulae pillars support HA cluster bootstrap-

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
