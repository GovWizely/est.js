---
---

$ = jQuery

$.fn.setupEST = (options) ->
  this.each ->
    new window.EST.Toolkit(this, options)
