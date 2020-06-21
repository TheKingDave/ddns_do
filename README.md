Example start command
```sh
docker run --rm --name ddns --env-file ./.env -p 4040:80 -v $(pwd)/tmp/:/etc/ddns ddns-do
```

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
