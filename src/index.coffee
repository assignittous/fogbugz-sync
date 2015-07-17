# fogbugz

###

Fogbugz uses an XML API, which means it needs some special handling compared to most APIs, which use JSON.

###

'use strict'

logger = require('knodeo-logger').Logger
request = require("knodeo-http-sync").httpSync
xmlParse = require('xml2js').parseString


exports.fogbugz = {

  token: null
  host: null
  raw: true

  attributes: 
    cases: [
      "ixBug"
      "ixBugParent"
      "ixBugChildren"
      "ixProject"
      "fOpen"
      "sProject"
      "ixArea"
      "sArea"
      "sTitle"
      "sStatus"
      "ixPersonAssignedTo"
      "sPersonAssignedTo"
      "sEmailAssignedTo"
      "ixPersonOpenedBy"
      "ixPersonResolvedBy"
      "ixPersonClosedBy"
      "ixPersonLastEditedBy"
      "ixStatus"
      "ixBugDuplicates"
      "ixBugOriginal"
      "sStatus"
      "ixPriority"
      "sPriority"
      "ixFixFor"
      "sFixFor"
      "dtFixFor"
      "sVersion"
      "sComputer"
      "hrsOrigEst"
      "hrsCurrEst"
      "hrsElapsed"
      "c"
      "sCategory"
      "dtOpened"
      "dtResolved"
      "dtClosed"
      "ixBugEventLatest"
      "dtLastUpdated"
      "dtDue"
      "dtLastView"
      "ixRelatedBugs"
      "dtLastOccurrence"
    ]

  objectify: (xml)->
    # convert xml to nice json object
    return {}

   
  getRequest: (suffix)->
    if @token?
      console.log "#{@baseUrl}#{suffix}"
      return request.get("#{@baseUrl}#{suffix}")
    else
      logger.error "Not logged in"
      return false

  logout: ()->
    logoutXml = request.get "#{@baseUrl}cmd=logoff&token=#{@token}"
    # todo: add some handling here
    @token = null
    return true

  login: (credentials)->
    @host = credentials.host
    @baseUrl =  "https://#{@host}/api.asp?"
    that = @
    console.log @baseUrl
    console.log @host
    
    attempt = request.get "#{@baseUrl}cmd=logon&email=#{credentials.username}&password=#{credentials.password}"

    xmlParse attempt, (err, data)->
      if err?
        logger.error "Login attempt connection failure"
        return false
      else
        response = data.response
        if response.error?
          logger.error "Fogbugz reported an error: #{response.error[0]._}"
          return false
        else
          if response.token?
            that.token = response.token[0]
            that.baseUrl =  "https://#{that.host}/api.asp?token=#{that.token}"
            #logger.info "Logged in to Fogbugz as #{serviceConfig.username}"
            #logger.info "Token #{token}"
            return true
          else
            return false
            #baseUrl += "token=#{token}"


            # List projects
        # projectsXml = 


  projects: () ->
    logger.info "Getting projects list"
    return @getRequest("&cmd=listProjects&fIncludeDeleted=1")

  filters: ()->
    logger.info "Getting filters list"
    return @getRequest("&cmd=listFilters")

  setCurrentFilter: (filter)->
    logger.info "Set current filter to"
    return @getRequest("&cmd=listFilters")



    ###
    # hunt for serviceConfig.filter's id

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
    ###


  areas: ()->
    logger.info "Getting areas"
    return @getRequest("&cmd=listAreas")

  categories: ()->
    logger.info "Getting categories"
    return @getRequest("&cmd=listCategories")

  people: ()->
    # This appears to be useless, even when loggin in as the account owner, doesn't produce any recrods
    logger.info "Getting people"
    return @getRequest("&cmd=listPeople&fIncludeDeleted=1&fIncludeCommunity=1&fIncludeVirtual=1")

  statuses: ()->
    logger.info "Getting categories"
    return @getRequest("&cmd=listStatuses")

  fixFors: ()->
    logger.info "Getting fix fors"
    return @getRequest("&cmd=listFixFors&fIncludeDeleted=1&fIncludeReallyDeleted=1")
   
  mailboxes: ()->
    logger.info "Getting mailboxes"
    return @getRequest("&cmd=listMailboxes")

  wikis: ()->
    logger.info "Getting wikis"
    return @getRequest("&cmd=listWikis")

  snippets: ()->
    logger.info "Getting snippets"
    return @getRequest("&cmd=listSnippets")

}

