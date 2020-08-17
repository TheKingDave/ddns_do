## DDNS server for DigitalOcean

This is a small DDNS server that works with DigitalOcean.

### CLI Parameters

| Name        | Abbr | Description                                    | Default       |
| ----------- | ---- | ---------------------------------------------- | ------------- |
| config-file | c    | Defines which config file to load              | ./config.yaml |
| ddns-file   | d    | If set overrides DDNS-file specified in config | `null`        |
| help        | h    | Shows usage and exists                         | `false`       |

### Configuration

This part describes the configuration file, which is a YAML file. You can find an example with (nearly) all options in the [example folder](https://github.com/TheKingDave/ddns_do/blob/master/example/config.yaml)

| Name                  | Description                                                  | Defaut                                               |
| --------------------- | ------------------------------------------------------------ | ---------------------------------------------------- |
| dotenv                | Load dotenv file on startup                                  | `null`                                               |
| host                  | On which host to listen to. If you want to li                | 127.0.0.1                                            |
| port                  | Port to listen on                                            | 80                                                   |
| doAuthTokenEnv        | The DigitalOcean authentication token environment variable   | DO_AUTH_TOKEN                                        |
| ttl                   | Time to live of the dns records (min 30)                     | 60                                                   |
| ddns_file             | The file to load the ddns entries from                       | ddns                                                 |
| ipHeader              | If set gets the ip address from the header instead of the TCP connection | `null`                                               |
| logger                | Logger configuration ([link](#logger-configuration))         | `null`                                               |
| defaultPrioritization |                                                              | sent                                                 |
| suffixList            | Where to load the domain suffix list from                    | https://publicsuffix.org/list/public_suffix_list.dat |
| query                 | Query parameter configuration ([link](#query-parameter-configuration)) |                                                      |

#### Logger configuration

| Name       | Description                                                  | Default |
| ---------- | ------------------------------------------------------------ | ------- |
| level      | Level of logging output [Debug, Verbose, Info, Error], case insensitive | error   |
| color      | If the log level should be in color                          | `false` |
| timestamp  | If timestamp should be printed on start of every log         | `false` |
| stacktrace | If a stacktrace should be printed on errors                  | `false` |

#### Query parameter configuration

| Name       | Description                 |
| ---------- | --------------------------- |
| ip         | Sent IP from client         |
| domain     | Domain to update            |
| user       | Username for authentication |
| password   | Password for authentication |
| prioritize | Which prioritization to use |

### DDNS file format

The configuration of which domain can be changed with what username and password is done in the DDNS file.

The format is very simple and made after the example of the [passwd](https://en.wikipedia.org/wiki/Passwd) file.

The format is as follows: `domain:user:password`.

The password is hashed with BCrypt. (You can use this [tool](https://www.browserling.com/tools/bcrypt) to hash your password)

| Part     | Description                        | Example          |
| -------- | ---------------------------------- | ---------------- |
| domain   | Domain name                        | test.exmaple.com |
| username | The username                       | user             |
| password | The password in hashed bcrypt form | pass (cleartext) |

Composed example:

```text
test.example.com:user:$2a$12$jt9c5pN1ZURYspcFBjXV/uxn54RKpYv8EjhNExqY7owZyf/GZGzQK
```

### Run the server

Prerequisite: an DigitalOcean API token. You can generate one [here](https://cloud.digitalocean.com/account/api/tokens).

### Example configuration for [FritzBox](https://at.avm.de/produkte/fritzbox/)
```text
https://ddns.service/?ip=<ipaddr>&domain=<domain>&user=<username>&password=<pass>
```

#### Docker
Example docker run command
```sh
docker run --rm --name ddns --env-file ./.env -p 4040:80 -v $(pwd)/ddns:/var/lib/ddns_do/ddns thekingdave/ddns_do
```
Docker compose:
```yaml
version: '3.8'

services:
  ddns:
    image: thekingdave/ddns_do
    container_name: ddns
    env_file: .env
    volumes:
      - ./ddns:/var/lib/ddns_do/ddns
    restart: unless-stopped
```


