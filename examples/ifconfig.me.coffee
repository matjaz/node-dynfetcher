DynFetcher = require '../lib/'

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
