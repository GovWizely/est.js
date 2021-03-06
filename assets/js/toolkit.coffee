---
---

$ = jQuery

window.EST ?= {}

class window.EST.Toolkit
  @DEFAULT_EASING = 300

  constructor: (element, @options) ->
    @pathname = window.location.pathname
    html = """{% include_relative templates/main.html %}"""
    element.innerHTML = html
    filterTypes = ['issue', 'regulation', 'solution', 'provider']
    @filters = (new window.EST.Filter(this, filterType, @options) for filterType in filterTypes)
    this.setup()

  setup: ->
    this.setupOnStateChange()
    this.setupOnShowResults()
    this.setupOnReset()
    this.loadPage false

  setupOnStateChange: ->
    toolkit = this
    History.Adapter.bind window, 'statechange', ->
      state = History.getState()
      if state.id != toolkit.stateId
        toolkit.stateId = state.id
        toolkit.loadPage()

  setupOnShowResults: ->
    toolkit = this
    $('#estShowResults').on 'click', (e) ->
      e.preventDefault()
      toolkit.pushNextPage()

  setupOnReset: ->
    toolkit = this
    $('#estReset').on 'click', (e) ->
      e.preventDefault()
      toolkit.reset()

  reset: ->
    this.disable()
    filter.setSelectedId({}) for filter in this.filters
    this.pushNextPage {}

  pushNextPage: (selectedParams) ->
    selectedParams ?= this.getSelectedFilters()
    if $.isEmptyObject selectedParams
      paramString = $.param { id: (new Date()).getTime() }
    else
      paramString = $.param selectedParams

    nextPath = "#{@pathname}?#{paramString}"

    History.pushState null, 'Environmental Solutions Toolkit', nextPath

  loadPage: (isScrollEnabled = true) ->
    urlParams = this.paramStringToObject()
    onShowResults = true unless $.isEmptyObject urlParams
    filter.setSelectedId(urlParams) for filter in this.filters
    if onShowResults
      toolkit = this
      this.showLoadingResults isScrollEnabled, ->
        toolkit.loadFilterData onShowResults, isScrollEnabled
    else
      this.loadFilterData onShowResults, isScrollEnabled

  showLoadingResults: (isScrollEnabled = true, complete) ->
    @loadingResultsHtml ?= """{% include_relative templates/loading_results.html %}"""
    document.getElementById('estResults').innerHTML = @loadingResultsHtml
    if isScrollEnabled
      this.scrollToResults complete
    else
      complete.call()

  scrollToForm: (complete) ->
    $('body').animate
      scrollTop: $('#estForm').offset().top,
      { complete: complete }

  scrollToResults: (complete) ->
    $('body').animate
      scrollTop: $('#estResults').offset().top,
      { complete: complete }

  paramStringToObject: ->
    paramStrings = window.location.search.substr(1).split('&')
    currentParams = {}
    validKeys = ['issue_ids', 'regulation_ids', 'solution_ids', 'provider_ids']

    for paramString in paramStrings
      keyValuePair = paramString.split '='
      continue unless keyValuePair[0] in validKeys
      currentParams[keyValuePair[0]] = keyValuePair[1] if keyValuePair[1]?

    currentParams

  loadFilterData: (onShowResults, isScrollEnabled = true) ->
    this.disable()
    currentParams = this.getSelectedFilters()
    toolkit = this

    $.when (filter.loadData(currentParams) for filter in @filters)...
    .done ->
      if onShowResults
        toolkit.showResults()
        toolkit.loadComplete()
        toolkit.enable true
        toolkit.scrollToResults() if isScrollEnabled
      else
        document.getElementById('estResults').innerHTML = ''
        toolkit.loadComplete()
        if isScrollEnabled
          toolkit.scrollToForm ->
            toolkit.enable()
        else
          toolkit.enable()

  disable: ->
    filter.disable() for filter in @filters
    $('#estShowResults, #estReset').prop('disabled', true)

  getSelectedFilters: ->
    selectedFilters = {}
    for filter in @filters
      $.extend selectedFilters, filter.getSelectedObject()
    selectedFilters

  enable: (onShowResults = false) ->
    filter.enable() for filter in @filters
    if $.isEmptyObject this.getSelectedFilters()
      $('#estReset, #estShowResults').prop('disabled', true)
    else if onShowResults
      $('#estReset').prop('disabled', false)
    else
      $('#estReset, #estShowResults').prop('disabled', false)

  showResults: ->
    providerIds = (provider.provider_id for provider in @filters[3].getSelectedResults()).toString()
    solutionIds = (solution.solution_id for solution in @filters[2].getSelectedResults()).toString()
    toolkit = this
    this.loadProviderSolutionUrls
      provider_ids: providerIds,
      solution_ids: solutionIds,
      (providerSolutionUrls) ->
        toolkit.renderResults providerSolutionUrls

  loadProviderSolutionUrls: (params, doneCallback) ->
    toolkit = this
    endpointmeConfig = $.extend {}, @options, path: '/v1/est_provider_solution_urls/search'
    resource = new window.EST.EndpointmeResource endpointmeConfig
    resource.findAll params, doneCallback

  renderResults: (providerSolutionUrls) ->
    results =
      issues: @filters[0].getSelectedResults(),
      regulations: @filters[1].getSelectedResults(),
      solutions: this.buildSolutionResults(providerSolutionUrls)

    resultsTemplate = """{% include_relative templates/results.html %}"""
    html = Mustache.render resultsTemplate, results
    document.getElementById('estResults').innerHTML = html

  buildSolutionResults: (providerSolutionUrls) ->
    urlsByProviderId = {}
    for providerSolutionUrl in providerSolutionUrls
      urlsByProviderId[providerSolutionUrl.solution_id] ||= []
      urlsByProviderId[providerSolutionUrl.solution_id].push
        provider_name: providerSolutionUrl.provider_name,
        url: providerSolutionUrl.url

    for solution in @filters[2].getSelectedResults()
      name: solution.name, urls: urlsByProviderId[solution.solution_id]

  loadComplete: ->
    $('#estProgressWrapper').hide()
    $('#estDisclaimer, #estFormWrapper, #estResults').show()
