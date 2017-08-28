# Docker Demo Stack

This application is part of my multi-part blog series:

[Real-World Rails development with Docker](https://itshouldbeuseful.wordpress.com/2017/02/02/real-world-rails-development-with-docker-part-1/)

## SSL

Self-signed SSL certificates are provided where applicable. You will need to [trust the certificate][trust-ssl-certificate].

## Local DNS

`dnsmasq` is configured to resolve all `localdev` requests to your host. You do not need to add any entries to your `/etc/hosts` file e.g.

- [http://app.vzaar.localdev](http://app.vzaar.localdev)
- [http://bg.vzaar.localdev](http://bg.vzaar.localdev)

To test your local DNS setup, you can do this:

```
dig this.is.a.test.localdev @127.0.0.1
```

You should see something like this in the response:

```
;; ANSWER SECTION:
this.is.a.test.localdev. 0 IN A 127.0.0.1
```

[trust-ssl-certificate]: http://www.robpeck.com/2010/10/google-chrome-mac-os-x-and-self-signed-ssl-certificates/
