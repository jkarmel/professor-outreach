jsdom = require 'jsdom'
request = require 'request'
_ = require 'underscore'
cheerio = require 'cheerio'
async = require 'async'
fs = require 'fs'

psychiatryDepartments = require './department-names'
HMS_BASE_URL = "http://hms.harvard.edu"
HMS_SEARCH_URL_BASE = HMS_BASE_URL + "/faculty-search?view_all=1&Department="

facultyListings = []
fns = []
for department in psychiatryDepartments
  do (department) ->
    fns.push (done) ->
      request HMS_SEARCH_URL_BASE + escape(department), (err, response, body) ->
        $ = cheerio.load(body)
        $('.results-line a').each (i, a) ->
          facultyListings.push HMS_BASE_URL + a.attribs.href
        done()
            # emailImg = $$('.hms-people-search-alumni-results-body img')
            # console.log name, emailImg

results = []
num = 0
async.series fns, (err) ->
  console.log "#{facultyListings.length} listings found"
  fns = []
  for listing in facultyListings
    do (listing) ->
      fns.push (done) ->
        request listing, (err, response, body) ->
          $ = cheerio.load body
          console.log "#{++num} of #{facultyListings.length}"
          results.push $('.hms-people-search-alumni-results-body').html()
          fs.writeFile 'results', JSON.stringify(results), ->
            done()

  async.series fns, (err) ->
    fs.writeFile 'results', JSON.stringify(results)
    console.log 'all done'