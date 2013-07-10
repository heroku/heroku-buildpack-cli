Heroku buildpack: Heroku Toolbelt
=========================

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpacks) that
allows one to run Heroku Toolbelt in a dyno alongside application code.
It is meant to be used in conjunction with at least the
[minimal ruby](https://github.com/dpiddy/heroku-buildpack-ruby-minimal) as well
as other buildpacks as part of a
[multi-buildpack](https://github.com/ddollar/heroku-buildpack-multi).


Usage
-----

Example usage:

    $ ls -a
    .buildpacks  Gemfile  Gemfile.lock  Procfile  config/  config.ru

    $ heroku config:add BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git

    $ heroku config:add HEROKU_API_EMAIL=my-fake-email@gmail.com

    $ heroku auth:token
      aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

    $ heroku config:add HEROKU_API_PASSWORD=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

    $ cat .buildpacks
    https://github.com/heroku/heroku-buildpack-toolbelt.git
    https://github.com/dpiddy/heroku-buildpack-ruby-minimal.git

    $ git push heroku master
    ...
    -----> Fetching custom git buildpack... done
    -----> Multipack app detected
    =====> Downloading Buildpack: https://github.com/gregburek/heroku-buildpack-pgbouncer.git
    =====> Detected Framework: pgbouncer-stunnel
           Using pgbouncer version: 1.5.4
           Using stunnel version: 4.56
    -----> Fetching and vendoring pgbouncer into slug
    -----> Fetching and vendoring stunnel into slug
    -----> Moving the configuration generation script into app/.profile.d
    -----> Moving the start-pgbouncer-stunnel script into app/bin
    -----> pgbouncer/stunnel done
    =====> Downloading Buildpack: https://github.com/heroku/heroku-buildpack-ruby.git
    =====> Detected Framework: Ruby/Rack
    -----> Using Ruby version: ruby-1.9.3
    -----> Installing dependencies using Bundler version 1.3.2
    ...

The buildpack will install and configure pgbouncer and stunnel to connect to
`DATABASE_URL` over a SSL connection. Prepend `bin/start-pgbouncer-stunnel`
to any process in the Procfile to run pgbouncer and stunnel alongside that process.


