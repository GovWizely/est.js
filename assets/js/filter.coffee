---
---

$ = jQuery

window.EST ?= {}

class window.EST.Filter
  @KEYS = ['issue_ids', 'regulation_ids', 'solution_ids', 'provider_ids']

  constructor: (@toolkit, @filterType, @options) ->
#    @defaultOptionText = if @filterType == 'issue' then 'Select an issue' else "Select a #{@filterType}"
    @defaultOptionText = 'Select an option'
    @selector = "##{@filterType}sSelect"
    @parameterKey = "#{@filterType}_ids"
    @$this = $(@selector)
    @$countSpan = @$this.prev('label').children('span')
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
      toolkit.pushNextPage()

  saveSelected: ->
    value = $("#{@selector} option:selected").val()
    if value then @$this.data('selectedId', value) else @$this.removeData('selectedId')

  getSelectedObject: ->
    selectedObject = {}
    selectedId = @getSelectedId()
    selectedObject[@parameterKey] = selectedId if selectedId?
    selectedObject

  getSelectedId: ->
    data = @$this.data() || {}
    data.selectedId

  setSelectedId: (currentParams) ->
    selectedId = currentParams[@parameterKey]
    if selectedId then @$this.data('selectedId', selectedId) else @$this.removeData('selectedId')

  loadData: (currentParams) ->
    endpointmeConfig = $.extend {}, @options, path: "/v1/est_#{@filterType}s/search"
    resource = new window.EST.EndpointmeResource endpointmeConfig

    filter = this
    resource.findAll this.buildEndpointmeParams(currentParams), (searchResults) ->
      filter.results = searchResults
      filter.renderOptionTags searchResults
      filter.updateCount searchResults.length

  buildEndpointmeParams: (currentParams) ->
    filterParams = if (@filterType != 'provider') then { lang: 'en' } else {}
    for key in @filterKeys
      value = currentParams[key]
      filterParams[key] = value if value?
    filterParams

  updateCount: (count) ->
    @$countSpan.text "(#{count})"

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
