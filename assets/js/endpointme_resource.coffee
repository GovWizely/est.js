---
---

$ = jQuery

window.EST ?= {}

class window.EST.EndpointmeResource
  @DEFAULT_SIZE: 100

  constructor: (options) ->
    @endpointUrl = "#{options.scheme}://#{options.host}#{options.path}"
    @accessToken = options.accessToken
    @defaultParams =
      size: @constructor.DEFAULT_SIZE

  findAll: (params, success) ->
    searchResults = []
    this.doSearch params, searchResults, success

  doSearch: (params, searchResults, doneCallback, deferred = $.Deferred(), offset = 0) ->
    searchParams = $.extend {}, @defaultParams, params, offset: offset
    paramString = $.param searchParams
    url = "#{@endpointUrl}?#{paramString}"

    resource = this

    $.ajax
      contentType: 'text/plain',
      context: this,
      type: 'GET',
      url: url,
      headers: { "Authorization": 'Bearer ' + @accessToken },
      xhrFields:
        withCredentials: false
    .done (data) ->
      searchResults.push data.results...
      if data.results.length == resource.constructor.DEFAULT_SIZE && data.total > searchResults.length
        offset += resource.constructor.DEFAULT_SIZE
        resource.doSearch params, searchResults, doneCallback, deferred, offset
      else
        doneCallback searchResults
        deferred.resolve()

    deferred
