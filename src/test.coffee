fogbugz = require("./index").fogbugz
parser = require("./lib/xml_lite_parser").xmlLiteParser
cson = require("cson")
_ = require('lodash')


credentials = cson.parseFile("creds.cson")
fogbugz.login credentials



console.log JSON.stringify parser.parse(fogbugz.projects()), null, 2

fogbugz.logout()
