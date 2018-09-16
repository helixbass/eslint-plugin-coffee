###*
# @fileoverview HTML special characters should be escaped.
# @author Patrick Hayes
###
'use strict'

docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'
jsxUtil = require '../util/react/jsx'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------

# NOTE: '<' and '{' are also problematic characters, but they do not need
# to be included here because it is a syntax error when these characters are
# included accidentally.
DEFAULTS = ['>', '"', "'", '}']

module.exports =
  meta:
    docs:
      description:
        'Detect unescaped HTML entities, which might represent malformed tags'
      category: 'Possible Errors'
      recommended: yes
      url: docsUrl 'no-unescaped-entities'
    schema: [
      type: 'object'
      properties:
        forbid:
          type: 'array'
          items:
            type: 'string'
      additionalProperties: no
    ]

  create: (context) ->
    reportInvalidEntity = (node) ->
      configuration = context.options[0] or {}
      entities = configuration.forbid or DEFAULTS

      # HTML entites are already escaped in node.value (as well as node.raw),
      # so pull the raw text from context.getSourceCode()
      for i in [node.loc.start.line..node.loc.end.line]
        rawLine = context.getSourceCode().lines[i - 1]
        start = 0
        end = rawLine.length
        if i is node.loc.start.line then start = node.loc.start.column
        if i is node.loc.end.line then end = node.loc.end.column
        rawLine = rawLine.substring start, end
        for entity in entities
          for c, index in rawLine
            if c is entity
              context.report {
                loc: line: i, column: start + index
                message: 'HTML entities must be escaped.'
                node
              }

    'Literal, JSXText': (node) ->
      if jsxUtil.isJSX node.parent then reportInvalidEntity node
