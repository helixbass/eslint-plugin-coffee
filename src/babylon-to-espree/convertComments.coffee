'use strict'

module.exports = (comments) ->
  for comment in comments
    if comment.type is 'CommentBlock'
      comment.type = 'Block'
    else if comment.type is 'CommentLine'
      comment.type = 'Line'
    # sometimes comments don't get ranges computed,
    # even with options.ranges === true
    unless comment.range
      comment.range = [comment.start, comment.end]
  undefined
