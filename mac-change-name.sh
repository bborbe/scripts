#!/usr/bin/env bash

NAME="burn"

sudo scutil --set ComputerName "${NAME}"
sudo scutil --set LocalHostName "${NAME}"
sudo scutil --set HostName "${NAME}"
sudo hostname "${NAME}"
