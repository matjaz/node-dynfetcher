Dynfetcher-node
===============

[![Build Status](https://secure.travis-ci.org/matjaz/dynfetcher-node.png?branch=master)](http://travis-ci.org/matjaz/dynfetcher-node)

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

For latest updates visit [project's repository](https://github.com/matjaz/dynfetcher-node/).

Maybe you might find interesting [Yahoo! Query Language](http://developer.yahoo.com/yql/).
