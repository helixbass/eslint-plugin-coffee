### eslint-disable no-underscore-dangle ###

axe = require 'axe-core'

exports.axeFailMessage = (checkId, data) ->
  axe._audit.data.checks[checkId].messages.fail data
