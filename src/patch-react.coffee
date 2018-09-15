Components = require './util/react/Components'

module.exports = ->
  console.log 'monkeypatching'
  try
    ReactComponents = require 'eslint-plugin-react/lib/util/Components'
  catch
    return
  console.log {ReactComponents}
  return if ReactComponents.__monkeypatched
  console.log det: Components.detect
  ReactComponents.detect = Components.detect
  ReactComponents.__monkeypatched = yes
