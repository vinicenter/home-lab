# home-lab

## Reverse Proxy Installation

### Introduction

This repository provides a simple solution for setting up a reverse proxy on an external server with public IP address, enabling access to your Docker services over the external network.

The reverse proxy is installed on an external server, which is used to route traffic to your Docker services running on your home server.

This is necessary because most home networks do not have a public IP address, which makes it difficult to access your Docker services over the external network.

### Prerequisites

Before running the installation command, make sure the following prerequisites are met:

- [Debian-based OS](https://www.debian.org/)
- wget installed (`sudo apt install wget` is generally sufficient)
- iptables (`sudo apt install iptables` is generally sufficient)
- Establish a secure VPN connection between your external server (proxy) and the server running your Docker services. Consider using [Tailscale](https://tailscale.com/) for a secure VPN setup.

### Installation

Execute the following command to install the reverse proxy. Ensure that you understand the implications of this command before proceeding:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/vinicenter/home-lab/main/install-reverse-proxy.sh)
```

You can see the source code of the installation script [here](https://raw.githubusercontent.com/vinicenter/home-lab/main/install-reverse-proxy.sh)

This script should be run with root privileges.

Remember that you need to run this command on your external server (proxy), not on the server running your Docker services, when it asks for the target IP address, enter the IP address of the server running your Docker services.
