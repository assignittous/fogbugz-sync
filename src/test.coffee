fogbugz = require("./index").fogbugz
cson = require("cson")
_ = require('lodash')

###
credentials = cson.parseFile("creds.cson")
fogbugz.login credentials



console.log fogbugz.projects()

fogbugz.logout()
###

xmlObject = cson.parseFile("test.json")

iterator = 0

parser = (obj)->

  output = {}
  # console.log Object.keys(obj)
  iterator++
  if obj.name?
    console.log "#{iterator} NAME: #{obj.name}"
    if obj.childs?
      children = obj.childs
      console.log " #{obj.name} has childs"
      console.log obj.childs
    else
      children = null
    # only do this if is array of objects, otherwise 
    isArrayOfObjects = false
    if isArrayOfObjects
      output[obj.name] = parser(children)
    else
      output[obj.name] = children
    
  else
    # probably an array, so iterate
    if Array.isArray(obj)

      output = []
        #output = _.map obj, (item, key)->
        #  console.log item
          #return parser(item)
        _.forEach obj, (item)->
          output.push parser(item)
  
  return output


console.log JSON.stringify parser(xmlObject), null, 2

#console.log _.isTypedArray([])