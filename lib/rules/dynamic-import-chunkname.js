// Generated by CoffeeScript 2.5.0
(function() {
  var vm;

  vm = require('vm');

  // import docsUrl from '../docsUrl'
  module.exports = {
    meta: {
      docs: {
        // url: docsUrl 'dynamic-import-chunkname'
        url: ''
      },
      schema: [
        {
          type: 'object',
          properties: {
            importFunctions: {
              type: 'array',
              uniqueItems: true,
              items: {
                type: 'string'
              }
            },
            webpackChunknameFormat: {
              type: 'string'
            }
          }
        }
      ]
    },
    create: function(context) {
      var chunkSubstrFormat, chunkSubstrRegex, commentStyleRegex, config, importFunctions, paddedCommentRegex, webpackChunknameFormat;
      config = context.options[0];
      ({importFunctions = []} = config || {});
      ({webpackChunknameFormat = '[0-9a-zA-Z-_/.]+'} = config || {});
      paddedCommentRegex = /^ (\S[\s\S]+\S) $/;
      commentStyleRegex = /^( \w+: ("[^"]*"|\d+|false|true),?)+ $/;
      chunkSubstrFormat = ` webpackChunkName: \"${webpackChunknameFormat}\",? `;
      chunkSubstrRegex = new RegExp(chunkSubstrFormat);
      return {
        CallExpression: function(node) {
          var arg, comment, error, isChunknamePresent, leadingComments, sourceCode;
          if (node.callee.type !== 'Import' && importFunctions.indexOf(node.callee.name) < 0) {
            return;
          }
          sourceCode = context.getSourceCode();
          arg = node.arguments[0];
          leadingComments = sourceCode.getComments(arg).leading;
          if (!leadingComments || leadingComments.length === 0) {
            context.report({
              node,
              message: 'dynamic imports require a leading comment with the webpack chunkname'
            });
            return;
          }
          isChunknamePresent = false;
          for (comment of leadingComments) {
            if (comment.type !== 'Block') {
              context.report({
                node,
                message: 'dynamic imports require a ### foo ### style comment, not a # foo comment'
              });
              return;
            }
            if (!paddedCommentRegex.test(comment.value)) {
              context.report({
                node,
                message: 'dynamic imports require a block comment padded with spaces - ### foo ###'
              });
              return;
            }
            try {
              // just like webpack itself does
              vm.runInNewContext(`(function(){return {${comment.value}}})()`);
            } catch (error1) {
              error = error1;
              context.report({
                node,
                message: 'dynamic imports require a "webpack" comment with valid syntax'
              });
              return;
            }
            if (!commentStyleRegex.test(comment.value)) {
              context.report({
                node,
                message: `dynamic imports require a leading comment in the form ###${chunkSubstrFormat}###`
              });
              return;
            }
            if (chunkSubstrRegex.test(comment.value)) {
              isChunknamePresent = true;
            }
          }
          if (!isChunknamePresent) {
            return context.report({
              node,
              message: `dynamic imports require a leading comment in the form ###${chunkSubstrFormat}###`
            });
          }
        }
      };
    }
  };

}).call(this);