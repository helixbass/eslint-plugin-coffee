CoffeeScript = require 'coffeescript'

{getParser} = require './parser'

exports.parseForESLint = getParser (code, opts) -> CoffeeScript.babylon code, {...opts, withTokens: yes}
