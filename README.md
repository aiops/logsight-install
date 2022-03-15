# Logsight Installation

 <a href="https://logsight.ai/"><img src="https://logsight.ai/assets/img/logol.png" width="150"/></a>

This repository contains a collection of scripts and other resources for an on-premise installation of [logsight.ai](https://logsight.ai).

Clone this repository

```bash
git clone git@github.com:aiops/logsight-install.git
```

or 

```bash
git clone https://github.com/aiops/logsight-install.git
```

Switch to the ```logsight-install``` directors:

```bash
cd logsight-install
```

## Install with docker-compose

All docker-compose, configuration and utility script files to install [logsight.ai](https://logsight.ai) via docker-compose are located in the docker-compose directory.

The easiest way to install [logsight.ai](https://logsight.ai) is to run the utility script ```install.sh```. You need to accept the EULA when installing [logsight.ai](https://logsight.ai) by setting ```accept-license``` as the only command line argument for the script:

```bash
./docker-compose/install.sh accept-license
```

The script will prompt for an Elasticsearch and a PostgreSQL password. Alternatively, it is possible to set the following environment variables before running the script:

```bash
export ELASTICSEARCH_PASSWORD=<set a password>
export POSTGRES_PASSWORD=<set a password>
```

When all services are running, you can access the [logsight.ai](https://logsight.ai) dashboard via [http://localhost:4200](http://localhost:4200).

## Uninstall with docker-compose

Run the ```uninstall.sh``` utility script if you want to uninstall [logsight.ai](https://logsight.ai):

```bash
./docker-compose/uninstall.sh
```

# Documentation

Visit our logsight [docs](https://docs.logsight.ai/#/) for additional information about the installation and configuration of logsight.ai, sending of log data to logsight.ai, or explanation of different dashboards.

# Support

Please use the [GitHub issue tracker](https://github.com/aiops/logsight-install/issues) to report problems encountered during the installation process.

If you have general questions or need support, you can visit [https://logsight.ai](https://logsight.ai) and use the live chat or drop us an[email](mailto:support@logsight.ai?subject=[GitHub]Support Request)

