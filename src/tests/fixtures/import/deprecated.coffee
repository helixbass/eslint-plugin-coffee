# some line comment
###*
# this function is terrible
# @deprecated please use 'x' instead.
# @return null
###
# another line comment
# with two lines
export fn = -> return null

###*
# so terrible
# @deprecated this is awful, use NotAsBadClass.
###
export default class TerribleClass

###*
# some flux action type maybe
# @deprecated please stop sending/handling this action type.
# @type {String}
###
export MY_TERRIBLE_ACTION = 'ugh'

###*
# @deprecated this chain is awful
# @type {String}
###
export CHAIN_A = 'a'
###*
# @deprecated so awful
# @type {String}
###
export CHAIN_B = 'b'

###*
 * An async function. Options requires return.
###
export CHAIN_C = 'C'

###*
# this one is fine
# @return {String} - great!
###
export fine = -> return 'great!'

export _undocumented = -> return 'sneaky!'
