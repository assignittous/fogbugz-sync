_ = require('lodash')


exports.xmlLiteParser = {
  isArrayOfObjects: (obj)->
    isArray = obj instanceof Array
    if isArray
      return obj[0] instanceof Object
    else
      return false

  parse: (obj)->
    that = @
    output = {}

    if (obj instanceof Object)

      if obj.name?
        # check the children
        if obj.childs?

          children = {}
          _.forEach obj.childs, (attribute)->
            children[attribute.name] = that.parse(attribute.childs)
          output[obj.name] = children

      else
        if obj instanceof Array
          if obj.length == 1
            # might be a value
            #console.log "might be a value"
            if !@isArrayOfObjects(obj)
              output = obj[0]
            else
              output = that.parse(obj[0])
          else
            output = []
            _.forEach obj, (item)->
              output.push that.parse(item)
        else
          # todo: fix this? output should return {} by default
          console.log "got a non-array"
          console.log obj

    else
      # todo: fix this? output should return {} by default
      console.log "passed object is not an object"
      console.log obj

    return output


}
