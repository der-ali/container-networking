# Container Networking

Examples of creating a network of linux containers (network namespaces).

[1 - Network Namespace](1-network-namespace/README.md)

[2 - Single Node](2-single-node/README.md)

[3 - Multi Node](3-multi-node/README.md)

[4 - Overlay Network](4-overlay-network/README.md)

## Installation

### OSX

```
brew cask install virtualbox
brew cask install vagrant
vagrant plugin install vagrant-vbguest
```

### Linux

```
sudo apt-get install virtualbox
sudo apt-get install vagrant
vagrant plugin install vagrant-vbguest
```

## Setup

To bring up the VMs for all examples:

```
make vagrant-up
```

## Status

To check the status of the VMs for all examples:

```
make vagrant-status
```

## Test

To run the tests for all examples:

```
make test
```

## Teardown

To destroy the VMs for all of the examples:

```
make vagrant-destroy
```

## Talks: 'Container Networking From Scratch' 

* 2018-06 - Bristol Cloud Native: https://www.youtube.com/watch?v=mICllKv8JM4&t=1712s 
* 2018-10 - Voxxed Days Bristol: https://voxxeddays.com/bristol/
* 2018-12 - KubeCon North America: https://www.youtube.com/watch?v=6v_BDHIgOY8

## References

https://blog.scottlowe.org/2013/09/04/introducing-linux-network-namespaces/
# container-networking
