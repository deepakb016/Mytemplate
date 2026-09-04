# Dokku Setup

# Setup

On your dokku server run:

`dokku apps:create appname`

In your repo, add the remote repository for dokku

```
git remote add dokku dokku@<your-dokku-server>:appname
git push dokku master # (from the master branch)
```

Now we'll create the database & redis

```
dokku config:set MyTemplate APPNAME_ENV=prod FLASK_APP=manage.py
dokku postgres:create MyTemplate
dokku postgres:link MyTemplate MyTemplate
dokku redis:create MyTemplate
dokku redis:link MyTemplate MyTemplate
```

Lets setup the tables & secret key
```
dokku run MyTemplate ./manage.py initdb
dokku run MyTemplate ./manage.py generate-session-key
dokku config:set MyTemplate SECRET_KEY=<value-from-above> --no-restart
```

Next we'll set some basic environment variables

```
# If you haven't already:
# dokku config:set MyTemplate APPNAME_ENV=prod

dokku config:set MyTemplate MAIL_USERNAME='' MAIL_PASSWORD='' MAIL_DEFAULT_SENDER="appname\ <appname@appname.com>"

dokku config:set MyTemplate GOOGLE_CONSUMER_KEY='' GOOGLE_CONSUMER_SECRET=''  STRIPE_SECRET_KEY='' STRIPE_PUBLISHABLE_KEY='' SENTRY_DSN=''
```

Now lets add you as an admin user

```
dokku run MyTemplate flask shell

> user = User(email="youremail@gmail.com", password="", admin=True, role='admin')
> db.session.add(user)
> db.session.commit()
```

# Management

## Starting workers/scaling up

`dokku ps:scale appname web=1 work=1 scheduler=1`

## Setting up a custom domain

`dokku domains:add appname appname.com`

## Disable checks for non-web containers

`dokku checks:skip appname work,scheduler`


## HTTPS

Install the letsencrypt plugin for dokku [dokku-letencrypt](https://github.com/dokku/dokku-letsencrypt)

`dokku letsencrypt appname`
