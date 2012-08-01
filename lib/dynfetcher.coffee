fs    = require 'fs'
jsdom = require 'jsdom'

class DynFetcher

    constructor : (@url) ->

    fetch : (callback) ->
        jsdom.env
            html : @url,
            src  : [fs.readFileSync "#{__dirname}/../vendor/sizzle.js", 'utf8'],
            done : callback

    getText : (elem) ->
        nodeType = elem.nodeType
        ret      = ''
        if nodeType
            if nodeType is 1 or nodeType is 9 or nodeType is 11
                ret += node.nodeValue for node in elem.childNodes when node.nodeType is 3 or node.nodeType is 4
            else if nodeType is 3 or nodeType is 4
                return elem.nodeValue
        else
            ret += @getText node for node in elem when node.nodeType isnt 8
        ret

    find : (itemSelector, properties, processItemFn, callback) ->
        
        unless callback
            callback      = processItemFn
            processItemFn = null
        
        if not properties or typeof properties isnt 'object'
            callback new TypeError 'Properties must be an object.'
            return
        
        for key, property of properties
            if not property or typeof property isnt 'object'
                callback new TypeError "#{key} must be an object."
                return
            unless property.selector?
                callback new TypeError "#{key} does not have selector specified."
                return
            if key is '*' and not property.name?
                callback new TypeError "Selector \"#{property.selector}\" must sprecify name."
                return
            if property.process? and typeof property.process isnt 'function'
                callback new TypeError "#{key} process parameter is not a valid function."
                return

        if processItemFn? and typeof processItemFn isnt 'function'
                callback new TypeError 'processItemFn parameter is not a valid function.'
                return

        @fetch (errors, window) =>
            if errors
                callback errors
                return
            
            err = null
            try
                results = window.Sizzle itemSelector
                if results?.length < 1 or typeof results isnt 'object'
                    callback new TypeError 'Selector did not return any results.'
                    return

                res = []
                results.forEach (result) =>
                    return if err?
                    item = {}
                    for name, p of properties
                        wild = off
                        if name is '*'
                            wild = on
                            nameRes = window.Sizzle p.name, result
                            if nameRes.length is 1
                                name = @getText nameRes[0]
                            else if p.required is on
                                return
                        if p.selector is '.'
                            itemRes = window.Sizzle null, result, [result]
                        else
                            itemRes = window.Sizzle p.selector, result
                        if itemRes.length is 0
                            return if p.required is on
                        else
                            if p.raw isnt on
                                itemRes = @getText itemRes
                            if p.process
                                itemRes = p.process itemRes
                                if itemRes isnt null
                                    item[name] = itemRes
                                else if p.required is on
                                    return
                            else
                                item[name] = itemRes
                    if not processItemFn or (item = processItemFn(item)) isnt null
                        res.push item
            catch e
                err = e

            if err?
                callback err
            else
                callback null, res

module.exports = DynFetcher
