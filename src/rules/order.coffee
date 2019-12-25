'use strict'

minimatch = require 'minimatch'
{default: importType} = require 'eslint-plugin-import/lib/core/importType'
{
  default: isStaticRequire
} = require 'eslint-plugin-import/lib/core/staticRequire'
{default: docsUrl} = require 'eslint-plugin-import/lib/docsUrl'

defaultGroups = ['builtin', 'external', 'parent', 'sibling', 'index']

# REPORTING AND FIXING

reverse = (array) ->
  array
  .map (v) ->
    name: v.name
    rank: -v.rank
    node: v.node
  .reverse()

getTokensOrCommentsAfter = (sourceCode, node, count) ->
  currentNodeOrToken = node
  result = []
  i = 0
  while i < count
    currentNodeOrToken = sourceCode.getTokenOrCommentAfter currentNodeOrToken
    break unless currentNodeOrToken?
    result.push currentNodeOrToken
    i++
  result

getTokensOrCommentsBefore = (sourceCode, node, count) ->
  currentNodeOrToken = node
  result = []
  i = 0
  while i < count
    currentNodeOrToken = sourceCode.getTokenOrCommentBefore currentNodeOrToken
    break unless currentNodeOrToken?
    result.push currentNodeOrToken
    i++
  result.reverse()

takeTokensAfterWhile = (sourceCode, node, condition) ->
  tokens = getTokensOrCommentsAfter sourceCode, node, 100
  result = []
  i = 0
  while i < tokens.length
    if condition tokens[i] then result.push tokens[i] else break
    i++
  result

takeTokensBeforeWhile = (sourceCode, node, condition) ->
  tokens = getTokensOrCommentsBefore sourceCode, node, 100
  result = []
  i = tokens.length - 1
  while i >= 0
    if condition tokens[i] then result.push tokens[i] else break
    i--
  result.reverse()

findOutOfOrder = (imported) ->
  return [] if imported.length is 0
  maxSeenRankNode = imported[0]
  imported.filter (importedModule) ->
    res = importedModule.rank < maxSeenRankNode.rank
    if maxSeenRankNode.rank < importedModule.rank
      maxSeenRankNode ###:### = importedModule
    res

findRootNode = (node) ->
  parent = node
  while parent.parent? and not parent.parent.body?
    {parent} = parent
  parent

findEndOfLineWithComments = (sourceCode, node) ->
  tokensToEndOfLine = takeTokensAfterWhile(
    sourceCode
    node
    commentOnSameLineAs node
  )
  endOfTokens =
    if tokensToEndOfLine.length > 0
      tokensToEndOfLine[tokensToEndOfLine.length - 1].range[1]
    else
      node.range[1]
  result = endOfTokens
  i = endOfTokens
  while i < sourceCode.text.length
    if sourceCode.text[i] is '\n'
      result = i + 1
      break
    if (
      sourceCode.text[i] isnt ' ' and
      sourceCode.text[i] isnt '\t' and
      sourceCode.text[i] isnt '\r'
    )
      break
    result = i + 1
    i++
  result

commentOnSameLineAs = (node) -> (token) ->
  token.type in ['Block', 'Line'] and
  token.loc.start.line is token.loc.end.line and
  token.loc.end.line is node.loc.end.line

findStartOfLineWithComments = (sourceCode, node) ->
  tokensToEndOfLine = takeTokensBeforeWhile(
    sourceCode
    node
    commentOnSameLineAs node
  )
  startOfTokens =
    if tokensToEndOfLine.length > 0
      tokensToEndOfLine[0].range[0]
    else
      node.range[0]
  result = startOfTokens
  i = startOfTokens - 1
  while i > 0
    if sourceCode.text[i] isnt ' ' and sourceCode.text[i] isnt '\t' then break
    result = i
    i--
  result

isPlainRequireModule = (node) ->
  if node.type is 'VariableDeclaration'
    return no unless node.declarations.length is 1
    {id, init} = node.declarations[0]
  else if (
    node.type is 'ExpressionStatement' and
    node.expression?.type is 'AssignmentExpression'
  )
    {left: id, right: init} = node.expression
  else
    return no

  return (
    id?.type in ['Identifier', 'ObjectPattern'] and
    init?.type is 'CallExpression' and
    init.callee?.name is 'require' and
    init.arguments?.length is 1 and
    init.arguments[0].type is 'Literal'
  )

isPlainImportModule = (node) ->
  node.type is 'ImportDeclaration' and node.specifiers?.length > 0

canCrossNodeWhileReorder = (node) ->
  isPlainRequireModule(node) or isPlainImportModule node

canReorderItems = (firstNode, secondNode) ->
  {parent} = firstNode
  [firstIndex, secondIndex] = [
    parent.body.indexOf firstNode
    parent.body.indexOf secondNode
  ].sort()
  nodesBetween = parent.body.slice firstIndex, secondIndex + 1
  for nodeBetween from nodesBetween
    return no unless canCrossNodeWhileReorder nodeBetween
  yes

fixOutOfOrder = (context, firstNode, secondNode, order) ->
  sourceCode = context.getSourceCode()

  firstRoot = findRootNode firstNode.node
  firstRootStart = findStartOfLineWithComments sourceCode, firstRoot
  firstRootEnd = findEndOfLineWithComments sourceCode, firstRoot

  secondRoot = findRootNode secondNode.node
  secondRootStart = findStartOfLineWithComments sourceCode, secondRoot
  secondRootEnd = findEndOfLineWithComments sourceCode, secondRoot
  canFix = canReorderItems firstRoot, secondRoot

  newCode = sourceCode.text.substring secondRootStart, secondRootEnd
  unless newCode[newCode.length - 1] is '\n' then newCode += '\n'

  message = "`#{secondNode.name}` import should occur #{order} import of `#{
    firstNode.name
  }`"

  if order is 'before'
    context.report {
      node: secondNode.node
      message
      fix: canFix and (fixer) ->
        fixer.replaceTextRange(
          [firstRootStart, secondRootEnd]
          newCode + sourceCode.text.substring firstRootStart, secondRootStart
        )
    }
  else if order is 'after'
    context.report {
      node: secondNode.node
      message
      fix: canFix and (fixer) ->
        fixer.replaceTextRange(
          [secondRootStart, firstRootEnd]
          sourceCode.text.substring(secondRootEnd, firstRootEnd) + (
              if /\n\s*$/.test(
                sourceCode.text.substring secondRootEnd, firstRootEnd
              )
                ''
              else
                '\n'
            ) +
            newCode
        )
    }

reportOutOfOrder = (context, imported, outOfOrder, order) ->
  outOfOrder.forEach (imp) ->
    found = imported.find (importedItem) -> importedItem.rank > imp.rank
    fixOutOfOrder context, found, imp, order

makeOutOfOrderReport = (context, imported) ->
  outOfOrder = findOutOfOrder imported
  return unless outOfOrder.length
  # There are things to report. Try to minimize the number of reported errors.
  reversedImported = reverse imported
  reversedOrder = findOutOfOrder reversedImported
  if reversedOrder.length < outOfOrder.length
    reportOutOfOrder context, reversedImported, reversedOrder, 'after'
    return
  reportOutOfOrder context, imported, outOfOrder, 'before'

importsSorterAsc = (importA, importB) ->
  return -1 if importA < importB

  return 1 if importA > importB

  0

importsSorterDesc = (importA, importB) ->
  return 1 if importA < importB

  return -1 if importA > importB

  0

mutateRanksToAlphabetize = (imported, order) ->
  groupedByRanks = imported.reduce(
    (acc, importedItem) ->
      unless Array.isArray acc[importedItem.rank]
        acc[importedItem.rank] = []
      acc[importedItem.rank].push importedItem.name
      acc
  ,
    {}
  )

  groupRanks = Object.keys groupedByRanks

  sorterFn = if order is 'asc' then importsSorterAsc else importsSorterDesc
  # sort imports locally within their group
  groupRanks.forEach (groupRank) -> groupedByRanks[groupRank].sort sorterFn

  # assign globally unique rank to each import
  newRank = 0
  alphabetizedRanks =
    groupRanks
    .sort()
    .reduce(
      (acc, groupRank) ->
        groupedByRanks[groupRank].forEach (importedItemName) ->
          acc[importedItemName] = newRank
          newRank += 1
        acc
    ,
      {}
    )

  # mutate the original group-rank with alphabetized-rank
  imported.forEach (importedItem) ->
    importedItem.rank = alphabetizedRanks[importedItem.name]

# DETECTING

computePathRank = (ranks, pathGroups, path, maxPosition) ->
  i = 0
  l = pathGroups.length
  while i < l
    {pattern, patternOptions, group, position = 1} = pathGroups[i]
    return ranks[group] + position / maxPosition if minimatch(
      path
      pattern
      patternOptions or nocomment: yes
    )
    i++

computeRank = (context, ranks, name, type) ->
  impType = importType name, context
  if impType isnt 'builtin' and impType isnt 'external'
    rank = computePathRank(
      ranks.groups
      ranks.pathGroups
      name
      ranks.maxPosition
    )
  unless rank then rank = ranks.groups[impType]
  unless type is 'import' then rank += 100

  rank

registerNode = (context, node, name, type, ranks, imported) ->
  rank = computeRank context, ranks, name, type
  unless rank is -1 then imported.push {name, rank, node}

isInVariableDeclaratorOrAssignment = (node) ->
  return no unless node
  return yes if node.type is 'VariableDeclarator'
  # return yes if (
  #   node.parent?.type is 'AssignmentExpression' and node is node.parent.right
  # )
  if node.parent?.type is 'AssignmentExpression' and node is node.parent.right
    return yes
  return yes if isInVariableDeclaratorOrAssignment node.parent
  no

types = [
  'builtin'
  'external'
  'internal'
  'unknown'
  'parent'
  'sibling'
  'index'
]

# Creates an object with type-rank pairs.
# Example: { index: 0, sibling: 1, parent: 1, external: 1, builtin: 2, internal: 2 }
# Will throw an error if it contains a type that does not exist, or has a duplicate
convertGroupsToRanks = (groups) ->
  rankObject = groups.reduce(
    (res, group, index) ->
      if typeof group is 'string' then group = [group]
      group.forEach (groupItem) ->
        if types.indexOf(groupItem) is -1
          throw new Error(
            "Incorrect configuration of the rule: Unknown type `#{JSON.stringify(
              groupItem
            )}`"
          )
        unless res[groupItem] is undefined
          throw new Error(
            "Incorrect configuration of the rule: `#{groupItem}` is duplicated"
          )
        res[groupItem] = index
      res
  ,
    {}
  )

  omittedTypes = types.filter (type) -> rankObject[type] is undefined

  omittedTypes.reduce(
    (res, type) ->
      res[type] = groups.length
      res
  ,
    rankObject
  )

convertPathGroupsForRanks = (pathGroups) ->
  after = {}
  before = {}

  transformed = pathGroups.map (pathGroup, index) ->
    {group, position: positionString} = pathGroup
    position = 0
    if positionString is 'after'
      unless after[group] then after[group] = 1
      position = after[group]++
    else if positionString is 'before'
      unless before[group] then before[group] = []
      before[group].push index

    Object.assign {}, pathGroup, {position}

  maxPosition = 1

  Object.keys(before).forEach (group) ->
    groupLength = before[group].length
    before[group].forEach (groupIndex, index) ->
      transformed[groupIndex].position = -1 * (groupLength - index)
    maxPosition ###:### = Math.max maxPosition, groupLength

  Object.keys(after).forEach (key) ->
    groupNextPosition = after[key]
    maxPosition ###:### = Math.max maxPosition, groupNextPosition - 1

  pathGroups: transformed
  maxPosition:
    if maxPosition > 10
      Math.pow 10, Math.ceil Math.log10 maxPosition
    else
      10

fixNewLineAfterImport = (context, previousImport) ->
  prevRoot = findRootNode previousImport.node
  tokensToEndOfLine = takeTokensAfterWhile(
    context.getSourceCode()
    prevRoot
    commentOnSameLineAs prevRoot
  )

  endOfLine = prevRoot.range[1]
  if tokensToEndOfLine.length > 0
    endOfLine = tokensToEndOfLine[tokensToEndOfLine.length - 1].range[1]
  (fixer) -> fixer.insertTextAfterRange [prevRoot.range[0], endOfLine], '\n'

removeNewLineAfterImport = (context, currentImport, previousImport) ->
  sourceCode = context.getSourceCode()
  prevRoot = findRootNode previousImport.node
  currRoot = findRootNode currentImport.node
  rangeToRemove = [
    findEndOfLineWithComments sourceCode, prevRoot
    findStartOfLineWithComments sourceCode, currRoot
  ]
  if /^\s*$/.test sourceCode.text.substring rangeToRemove[0], rangeToRemove[1]
    return (fixer) ->
      fixer.removeRange rangeToRemove
  undefined

makeNewlinesBetweenReport = (context, imported, newlinesBetweenImports) ->
  getNumberOfEmptyLinesBetween = (currentImport, previousImport) ->
    linesBetweenImports =
      context
      .getSourceCode()
      .lines.slice(
        previousImport.node.loc.end.line
        currentImport.node.loc.start.line - 1
      )

    linesBetweenImports.filter((line) -> not line.trim().length).length
  previousImport = imported[0]

  imported
  .slice 1
  .forEach (currentImport) ->
    emptyLinesBetween = getNumberOfEmptyLinesBetween(
      currentImport
      previousImport
    )

    if newlinesBetweenImports in ['always', 'always-and-inside-groups']
      if currentImport.rank isnt previousImport.rank and emptyLinesBetween is 0
        context.report
          node: previousImport.node
          message:
            'There should be at least one empty line between import groups'
          fix: fixNewLineAfterImport context, previousImport
      else if (
        currentImport.rank is previousImport.rank and
        emptyLinesBetween > 0 and
        newlinesBetweenImports isnt 'always-and-inside-groups'
      )
        context.report
          node: previousImport.node
          message: 'There should be no empty line within import group'
          fix: removeNewLineAfterImport context, currentImport, previousImport
    else if emptyLinesBetween > 0
      context.report
        node: previousImport.node
        message: 'There should be no empty line between import groups'
        fix: removeNewLineAfterImport context, currentImport, previousImport

    previousImport ###:### = currentImport

getAlphabetizeConfig = (options) ->
  alphabetize = options.alphabetize or {}
  order = alphabetize.order or 'ignore'

  {order}

module.exports =
  meta:
    type: 'suggestion'
    docs:
      url: docsUrl 'order'

    fixable: 'code'
    schema: [
      type: 'object'
      properties:
        groups:
          type: 'array'
        pathGroups:
          type: 'array'
          items:
            type: 'object'
            properties:
              pattern:
                type: 'string'
              patternOptions:
                type: 'object'
              group:
                type: 'string'
                enum: types
              position:
                type: 'string'
                enum: ['after', 'before']
            required: ['pattern', 'group']
        'newlines-between':
          enum: ['ignore', 'always', 'always-and-inside-groups', 'never']
        alphabetize:
          type: 'object'
          properties:
            order:
              enum: ['ignore', 'asc', 'desc']
              default: 'ignore'
          additionalProperties: no
      additionalProperties: no
    ]

  create: (context) ->
    options = context.options[0] or {}
    newlinesBetweenImports = options['newlines-between'] or 'ignore'
    alphabetize = getAlphabetizeConfig options
    try
      {
        pathGroups
        maxPosition
      } = convertPathGroupsForRanks options.pathGroups or []
      ranks = {
        groups: convertGroupsToRanks options.groups or defaultGroups
        pathGroups
        maxPosition
      }
    catch error
      # Malformed configuration
      return
        Program: (node) -> context.report node, error.message
    imported = []
    level = 0

    incrementLevel = -> level++
    decrementLevel = -> level--

    ImportDeclaration: (node) ->
      if node.specifiers.length
        # Ignoring unassigned imports
        name = node.source.value
        registerNode context, node, name, 'import', ranks, imported
    CallExpression: (node) ->
      return unless (
        level is 0 and
        isStaticRequire(node) and
        isInVariableDeclaratorOrAssignment node
      )
      name = node.arguments[0].value
      registerNode context, node, name, 'require', ranks, imported
    'Program:exit': ->
      unless newlinesBetweenImports is 'ignore'
        makeNewlinesBetweenReport context, imported, newlinesBetweenImports

      unless alphabetize.order is 'ignore'
        mutateRanksToAlphabetize imported, alphabetize.order

      makeOutOfOrderReport context, imported

      imported ###:### = []
    FunctionDeclaration: incrementLevel
    FunctionExpression: incrementLevel
    ArrowFunctionExpression: incrementLevel
    BlockStatement: incrementLevel
    ObjectExpression: incrementLevel
    'FunctionDeclaration:exit': decrementLevel
    'FunctionExpression:exit': decrementLevel
    'ArrowFunctionExpression:exit': decrementLevel
    'BlockStatement:exit': decrementLevel
    'ObjectExpression:exit': decrementLevel
