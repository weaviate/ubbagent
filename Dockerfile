# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM golang:1.20-alpine3.18 AS build

COPY . /ubbagent-src/
WORKDIR /ubbagent-src/

RUN apk update && \
    apk add --no-cache make git busybox=1.36.1-r2 && \
    rm -rf /ubbagent-src/.git && \
    make clean setup build

FROM alpine:3.18
RUN apk update && \
    apk add --update libintl ca-certificates busybox=1.36.1-r2 && \
    apk add --virtual build_deps gettext && \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps && \
    rm -rf /var/cache/apk/*

COPY --from=build /ubbagent-src/bin/ubbagent /usr/local/bin/ubbagent
COPY docker/ubbagent-start /usr/local/bin/ubbagent-start
CMD ["/usr/local/bin/ubbagent-start"]
