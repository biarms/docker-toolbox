# Brothers in ARMs' docker-toolbox

![GitHub release (latest by date)](https://img.shields.io/github/v/release/biarms/docker-toolbox?label=Latest%20Github%20release&logo=Github)
![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/biarms/docker-toolbox?include_prereleases&label=Highest%20GitHub%20release&logo=Github&sort=semver)

[![TravisCI build status image](https://img.shields.io/travis/biarms/docker-toolbox/master?label=Travis%20build&logo=Travis)](https://travis-ci.org/biarms/docker-toolbox)
[![CircleCI build status image](https://img.shields.io/circleci/build/gh/biarms/docker-toolbox/master?label=CircleCI%20build&logo=CircleCI)](https://circleci.com/gh/biarms/docker-toolbox)

[![Docker Pulls image](https://img.shields.io/docker/pulls/biarms/docker-toolbox?logo=Docker)](https://hub.docker.com/r/biarms/docker-toolbox)
[![Docker Stars image](https://img.shields.io/docker/stars/biarms/docker-toolbox?logo=Docker)](https://hub.docker.com/r/biarms/docker-toolbox)
[![Highest Docker release](https://img.shields.io/docker/v/biarms/docker-toolbox?label=docker%20release&logo=Docker&sort=semver)](https://hub.docker.com/r/biarms/docker-toolbox)

<!--
[![Travis build status](https://api.travis-ci.org/biarms/docker-toolbox.svg?branch=master)](https://travis-ci.org/biarms/docker-toolbox) 
[![CircleCI build status](https://circleci.com/gh/biarms/docker-toolbox.svg?style=svg)](https://circleci.com/gh/biarms/docker-toolbox)
-->

## Overview
The goal of this project is to build a docker image that contains linux tools useful for building, testing and debugging purposes.

Resulting docker images are pushed on [docker hub](https://hub.docker.com/r/biarms/docker-toolbox/).

## How to build locally
1. Option 1: with CircleCI Local CLI:
   - Install [CircleCI Local CLI](https://circleci.com/docs/2.0/local-cli/)
   - Call `circleci local execute`
2. Option 2: with make:
   - Install [GNU make](https://www.gnu.org/software/make/manual/make.html). Version 3.81 (which came out-of-the-box on MacOS) should be OK.
   - Call `make build`

## Release notes: 

### Version 0.0.1
- Base image is ubuntu:20.04 (20200423)
- Add the 'software-properties-common' ubuntu package
- Installed binaries are: sudo, curl, wget, make, pwgen, git, gnupg and lsb-release
- Install docker-ce cli, version 19.03.8

### Version 0.0.2
- Same as 0.0.1, but install docker-ce cli version 19.03.9
- Refactor the build
- Improve this README.md documentation
