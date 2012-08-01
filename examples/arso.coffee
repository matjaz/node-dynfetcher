DynFetcher = require '../lib/'

url = 'http://www.arso.gov.si/'
dyn = new DynFetcher url

extend = (dest, src...)->
    dest[p] = v for p, v of o for o in src
    dest

itemData =
    day :
        selector : '.'
        required : on

dyn.find '.napoved_obeti tr > th', itemData, (err1, weather) ->
    if err1
        console.error err1
        return

    itemData = 
        tempText :
            selector : '.'
            required : on

    processItemFn = (item) ->
        tempText = item.tempText.split ' / '
        item.min = tempText[0]
        item.max = tempText[1]
        delete item.tempText
        return item
    
    dyn.find '.napoved_obeti tr:nth-child(3) td', itemData, processItemFn, (err2, res2) ->
        if err2
            console.error err2
            return
        
        for item, i in res2
            extend weather[i], item

        itemData =
            typeIMG :
                selector : 'img'
                raw      : on
                process  : (prop) -> "http://www.arso.gov.si#{prop[0].getAttribute 'src'}"
            typeText     :
                selector : 'img'
                raw      : on
                process  : (prop) -> prop[0].getAttribute('alt').replace('er:', 'er').replace('pojav: ', '')
            weatherIMG   :
                selector : 'a>img'
                raw      : on
                process  : (prop) -> "http://www.arso.gov.si#{prop[0].getAttribute 'src'}"
            weatherText  : 
                selector : 'a>img'
                raw      : on
                process  : (prop) -> prop[0].getAttribute 'alt'
        dyn.find '.napoved_obeti tr:nth-child(2) td', itemData, (err3, res3) ->
            if err3
                console.error err3
                return

            i = 0
            res3.forEach (item) ->
                extend weather[i], item
                i++ if 'weatherIMG' of item

            console.log weather
