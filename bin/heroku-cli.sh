#!/usr/bin/env bash

# Add cli to path
export PATH=$PATH:/app/heroku-cli/bin

# Setup .netrc
umask 0077
cat >> ~/.netrc << EOF
machine api.heroku.com
  password $HEROKU_TOOLBELT_API_PASSWORD
  login $HEROKU_TOOLBELT_API_EMAIL
machine code.heroku.com
  password $HEROKU_TOOLBELT_API_PASSWORD
  login $HEROKU_TOOLBELT_API_EMAIL
EOF
