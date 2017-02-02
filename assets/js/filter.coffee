---
---

$ = jQuery

window.EST ?= {}

class window.EST.Filter
  @KEYS = ['issue_ids', 'regulation_ids', 'solution_ids', 'provider_ids']

  constructor: (@toolkit, @filterType, @options) ->
    @defaultOptionText = 'Select an option'
    @selector = "##{@filterType}sSelect"
    @parameterKey = "#{@filterType}_ids"
    @$this = $(@selector)
    @filterKeys = this.detectFilterKeys()
    this.setupOnChange()

  detectFilterKeys: ->
    parameterKeys = []
    for key in @constructor.KEYS
      parameterKeys.push key unless key == @parameterKey
    parameterKeys

  setupOnChange: ->
    filter = this
    toolkit = @toolkit
    @$this.on 'change', ->
      filter.saveSelected()
      filter.selectedParamsString = $.param toolkit.getSelectedFilters()
      toolkit.loadFilterData false

  saveSelected: ->
    value = $("#{@selector} option:selected").val()
    if value then @$this.data('selectedId', value) else @$this.removeData('selectedId')

  getSelectedObject: ->
    selectedObject = {}
    selectedId = this.getSelectedId()
    selectedObject[@parameterKey] = selectedId if selectedId?
    selectedObject

  getSelectedId: ->
    data = @$this.data() || {}
    data.selectedId

  setSelectedId: (currentParams) ->
    selectedId = currentParams[@parameterKey]
    if selectedId then @$this.data('selectedId', selectedId) else @$this.removeData('selectedId')

  loadData: (params) ->
    paramsString = $.param params
    if @selectedParamsString == paramsString
      deferred = $.Deferred()
      deferred.resolve()
      return deferred
    else
      @selectedParamsString = paramsString

    this.showLoading()
    endpointmeConfig = $.extend {}, @options, path: "/v1/est_#{@filterType}s/search"
    resource = new window.EST.EndpointmeResource endpointmeConfig

    filter = this
    resource.findAll this.buildEndpointmeParams(params), (searchResults) ->
      filter.results = searchResults
      filter.renderOptionTags searchResults

  showLoading: ->
    @$this.html $('<option />', text: 'Loading ...', val: '')

  buildEndpointmeParams: (currentParams) ->
    filterParams = if (@filterType != 'provider') then { lang: 'en' } else {}
    for key in @filterKeys
      value = currentParams[key]
      filterParams[key] = value if value?
    filterParams

  renderOptionTags: (results) ->
    selectedId = this.getSelectedId()
    key = "#{@filterType}_id"

    @$this.empty()
    @$this.append $('<option />', text: @defaultOptionText, val: '') unless results.length <= 1

    for result in results
      $option = $('<option />', text: result.name, data: result, val: result[key])
      $option.attr('selected', 'selected') if results.length == 1 or (result[key]? && selectedId == result[key])
      @$this.append $option

  disable: ->
    @$this.prop('disabled', true)

  enable: ->
    @$this.prop('disabled', false)

  getSelectedResults: ->
    selectedId = this.getSelectedId()
    selectedResults = []
    if selectedId?
      idKey = "#{@filterType}_id"
      for result in @results
        selectedResults.push(result) if result[idKey] == selectedId
    else
      selectedResults = @results
    selectedResults
