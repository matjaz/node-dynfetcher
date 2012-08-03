should = require 'should'
if process.env.DYNFETHCER_COV
    DynFetcher = require '../lib-cov/dynfetcher'
else
    DynFetcher = require '../'

getDyn = ->
    new DynFetcher "#{__dirname}/data/weather.html"

describe 'Basics', ->

    it 'should handle failed resource', (done) ->
        dyn = new DynFetcher "#{__dirname}/404"
        dyn.find 'test', {}, (err, res) ->
            should.exist err
            should.not.exist res
            done()

    it 'should return error if selector returns no results', (done) ->
        dyn = getDyn()
        dyn.find 'test', {}, (err, res) ->
            should.exist err
            should.not.exist res
            err.message.should.equal 'Selector did not return any results.'
            done()

describe 'Validation', ->

    it 'should check properties is an object', (done) ->
        dyn = getDyn()
        dyn.find 'test', null, (err, res) ->
            should.exist err
            should.not.exist res
            err.message.should.equal 'Properties must be an object.'
            done()

    it 'should check property def is an object', (done) ->
        dyn = getDyn()
        dyn.find 'test', test : null, (err, res) ->
            should.exist err
            should.not.exist res
            err.message.should.equal 'test must be an object.'
            done()

    it 'should check property have selector', (done) ->
        dyn = getDyn()
        dyn.find 'test', test : {}, (err, res) ->
            should.exist err
            should.not.exist res
            err.message.should.equal 'test does not have selector specified.'
            done()

    it 'should check wildcard property must have name', (done) ->
        dyn   = getDyn()
        items =
            '*' :
                selector : 'div'
        dyn.find 'test', items, (err, res) ->
            should.exist err
            should.not.exist res
            err.message.should.equal 'Selector "div" must sprecify name.'
            done()

    it 'should check property.process is a valid function reference', (done) ->
        dyn   = getDyn()
        items =
            'test' :
                selector : 'div'
                process  : ''

        dyn.find 'test', items, (err, res) ->
            should.exist err
            should.not.exist res
            err.message.should.equal 'test process parameter is not a valid function.'
            done()

    it 'should check property.process is a valid function', (done) ->
        dyn   = getDyn()
        items =
            day :
                selector : '.'
                process  : (item) -> undefinedVar

        dyn.find '.titleSubtle', items, (err, res) ->
            should.exist err
            should.not.exist res
            throw 'Should catch error' unless err.message.indexOf('undefinedVar') > -1
            done()

    it 'should check property.process has one parameter', (done) ->
        dyn   = getDyn()
        items =
            day :
                selector : '.'
                process  : ->

        dyn.find '.titleSubtle', items, (err, res) ->
            should.exist err
            should.not.exist res
            throw 'Should catch error' if err.message isnt 'day process wrong number of parameters.'
            done()

    it 'should check item.process is a valid function reference', (done) ->
        dyn   = getDyn()
        items =
            test :
                selector : 'div'
        dyn.find 'test', items, '', (err, res) ->
            should.exist err
            should.not.exist res
            err.message.should.equal 'processItemFn parameter is not a valid function.'
            done()
    
    it 'should check itemProcessFn is a valid function', (done) ->
        dyn   = getDyn()
        items =
            test :
                selector : '.'
        itemProcessFn = (item) -> undefinedVar

        dyn.find '.titleSubtle', items, itemProcessFn, (err, res) ->
            should.exist err
            should.not.exist res
            throw 'Should catch error' if err.message.indexOf('undefinedVar') is -1
            done()

    it 'should check itemProcessFn has a correct number of parameters', (done) ->
        dyn   = getDyn()
        items =
            test :
                selector : '.'
        itemProcessFn = ->

        dyn.find '.titleSubtle', items, itemProcessFn, (err, res) ->
            should.exist err
            should.not.exist res
            throw 'Should catch error' if err.message.indexOf('processItemFn must accept exactly one parameter.') is -1
            done()

describe 'Processing', ->

    it 'should convert wildcard to named param', (done) ->
        dyn   = getDyn()
        items =
            '*' : 
                'selector' : '.'
                'name'     : 'div.titleSubtle'

        dyn.find 'div.foreGlance', items, (err, res) ->
            should.not.exist err
            res.length.should.equal 6
            res[0].should.have.property 'Tonight'
            res[2].should.have.property '*'
            done()

    it 'should skip items missing required wildcard name property', (done) ->
        dyn   = getDyn()
        items =
            '*' :
                'selector' : '.'
                'name'     : 'div.titleSubtle'
                'required' : on

        dyn.find 'div.foreGlance', items, (err, res) ->
            should.not.exist err
            res.length.should.equal 5
            res[0].should.have.property 'Tonight'
            res[4].should.have.property 'Sunday'
            done()

    it 'should include items without existing properties', (done) ->
        dyn   = getDyn()
        items = 
            day :
                selector : 'div.titleSubtle'

        dyn.find 'div.foreGlance', items, (err, res) ->
            should.not.exist err
            res.length.should.equal 6
            res[5].should.have.property 'day'
            res[5].day.should.equal 'Sunday'
            done()

    it 'should skip items with required properties', (done) ->
        dyn   = getDyn()
        items = 
            day :
                selector : 'div.titleSubtle'
                required : on

        dyn.find 'div.foreGlance', items, (err, res) ->
            should.not.exist err
            res.length.should.equal 5
            res[4].should.have.property 'day'
            res[4].day.should.equal 'Sunday'
            done()

    it 'should return raw property', (done) ->
        dyn   = getDyn()
        items = 
            summary :
                selector : 'div.foreSummary'
                raw      : on

        dyn.find 'div.foreGlance', items, (err, res) ->
            should.not.exist err
            res.length.should.equal 6
            for item, i in res
                # can not use should because summary is not "shouldened"
                should.exist item.summary, "Missing item #{i} summary"
                should.exist item.summary.length
                throw "Item #{i} summary should have one item" unless item.summary.length is 1
                throw "Item #{i} summary should be Node element" unless item.summary[0].nodeType?
            throw 'Item 0 summary should equal to "16 °C"' unless res[0].summary[0].childNodes[2].textContent isnt '16 °C'
            done()

    it 'should process property', (done) ->
        dyn   = getDyn()
        items = 
            summary :
                selector : '.titleSubtle',
                required : on,
                process  : (data) ->
                    if data.slice(-3) is 'day' then data.slice(0, 3) else null
        
        dyn.find 'div.foreGlance', items, (err, res) ->
            should.not.exist err
            temperatures = [
                'Fri'
                'Sat'
                'Sun'
            ]
            for item, i in res
                should.exist item.summary, "Missing item #{i} summary"
                item.summary.should.equal temperatures[i]
            done()


    it 'should process item', (done) ->
        dyn   = getDyn()
        items = 
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
                    return null if item.min < 18
                else
                    delete item.min

            if item.max?
                item.max = parseInt item.max, 10
                return null if item.max < 30

            item

        dyn.find 'div.foreGlance', items, itemProcessFn, (err, res) ->
            should.not.exist err
            res.should.eql [
                { min : 18, max : 30 }
                { min : 19, max : 31 }
            ]
            done()
