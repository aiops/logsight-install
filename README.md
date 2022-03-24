# Logsight Installation

 <a href="https://logsight.ai/"><img src="https://logsight.ai/assets/img/logol.png" width="150"/></a>

This repository contains a collection of scripts and other resources for an on-premise installation of [logsight.ai](https://logsight.ai).

Clone the repository with git https or ssh:
```bash
git clone git@github.com:aiops/logsight-install.git
```

```bash
git clone https://github.com/aiops/logsight-install.git
```

Switch into the ```logsight-install``` directory

```bash
cd logsight-install
```

## Installation with docker-compose

We provide all logsight.ai services as [Docker Images](https://hub.docker.com/orgs/logsight/repositories) which you can spin up with docker-compse. All compose, configuration and utility script files are located in the ```docker-compose``` directory.

The easiest way to do the installation is to run the utility script ```install.sh```. You need to accept the EULA when installing logsight.ai by setting ```accept-license``` as the only command line argument for the script.

```bash
./docker-compose/install.sh accept-license
```

The script will prompt for an Elasticsearch and a PostgreSQL password. Alternatively, it is possible to set the following environment variables before running the script.

```bash
export ELASTICSEARCH_PASSWORD=<set a password>
```

```bash
export POSTGRES_PASSWORD=<set a password>
```

When all services are running, you can access the logsight.ai landing page via [http://localhost:4200](http://localhost:4200).

# Documentation

Visit our logsight [docs](https://docs.logsight.ai/#/) for additional information about the installation and configuration of [logsight.ai](https://logsight.ai), sending of log data to [logsight.ai](https://logsight.ai), explanation of the different dashboards, and many more.

# Support

Please use the [GitHub issue tracker](https://github.com/aiops/logsight-install/issues) to report problems encountered during the installation process.

If you have general questions or need support, you can visit [https://logsight.ai](https://logsight.ai) and use the live chat or drop us an [email](mailto:support@logsight.ai?subject=[GitHub]Support%20Request).
