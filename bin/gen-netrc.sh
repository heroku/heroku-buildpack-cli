#!/usr/bin/env bash

cat >> ~/.netrc << EOF
machine dyno.heroku.com
  login $HEROKU_API_EMAIL
  password $HEROKU_API_PASSWORD
EOF
