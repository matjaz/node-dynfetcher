Dynfetcher
==========

[![Build Status](https://secure.travis-ci.org/matjaz/node-dynfetcher.png?branch=master)](http://travis-ci.org/matjaz/node-dynfetcher) [![Greenkeeper badge](https://badges.greenkeeper.io/matjaz/node-dynfetcher.svg)](https://greenkeeper.io/)

DynFetcher is a simple library for fetching parts of web pages using CSS selectors.

Fetch weather or TV program _or any other_ data from (X)HTML files in just a few lines using CSS selectors.

Example
-------

```
DynFetcher = require 'dynfetcher'

dyn = new DynFetcher 'http://ifconfig.me/'

itemData = 
    ip :
        selector : '#ip_address'
        required : on

dyn.find '#info_table', itemData, (err, info) ->
    if err
        console.error err
        return

    console.log info[0]
```

For latest updates visit [project's repository](https://github.com/matjaz/node-dynfetcher/).

Maybe you might find interesting [Yahoo! Query Language](http://developer.yahoo.com/yql/).
