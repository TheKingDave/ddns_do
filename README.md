## DDNS server for DigitalOcean

Example start command
```sh
docker run --rm --name ddns --env-file ./.env -p 4040:80 -v $(pwd)/tmp/:/etc/ddns docker.pkg.github.com/thekingdave/ddns_do/ddns_do:latest
```

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
