fogbugz = require("./index").fogbugz
cson = require("cson")

credentials = cson.parseFile("creds.cson")

fogbugz.login credentials

console.log "fogbugz token"
console.log fogbugz.token

console.log fogbugz.getProjects()