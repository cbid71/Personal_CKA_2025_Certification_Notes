# Networking


## Linux Networking Basics

- switch and route
  * switch
  * route
  * default gateway
- DNS
- Network Namespace
- Docker Networking


https://github.com/kubernetes/dns/blob/master/docs/specification.md
https://coredns.io/plugins/kubernetes/


Network namespaces : to implemente network isolation.

```
# Create a network namespace
sudo ip netns add myns

# Create virtual Ethernet (veth) pairs
sudo ip link add veth0 type veth peer name veth0_ns
sudo ip link add veth1 type veth peer name veth1_ns
sudo ip link add veth2 type veth peer name veth2_ns

# NOTE : veth0, veth1, and veth2 stay in the root(default) namespace and veth0_ns,veth1_ns, veth2_ns will have to move in a dedicated namespace

# Move one end of each pair to the namespace
sudo ip link set veth0_ns netns myns
sudo ip link set veth1_ns netns myns
sudo ip link set veth2_ns netns myns

# Assign IP addresses inside the namespace
sudo ip netns exec myns ip addr add 192.168.1.1/24 dev veth0_ns
sudo ip netns exec myns ip addr add 192.168.1.2/24 dev veth1_ns
sudo ip netns exec myns ip addr add 192.168.1.3/24 dev veth2_ns

# Bring up the interfaces inside the namespace
sudo ip netns exec myns ip link set veth0_ns up
sudo ip netns exec myns ip link set veth1_ns up
sudo ip netns exec myns ip link set veth2_ns up

# Bring up the veth interfaces in the root namespace
sudo ip link set veth0 up
sudo ip link set veth1 up
sudo ip link set veth2 up

# NOTE : veth0, veth1, and veth2 do not need an IP to be up and running, you can add an IP to those interfaces but it's not mandatory
#        without IP veth0, veth1, and veth2 will only act as links to make veth_nsX alive.

# Verify inside the namespace
sudo ip netns exec myns ip a
```

By Default :
- those virtual interfaces can't ping each other.
- Those virtual interfaces only can communicated with their root interface (example : veth0_ns can communicate with veth0)
- interfaces like eth0 can reach veth0, veth1, and veth2 only if they have an IP (which is not mandatory)
- interfaces like veth_nsX are not reachable by interfaces like eth0

To make ping each other you have to create a **bridge**.

```
# Inside myns, create a bridge
sudo ip netns exec myns ip link add br0 type bridge
sudo ip netns exec myns ip link set br0 up

# Attach veth interfaces to the bridge
sudo ip netns exec myns ip link set veth0_ns master br0
sudo ip netns exec myns ip link set veth1_ns master br0
sudo ip netns exec myns ip link set veth2_ns master br0

# Assign an IP to the bridge
sudo ip netns exec myns ip addr add 192.168.1.1/24 dev br0
```

Now, all interfaces inside myns can ping each other through br0.


