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
