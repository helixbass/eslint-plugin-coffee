vm = require 'vm'
# import docsUrl from '../docsUrl'

module.exports =
  meta:
    docs:
      # url: docsUrl 'dynamic-import-chunkname'
      url: ''
    schema: [
      type: 'object'
      properties:
        importFunctions:
          type: 'array'
          uniqueItems: yes
          items:
            type: 'string'
        webpackChunknameFormat:
          type: 'string'
    ]

  create: (context) ->
    config = context.options[0]
    {importFunctions = []} = config or {}
    {webpackChunknameFormat = '[0-9a-zA-Z-_/.]+'} = config or {}

    paddedCommentRegex = /^ (\S[\s\S]+\S) $/
    commentStyleRegex = /^( \w+: ("[^"]*"|\d+|false|true),?)+ $/
    chunkSubstrFormat = " webpackChunkName: \"#{webpackChunknameFormat}\",? "
    chunkSubstrRegex = new RegExp chunkSubstrFormat

    CallExpression: (node) ->
      return if (
        node.callee.type isnt 'Import' and
        importFunctions.indexOf(node.callee.name) < 0
      )

      sourceCode = context.getSourceCode()
      arg = node.arguments[0]
      leadingComments = sourceCode.getComments(arg).leading

      if not leadingComments or leadingComments.length is 0
        context.report {
          node
          message:
            'dynamic imports require a leading comment with the webpack chunkname'
        }
        return

      isChunknamePresent = no

      for comment from leadingComments
        unless comment.type is 'Block'
          context.report {
            node
            message:
              'dynamic imports require a ### foo ### style comment, not a # foo comment'
          }
          return

        unless paddedCommentRegex.test comment.value
          context.report {
            node
            message:
              'dynamic imports require a block comment padded with spaces - ### foo ###'
          }
          return

        try
          # just like webpack itself does
          vm.runInNewContext "(function(){return {#{comment.value}}})()"
        catch error
          context.report {
            node
            message:
              'dynamic imports require a "webpack" comment with valid syntax'
          }
          return

        unless commentStyleRegex.test comment.value
          context.report {
            node
            message: "dynamic imports require a leading comment in the form ####{chunkSubstrFormat}###"
          }
          return

        if chunkSubstrRegex.test comment.value then isChunknamePresent = yes

      unless isChunknamePresent
        context.report {
          node
          message: "dynamic imports require a leading comment in the form ####{chunkSubstrFormat}###"
        }
