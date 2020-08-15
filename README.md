## DDNS server for DigitalOcean

This is a small DDNS server that works with DigitalOcean.


#### DDNS file format
The configuration of which domain can be changed with what username and password is done in the DDNS file

The format is very simple and made after the example of the passwd file

The format is as follows: `domain:user:password`.
The password is hashed with BCrypt. (You can use this 
[tool](https://www.browserling.com/tools/bcrypt) to hash your password)

Example:
* domain: test.exmaple.com
* username: david
* password: david
```text
test.example.com:david:$2a$12$E2LB096sHfmOP2zkuKjzE.Ke57Ds1LzNTCl88Ug/JCrdV5lcGw6TS
```

#### Configuration
Example configuration with the default values
```yaml
# .env file to load
# if file not found logs warning
dotenv: .env
# host to bind to
host: 0.0.0.0
# port to listen to
port: 80
# env variable to get the do auth token from
doAuthTokenEnv: DO_AUTH_TOKEN
# TTL for domain entries
ttl: 60
# File to load for ddns data
ddns_file: /etc/ddns_do/ddns

# Default prioritization for sent or remote ip (sent, remote, error)
# what ip to use when the sent and remote ip dont match
default_prioritize: sent

# Url or Path for suffix_list
# gets download in docker build
suffixList: /etc/ddns_do/suffix.dat
# If a url, it downloads the list on startup
# suffixList: https://publicsuffix.org/list/public_suffix_list.dat

# HTTP query parameter mapping
query:
  ip: ip
  domain: domain
  user: user
  password: password 
  prioritize: prioritize
```

### Run the server
Prerequisite: an DigitalOcean api token. You kan generate one [here](https://cloud.digitalocean.com/account/api/tokens).

### Example configuration for [FritzBox](https://at.avm.de/produkte/fritzbox/)
```text
https://ddns.service/?ip=<ipaddr>&domain=<domain>&user=<username>&password=<pass>
```

#### Docker
Example docker run command
```sh
docker run --rm --name ddns --env-file ./.env -p 4040:80 -v $(pwd)/tmp/:/etc/ddns thekingdave/ddns_do
```
Docker compose:
```yaml
version: '3.8'

services:
  ddns:
    image: thekingdave/ddns_do
    container_name: ddns
    env_file: example/.env
    ports:
    - '4040:80'
    volumes:
    - ./config/:/etc/ddns
```

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
