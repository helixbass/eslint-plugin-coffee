###*
# @fileoverview Validate closing bracket location in JSX
# @author Yannick Croissant
###
'use strict'

{has} = require 'lodash'
docsUrl = require 'eslint-plugin-react/lib/util/docsUrl'

# ------------------------------------------------------------------------------
# Rule Definition
# ------------------------------------------------------------------------------
module.exports =
  meta:
    docs:
      description: 'Validate closing bracket location in JSX'
      category: 'Stylistic Issues'
      recommended: no
      url: docsUrl 'jsx-closing-bracket-location'
    fixable: 'code'

    schema: [
      oneOf: [
        enum: [
          'after-props'
          'props-aligned'
          # 'tag-aligned'
          'line-aligned'
        ]
      ,
        type: 'object'
        properties:
          location:
            enum: [
              'after-props'
              'props-aligned'
              # 'tag-aligned'
              'line-aligned'
            ]
        additionalProperties: no
      ,
        type: 'object'
        properties:
          nonEmpty:
            enum: [
              'after-props'
              'props-aligned'
              # 'tag-aligned'
              'line-aligned'
              no
            ]
          selfClosing:
            enum: [
              'after-props'
              'props-aligned'
              # 'tag-aligned'
              'line-aligned'
              no
            ]
        additionalProperties: no
      ]
    ]

  create: (context) ->
    MESSAGE = 'The closing bracket must be {{location}}{{details}}'
    MESSAGE_LOCATION =
      'after-props': 'placed after the last prop'
      'after-tag': 'placed after the opening tag'
      'props-aligned': 'aligned with the last prop'
      # 'tag-aligned': 'aligned with the opening tag'
      'line-aligned': 'aligned with the line containing the opening tag'
    DEFAULT_LOCATION = 'line-aligned'

    sourceCode = context.getSourceCode()
    config = context.options[0]
    options =
      nonEmpty: DEFAULT_LOCATION
      selfClosing: DEFAULT_LOCATION

    if typeof config is 'string'
      # simple shorthand [1, 'something']
      options.nonEmpty = config
      options.selfClosing = config
    else if typeof config is 'object'
      # [1, {location: 'something'}] (back-compat)
      if has config, 'location'
        options.nonEmpty = config.location
        options.selfClosing = config.location
      # [1, {nonEmpty: 'something'}]
      if has config, 'nonEmpty' then options.nonEmpty = config.nonEmpty
      # [1, {selfClosing: 'something'}]
      if has config, 'selfClosing' then options.selfClosing = config.selfClosing

    ###*
    # Get expected location for the closing bracket
    # @param {Object} tokens Locations of the opening bracket, closing bracket and last prop
    # @return {String} Expected location for the closing bracket
    ###
    getExpectedLocation = (tokens) ->
      requested =
        if tokens.selfClosing
          options.selfClosing
        else
          options.nonEmpty
      # Is always after the opening tag if there is no props
      unless tokens.lastProp?
        'after-tag'
      # Is always after the last prop if this one is on the same line as the opening bracket
      else if tokens.opening.line is tokens.lastProp.lastLine
        'after-props'
      # Aligning with prop that's on opening line can cause indentation error
      else if (
        tokens.opening.line is tokens.lastProp.firstLine and
        requested is 'props-aligned'
      )
        'line-aligned'
      # Else use configuration dependent on selfClosing property
      else
        requested

    ###*
    # Get the correct 0-indexed column for the closing bracket, given the
    # expected location.
    # @param {Object} tokens Locations of the opening bracket, closing bracket and last prop
    # @param {String} expectedLocation Expected location for the closing bracket
    # @return {?Number} The correct column for the closing bracket, or null
    ###
    getCorrectColumn = (tokens, expectedLocation) ->
      switch expectedLocation
        when 'props-aligned'
          return tokens.lastProp.column
        when 'tag-aligned'
          return tokens.opening.column
        when 'line-aligned'
          return tokens.openingStartOfLine.column
        else
          return null

    ###*
    # Check if the closing bracket is correctly located
    # @param {Object} tokens Locations of the opening bracket, closing bracket and last prop
    # @param {String} expectedLocation Expected location for the closing bracket
    # @return {Boolean} True if the closing bracket is correctly located, false if not
    ###
    hasCorrectLocation = (tokens, expectedLocation) ->
      switch expectedLocation
        when 'after-tag'
          return tokens.tag.line is tokens.closing.line
        when 'after-props'
          return tokens.lastProp.lastLine is tokens.closing.line
        when 'props-aligned', 'tag-aligned', 'line-aligned'
          correctColumn = getCorrectColumn tokens, expectedLocation
          return correctColumn is tokens.closing.column
        else
          return yes

    ###*
    # Get the characters used for indentation on the line to be matched
    # @param {Object} tokens Locations of the opening bracket, closing bracket and last prop
    # @param {String} expectedLocation Expected location for the closing bracket
    # @param {Number} correctColumn Expected column for the closing bracket
    # @return {String} The characters used for indentation
    ###
    getIndentation = (tokens, expectedLocation, correctColumn) ->
      spaces = []
      switch expectedLocation
        when 'props-aligned'
          indentation =
            /^\s*/.exec(sourceCode.lines[tokens.lastProp.firstLine - 1])[0]
        when 'tag-aligned', 'line-aligned'
          indentation =
            /^\s*/.exec(sourceCode.lines[tokens.opening.line - 1])[0]
        else
          indentation = ''
      if indentation.length + 1 < correctColumn
        # Non-whitespace characters were included in the column offset
        spaces = new Array +correctColumn + 1 - indentation.length
      indentation + spaces.join ' '

    ###*
    # Get the locations of the opening bracket, closing bracket, last prop, and
    # start of opening line.
    # @param {ASTNode} node The node to check
    # @return {Object} Locations of the opening bracket, closing bracket, last
    # prop and start of opening line.
    ###
    getTokensLocations = (node) ->
      opening = sourceCode.getFirstToken(node).loc.start
      closing =
        sourceCode.getLastTokens(node, if node.selfClosing then 2 else 1)[0].loc
          .start
      tag = sourceCode.getFirstToken(node.name).loc.start
      if node.attributes.length
        lastProp = node.attributes[node.attributes.length - 1]
        lastProp =
          column: sourceCode.getFirstToken(lastProp).loc.start.column
          firstLine: sourceCode.getFirstToken(lastProp).loc.start.line
          lastLine: sourceCode.getLastToken(lastProp).loc.end.line
      openingLine = sourceCode.lines[opening.line - 1]
      openingStartOfLine =
        column: /^\s*/.exec(openingLine)[0].length
        line: opening.line
      {
        tag
        opening
        closing
        lastProp
        selfClosing: node.selfClosing
        openingStartOfLine
      }

    ###*
    # Get an unique ID for a given JSXOpeningElement
    #
    # @param {ASTNode} node The AST node being checked.
    # @returns {String} Unique ID (based on its range)
    ###
    getOpeningElementId = (node) -> node.range.join ':'

    lastAttributeNode = {}

    JSXAttribute: (node) ->
      lastAttributeNode[getOpeningElementId(node.parent)] = node

    JSXSpreadAttribute: (node) ->
      lastAttributeNode[getOpeningElementId(node.parent)] = node

    'JSXOpeningElement:exit': (node) ->
      attributeNode = lastAttributeNode[getOpeningElementId(node)]
      cachedLastAttributeEndPos =
        if attributeNode then attributeNode.range[1] else null
      tokens = getTokensLocations node
      expectedLocation = getExpectedLocation tokens

      return if hasCorrectLocation tokens, expectedLocation

      data = location: MESSAGE_LOCATION[expectedLocation], details: ''
      correctColumn = getCorrectColumn tokens, expectedLocation

      unless correctColumn is null
        expectedNextLine =
          tokens.lastProp and tokens.lastProp.lastLine is tokens.closing.line
        data.details = " (expected column #{correctColumn + 1}#{
          if expectedNextLine then ' on the next line)' else ')'
        }"

      context.report {
        node
        loc: tokens.closing
        message: MESSAGE
        data
        fix: (fixer) ->
          closingTag = if tokens.selfClosing then '/>' else '>'
          switch expectedLocation
            when 'after-tag'
              return fixer.replaceTextRange(
                [cachedLastAttributeEndPos, node.range[1]]
                (if expectedNextLine then '\n' else '') + closingTag
              ) if cachedLastAttributeEndPos
              return fixer.replaceTextRange(
                [node.name.range[1], node.range[1]]
                (if expectedNextLine then '\n' else ' ') + closingTag
              )
            when 'after-props'
              return fixer.replaceTextRange(
                [cachedLastAttributeEndPos, node.range[1]]
                (if expectedNextLine then '\n' else '') + closingTag
              )
            when 'props-aligned', 'tag-aligned', 'line-aligned'
              return fixer.replaceTextRange(
                [cachedLastAttributeEndPos, node.range[1]]
                "\n#{getIndentation(
                  tokens
                  expectedLocation
                  correctColumn
                )}#{closingTag}"
              )
            else
              return yes
      }
