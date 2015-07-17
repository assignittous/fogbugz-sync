
/*

Fogbugz uses an XML API, which means it needs some special handling compared to most APIs, which use JSON.
 */
'use strict';
var logger, request, xmlLite, xmlParse;

logger = require('knodeo-logger').Logger;

request = require("knodeo-http-sync").httpSync;

xmlParse = require('xml2js').parseString;

xmlLite = require("node-xml-lite");

exports.fogbugz = {
  token: null,
  host: null,
  raw: false,
  attributes: {
    cases: ["ixBug", "ixBugParent", "ixBugChildren", "ixProject", "fOpen", "sProject", "ixArea", "sArea", "sTitle", "sStatus", "ixPersonAssignedTo", "sPersonAssignedTo", "sEmailAssignedTo", "ixPersonOpenedBy", "ixPersonResolvedBy", "ixPersonClosedBy", "ixPersonLastEditedBy", "ixStatus", "ixBugDuplicates", "ixBugOriginal", "sStatus", "ixPriority", "sPriority", "ixFixFor", "sFixFor", "dtFixFor", "sVersion", "sComputer", "hrsOrigEst", "hrsCurrEst", "hrsElapsed", "c", "sCategory", "dtOpened", "dtResolved", "dtClosed", "ixBugEventLatest", "dtLastUpdated", "dtDue", "dtLastView", "ixRelatedBugs", "dtLastOccurrence"]
  },
  objectify: function(xml) {
    return JSON.stringify(xmlLite.parseString(xml), null, 2);
  },
  getRequest: function(suffix) {
    var response;
    if (this.token != null) {
      console.log("" + this.baseUrl + suffix);
      response = request.get("" + this.baseUrl + suffix);
      if (this.raw) {
        return response;
      } else {
        return this.objectify(response);
      }
    } else {
      logger.error("Not logged in");
      return false;
    }
  },
  logout: function() {
    var logoutXml;
    logoutXml = request.get(this.baseUrl + "cmd=logoff&token=" + this.token);
    logger.info("logout");
    this.token = null;
    return true;
  },
  login: function(credentials) {
    var attempt, that;
    this.host = credentials.host;
    this.baseUrl = "https://" + this.host + "/api.asp?";
    that = this;
    console.log(this.baseUrl);
    console.log(this.host);
    attempt = request.get(this.baseUrl + "cmd=logon&email=" + credentials.username + "&password=" + credentials.password);
    return xmlParse(attempt, function(err, data) {
      var response;
      if (err != null) {
        logger.error("Login attempt connection failure");
        return false;
      } else {
        response = data.response;
        if (response.error != null) {
          logger.error("Fogbugz reported an error: " + response.error[0]._);
          return false;
        } else {
          if (response.token != null) {
            that.token = response.token[0];
            that.baseUrl = "https://" + that.host + "/api.asp?token=" + that.token;
            return true;
          } else {
            return false;
          }
        }
      }
    });
  },
  projects: function() {
    logger.info("Getting projects list");
    return this.getRequest("&cmd=listProjects&fIncludeDeleted=1");
  },
  filters: function() {
    logger.info("Getting filters list");
    return this.getRequest("&cmd=listFilters");
  },
  setCurrentFilter: function(filter) {
    logger.info("Set current filter to");
    return this.getRequest("&cmd=listFilters");

    /*
     * hunt for serviceConfig.filter's id
    
    xmlParse filtersXml, (err, obj)->
      if err?
        logger.error "Error trying to parse filters xml" 
        console.log err
      else
        logger.info "Filters xml:"
        console.log JSON.stringify(obj)
    
        filters = obj.response.filters.first().filter
        found = {}
        if filters.length > 0
          
          filters.map (filter)->
            found[filter._] = filter.$.sFilter
    
          if Object.keys(found).any serviceConfig.filter
    
            logger.info "Filter: #{serviceConfig.filter} Id is #{found[serviceConfig.filter]}"
            request.get("#{baseUrl}&cmd=setCurrentFilter&sFilter=#{found[serviceConfig.filter]}")
            output.toRaw "#{data_dir}/cases.xml", request.get("#{baseUrl}&cmd=search&cols=#{attributes.cases.join(',')}") 
    
          else
            logger.warn "Filter named #{serviceConfig.filter} in config file not found. Skipping case extraction."
     */
  },
  areas: function() {
    logger.info("Getting areas");
    return this.getRequest("&cmd=listAreas");
  },
  categories: function() {
    logger.info("Getting categories");
    return this.getRequest("&cmd=listCategories");
  },
  people: function() {
    logger.info("Getting people");
    return this.getRequest("&cmd=listPeople&fIncludeDeleted=1&fIncludeCommunity=1&fIncludeVirtual=1");
  },
  statuses: function() {
    logger.info("Getting categories");
    return this.getRequest("&cmd=listStatuses");
  },
  fixFors: function() {
    logger.info("Getting fix fors");
    return this.getRequest("&cmd=listFixFors&fIncludeDeleted=1&fIncludeReallyDeleted=1");
  },
  mailboxes: function() {
    logger.info("Getting mailboxes");
    return this.getRequest("&cmd=listMailboxes");
  },
  wikis: function() {
    logger.info("Getting wikis");
    return this.getRequest("&cmd=listWikis");
  },
  snippets: function() {
    logger.info("Getting snippets");
    return this.getRequest("&cmd=listSnippets");
  }
};
