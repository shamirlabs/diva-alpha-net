<br />
<div align="center">
  <a href="#">
    <img src="https://diva.community/metalogo.png" alt="Logo" width="200">
  </a>
  <h2 align="center">
    Liquid Staking protocol powered by Distributed Validators
  </h2>
</div>
<h1>Diva alpha testnet</h1>

This repository contains the necessary compose files to participate in the Diva alpha testnet using the docker images available at https://hub.docker.com/u/diva.

> **Warning**
> Important Security Notice: Docker may expose ports of your machine to the public. Please be aware that this setup does not implement any security measures. Running this testnet in an unprotected environment may expose your systems and data to potential risks. It is strongly recommended to deploy Diva in a secure and controlled network environment.

## 1. Install docker

This Github repository contains docker compose files that can be run using [docker](https://www.docker.com/). Please, [install docker](https://docs.docker.com/engine/install/) first if you want to join the Diva alpha net. Keep in mind that currently we provide only `linux/amd64` images.

## 2. Prepare your node

Type the following commands in the CLI of a UNIX based system to clone this repository to your local machine:

   ```sh
   # Clone the repository
   git clone https://github.com/shamirlabs/diva-alpha-net

   # Change directory
   cd diva-alpha-net/
   ```

To run a Diva node autonomously, you need to connect the Diva docker container to an execution client, a consensus client and a validator. Depending on your current setup, continue to one of the following sections:

- If you already have Ethereum clients running in the Goerli testnet, [continue to section 2.1](#21-run-diva-and-connect-it-to-your-ethereum-clients).
- If you don't have Ethereum clients running in the Goerli testnet, [continue to section 2.2](#22-run-diva-with-ethereum-clients-and-metrics-from-scratch).

Take into account that both options contain telemetry images to help us monitor and improve the testnet. If you want to disable such telemetry, follow the instructions described in x.x.

### 2.1 Run Diva and connect it to your Ethereum clients

To configure the consensus and execution clients, you **MUST** rename the file `.env.example` to `.env` and change the following values of the file:

- Replace the value `ws://127.0.0.1:8546` of `EXECUTION_CLIENT_URL` with the WebSocket endpoint of your execution client.
  ```sh
  EXECUTION_CLIENT_URL=ws://127.0.0.1:8546  # Change this (execution RPC WebSocket, geth example)
  ```

- Replace the value `http://127.0.0.1:3500` of `CONSENSUS_CLIENT_URL` with the REST API provider endpoint of your consensus client.

  ```sh
  CONSENSUS_CLIENT_URL=http://127.0.0.1:3500  # Change this (consensus REST API, prysm example)
  ```

- Replace the value `127.0.0.1:4000` of the `BEACON_RPC_PROVIDER` with the RPC provider endpoint of your consensus client.

  ```sh
  BEACON_RPC_PROVIDER=127.0.0.1:4000 # Change this (consensus RPC, prysm example)
  ```

To securely configure the Diva client, you **SHOULD** change the following values of the `.env` file  as well (these steps are optional in testnet, but highly recommended):

- Replace the value `changeThis` of the `DIVA_API_KEY` with the password that you want to use to login to your Diva node API. You must use this password later when accessing the Operator UI.

  ```sh
  DIVA_API_KEY=changeThis  # Change this (API key for the operator UI)
  ```

- Replace the value `vaultPassword` of the `DIVA_VAULT_PASSWORD` with the password that you want to use to login to your Diva node API. This password is used to encrypt the database of your node and could be useful to restore your node in the future. Be aware that once this parameter is set during the bootstraping of the node, you won't be able to change it until such functionality is implemented.

  ```sh
  DIVA_VAULT_PASSWORD=vaultPassword # Change this (password for the encrypted vault)
  ```

- Replace the value `username-address` of the `TESTNET_USERNAME` with the user ID that you want to use in the testnet (for instance, `prada-0x0000000000000000000000000000000000000000`).

  ```sh
  TESTNET_USERNAME=username-address  # Change this (recommended to username of the operator and ethereum address)
  ```
  
- Replace the value `docker-compose.yml` of the `COMPOSE_FILE` with the name of the docker compose file that you want to use).

  ```sh
  COMPOSE_FILE=docker-compose.yml # Change this (docker compose file name)
  ```

Once you have changed all the above values, continue configuring your node in [section 2.3](#23-configure-your-node).


### 2.2 Run Diva with Ethereum clients and metrics from scratch

Alternatively, if you don't have Ethereum clients running in the Goerli testnet already, use the file `docker-compose-with-clients-metrics.yml` to run all together. Such file contains:

- [Diva client](https://hub.docker.com/r/diva/diva) written in Golang
- [Reloader script](https://hub.docker.com/r/diva/reloader) service that syncs the public keys between the validator client and Diva
- [Diva Operator](https://hub.docker.com/r/diva/operator-ui) web UI for the Diva client API
- [Geth](https://github.com/ethereum/go-ethereum) execution client
- [Prysm](https://github.com/prysmaticlabs/prysm) consensus and validator clients
- [Prometheus](https://prometheus.io/), [Grafana](https://grafana.com/), [Jaeger](https://www.jaegertracing.io/) and [Vector](https://vector.dev/) for monitoring the testnet.

You **SHOULD** first change the recommended values described in [section 2.1](#21-run-diva-and-connect-it-to-your-ethereum-clients) in the `.env` file (you don't need to change the endpoints configuration). Continue configuring your node in [section 2.3](#23-configure-your-node).

If you are running your node inside a local network (e.g. you are a home staker), you **SHOULD** make sure to forward the P2P ports of the Execution and Consensus clients to your host machine. For Geth and Prysm, you should forward the ports `30303/tcp`, `30303/udp`, and `13000/tcp`. This is in addition to forwarding the Diva port `5050/tcp`. This is not relevant for cloud servers.

### 2.3. Configure your node

Your Diva client needs to talk to other nodes in order to perform signatures, receive duties, and find peers. For that reason:

- The port `5050` is used for P2P communication and **MUST** be open and exposed in your machine.
- The port `30000` is used to access the swagger API of your node and you **SHOULD** keep it open if you want to use the Operator UI.
- The port `80` is used by the Operator UI and you **SHOULD** open it if you want to serve the Operator UI.

You could also run the Operator UI locally on your laptop and connect to the port `30000` of your Diva client using a VPN, keeping access to your node as constrained as possible.

Finally, to run your node, execute the following command:

```sh
# Run the docker compose file
docker compose up -d
```

Your node should be up and running, ready to continue the setup using the Operator UI as described in [section 3](#3-setup-your-node).

## 3. Setup your node

Follow the instructions of the [following video](https://youtu.be/efkyU2oEygo) to setup your node using the Diva Operator web UI.

To do that, you will need to access to the Diva operator web UI in any of two ways:
   
   - Local: http://localhost
   - Remote: `http://YOUR_NODE_PUBLIC_IP`

If you access to it remotely, remember typing `YOUR_NODE_PUBLIC_IP:30000` when asked for the API URL of your node. 

[![Diva operator UI - alpha testnet demo](https://img.youtube.com/vi/efkyU2oEygo/hqdefault.jpg)](https://youtu.be/efkyU2oEygo)


## 4. Known bugs

- When using the file `docker-compose-with-clients-metrics.yml` or `docker-compose-with-clients.yml`, the Diva client will wait until the Ethereum nodes are synced without being able to start. If that happens, the Diva Operator UI might show a `Fetching your node identity...` message that never resolves. Please, restart the Diva client after your Ethereum clients are synced to solve the issue.

Please, report any other bugs [in our Discord](https://discord.com/invite/diva).
