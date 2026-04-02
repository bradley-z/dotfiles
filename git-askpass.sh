#!/bin/sh
case "$1" in
  *Username*) echo "bradley-z" ;;
  *Password*) echo "$GITHUB_TOKEN" ;;
esac
