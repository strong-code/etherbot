#!/usr/bin/env bash
git checkout master
git pull
skill etherbot
screen -d -m -S etherbot ruby etherbot.rb
