# docker-redex
![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/warnyul/redex/latest) ![Docker Image Size (tag)](https://img.shields.io/docker/image-size/warnyul/redex/latest) ![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/warnyul/redex/latest) [![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](LICENSE)

## Usage

You can run ReDex with a single command:
```
docker run --rm -v "$(pwd)":"$(pwd)" -w "$(pwd)" warnyul/redex redex ./myapp.apk -o ./redex.apk
```

## Build

```
git clone https://github.com/warnyul/docker-redex.git
cd docker-redex
# Use -u to update redex to the latest commit before build
./build.sh -u
```

All image will be tagged with the redex's commit hash to identify builds.

## License

    Copyright 2020 Balázs Varga

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.