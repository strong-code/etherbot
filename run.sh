#!/usr/bin/env bash
git checkout master
git pull
skill etherbot
screen -d -S etherbot ruby etherbot.rb
