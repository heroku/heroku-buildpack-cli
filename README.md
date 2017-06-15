Heroku buildpack: Heroku Toolbelt
=========================

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpacks) that
allows one to run Heroku Toolbelt in a dyno alongside application code.

This is not a replacement for the [Heroku API](https://devcenter.heroku.com/articles/platform-api-reference#overview) or various clients like [v3 Ruby](https://github.com/heroku/platform-api), [node](https://www.npmjs.org/package/heroku-client) or [python](https://github.com/heroku/heroku.py). Some private APIs like `pgbackups` do require the buildpack, so this exists.

Usage
-----

Example usage:

    $ heroku config:set H_API_EMAIL=my-fake-email@gmail.com
    $ heroku config:set H_API_TOKEN=`heroku auth:token`

    $ heroku buildpacks:add https://github.com/mikehale/heroku-buildpack-cli
    $ heroku buildpacks:add heroku/ruby

    $ git push heroku master
    ...
    -----> Fetching custom git buildpack... done
    -----> Multipack app detected
    =====> Downloading Buildpack: https://github.com/gregburek/heroku-buildpack-toolbelt
    =====> Detected Framework: heroku-toolbelt
    -----> Fetching and vendoring Heroku Toolbelt into slug
    -----> Moving the netrc generation script into app/.profile.d
    -----> heroku toolbelt installation done
    =====> Downloading Buildpack: https://github.com/heroku/heroku-buildpack-ruby.git
    =====> Detected Framework: Ruby/Rack
    -----> Using Ruby version: ruby-1.9.3
    -----> Installing dependencies using Bundler version 1.3.2
    ...

    $ heroku run 'heroku auth:token'
    Running `heroku auth:token` attached to terminal... up, run.3706
    abcdef0123456789abcdef0123456789abcdef01

    $ heroku run 'vendor/heroku-toolbelt/bin/heroku pgbackups:capture SILVER -a myapp'
    Running `vendor/heroku-toolbelt/bin/heroku pgbackups:capture SILVER -a myapp` attached to terminal... up, run.9532

    HEROKU_POSTGRESQL_SILVER_URL  ----backup--->  b003

    Capturing... done
    Storing... done


Notes
------

Some PATH manipulation may be needed, expecially if you are using the
heroku-buildpack-ruby-minimal solely to provide a ruby execution environment
for the heroku cli gem. 

