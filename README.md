# HA Cluster bootstrap salt formula

[![Build Status](https://travis-ci.org/krig/habootstrap-formula.svg?branch=master)](https://travis-ci.org/krig/habootstrap-formula)

Formulas for bootstrapping and managing a high availability cluster
using crmsh.

Mainly adapted to SUSE / openSUSE Linux distributions, but should be
usable on other distributions with minor modifications.

## GOAL

Enable the configuration and installation of a high availability
cluster using salt. The basic machine setup doesn't have to be handled
using this formula, but the configuration of the cluster itself should
be.

### OPEN QUESTIONS

* stuff like ocfs2? do as a second step.

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
