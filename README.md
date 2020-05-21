# Brothers in ARMs' docker-toolbox

[![Travis build status](https://api.travis-ci.org/biarms/docker-toolbox.svg?branch=master)](https://travis-ci.org/biarms/docker-toolbox) 
[![CircleCI build status](https://circleci.com/gh/biarms/docker-toolbox.svg?style=svg)](https://circleci.com/gh/biarms/docker-toolbox)

## Overview
The goal of this repo is to build a docker image that contains linux tools useful for building, testing and debugging purposes.

Resulting docker images are pushed on [dockerhub](https://hub.docker.com/r/biarms/docker-toolbox/).

## Release notes: 

### Version 0.0.1
- Base image is ubuntu:20.04 (20200423)
- Add the 'software-properties-common' ubuntu package
- Installed binaries are: sudo, curl, wget, make, pwgen, git, gnupg and lsb-release
- Install docker-ce cli, version 19.03.8

## How to build locally:
1. Option 1: `make`
2. Option 2: build as on CI thanks to the circleci cli with `make circleci-local-build`

