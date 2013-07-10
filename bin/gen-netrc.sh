#!/usr/bin/env bash

cat >> ~/.netrc << EOF
machine dyno.heroku.com
  login $HEROKU_TOOLBELT_API_EMAIL
  password $HEROKU_TOOLBELT_API_PASSWORD
EOF
