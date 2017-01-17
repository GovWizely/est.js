---
---

$ = jQuery

window.EST ?= {}

class window.EST.Toolkit
  @DEFAULT_EASING = 300

  constructor: (element, @options) ->
    template = """{% include_relative templates/main.html %}"""
    $(element).append template
    filterTypes = ['issue', 'regulation', 'solution', 'provider']
    @filters = (new window.EST.Filter(this, filterType, @options) for filterType in filterTypes)
    this.setup()

  setup: ->
    this.setupOnStateChange()
    this.setupOnReset()
    this.loadPage()

  setupOnStateChange: ->
    toolkit = this
    History.Adapter.bind window, 'statechange', ->
      state = History.getState()
      if state.id != toolkit.stateId
        toolkit.stateId = state.id
        toolkit.loadPage()

  setupOnReset: ->
    toolkit = this
    $('#estReset').on 'click', (e) ->
      e.preventDefault()
      filter.setSelectedId({}) for filter in toolkit.filters
      paramString = $.param {id: (new Date()).getTime()}
      History.pushState null, 'Environmental Solutions Toolkit', "?#{paramString}"

  pushNextPage: ->
    selectedParams = this.getSelectedFilters()
    paramString = $.param selectedParams
    History.pushState null, 'Environmental Solutions Toolkit', "?#{paramString}"

  loadPage: ->
    urlParams = this.paramStringToObject()
    onShowResults = true unless $.isEmptyObject urlParams
    filter.setSelectedId(urlParams) for filter in @filters
    this.loadFilterData onShowResults

  paramStringToObject: ->
    paramStrings = window.location.search.substr(1).split('&')
    currentParams = {}
    validKeys = ['issue_ids', 'regulation_ids', 'solution_ids', 'provider_ids']

    for paramString in paramStrings
      keyValuePair = paramString.split '='
      continue unless keyValuePair[0] in validKeys
      currentParams[keyValuePair[0]] = keyValuePair[1] if keyValuePair[1]?

    currentParams

  loadFilterData: (onShowResults) ->
    this.disable()
    currentParams = @getSelectedFilters()
    toolkit = this

    $.when (filter.loadData(currentParams) for filter in @filters)...
    .done ->
      if onShowResults
        toolkit.showResults()
      else
        $('#estResults').hide
          duration: toolkit.constructor.DEFAULT_EASING,
          done: ->
            $(this).empty()
            toolkit.enable()

  disable: ->
    filter.disable() for filter in @filters
    $('#estReset').prop('disabled', true)

  getSelectedFilters: ->
    selectedFilters = {}
    for filter in @filters
      $.extend selectedFilters, filter.getSelectedObject()
    selectedFilters

  enable: ->
    $('#estReset').prop('disabled', false)
    filter.enable() for filter in @filters

  showResults: ->
    providerIds = (provider.provider_id for provider in @filters[3].getSelectedResults()).toString()
    solutionIds = (solution.solution_id for solution in @filters[2].getSelectedResults()).toString()
    toolkit = this
    this.loadProviderSolutionUrls
      provider_ids: providerIds,
      solution_ids: solutionIds,
      (providerSolutionUrls) ->
        toolkit.renderResults providerSolutionUrls
        toolkit.enable()

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
    html = Mustache.render resultsTemplate,
      results
    $('#estResults').html(html).show(@constructor.DEFAULT_EASING)

  buildSolutionResults: (providerSolutionUrls) ->
    urlsByProviderId = {}
    for providerSolutionUrl in providerSolutionUrls
      urlsByProviderId[providerSolutionUrl.solution_id] ||= []
      urlsByProviderId[providerSolutionUrl.solution_id].push
        provider_name: providerSolutionUrl.provider_name,
        url: providerSolutionUrl.url

    for solution in @filters[2].getSelectedResults()
      name: solution.name, urls: urlsByProviderId[solution.solution_id]
