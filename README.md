# Logsight Installation

 <a href="https://logsight.ai/"><img src="https://logsight.ai/assets/img/logol.png" width="150"/></a>

A collection of scripts and other resources for an on-premise installation of [logsight.ai](https://logsight.ai).

Clone this repository:

```bash
git clone git@github.com:aiops/logsight-install.git
```

or 

```bash
git clone https://github.com/aiops/logsight-install.git
```

## Installation with docker-compose

All docker-compose, configuration and utility script files to install [logsight.ai](https://logsight.ai) via docker-compose are located in the docker-compose directory.

```bash
cd docker-compose
```

The easiest way is to run the utility script ```bash install.sh```. You need to accept the EULA when installing [logsight.ai](https://logsight.ai) by setting ```bash accept-license``` as the only command line argument for the script:

```bash
./install.sh accept-license
```

The script will prompt for an Elasticsearch and a PostgreSQL password. Alternatively, it is possible to set the following environment variables before running the script:

```bash
export ELASTICSEARCH_PASSWORD=<set a password>
export POSTGRES_PASSWORD=<set a password>
```

After all services are running, you can access the [logsight.ai](https://logsight.ai) dashboard via ```http://localhost:4200```.

Visit our logsight [docs](https://docs.logsight.ai/#/) for additional information about the installation and configuration of logsight.ai, sending of log data to logsight.ai, or explanation of different dashboards.

# Support

Please use the [GitHub issue tracker](https://github.com/aiops/logsight-install/issues) to report problems encountered during the installation process.

If you have general questions or need support, you can visit [https://logsight.ai](https://logsight.ai) and use the live chat or drop us an[email](mailto:support@logsight.ai?subject=[GitHub]Support Request)

