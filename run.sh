#!/usr/bin/env bash
git checkout master
git pull
skill etherbot
screen -S etherbot -D ruby etherbot.rb
