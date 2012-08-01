Dynfetcher-node
===============

[![Build Status](https://secure.travis-ci.org/matjaz/dynfetcher-node.png?branch=master)](http://travis-ci.org/matjaz/dynfetcher-node)

DynFetcher is a simple library for fetching parts of web pages using CSS selectors.

Fetch weather or TV program _or any other_ data from (X)HTML files in just a few lines using CSS selectors.

Example
-------

```
DynFetcher = require '../lib/'

url = 'http://www.wunderground.com/weather-forecast/LJ/Maribor.html'
dyn = new DynFetcher url

itemData = 
    day :
        selector : '.titleSubtle'
        required : on
    min :
        selector : '.foreSummary'
        process  : (data) -> data.trim()
        required : on
    max :
        selector : '.foreSummary > span',

itemProcessFn = (item) ->
    if item.min?
        item.min = item.min.replace /\D+/g, ''
        if item.min.length
            item.min = parseInt item.min, 10
        else
            delete item.min

    if item.max?
        item.max = parseInt item.max, 10

    item

dyn.find 'div.foreGlance', itemData, itemProcessFn, (err, weather) ->
    if err
        console.error err
        return

    console.log weather
```

For latest updates visit [project's repository](https://github.com/matjaz/dynfetcher-node/).

Maybe you might find interesting [Yahoo! Query Language](http://developer.yahoo.com/yql/).
