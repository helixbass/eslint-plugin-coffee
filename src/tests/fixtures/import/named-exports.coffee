a = 1
b = 2

export {a, b}

c = 3
export {c as d}

export class ExportedClass

# destructuring exports

# TODO: can uncomment(-ish) once https://github.com/jashkenas/coffeescript/issues/5100 is supported
# export { destructuredProp } = {}
#          , { destructingAssign = null } = {}
#          , { destructingAssign: destructingRenamedAssign = null } = {}
#          , [ arrayKeyProp ] = []
#          , [ { deepProp } ] = []
#          , { arr: [ ,, deepSparseElement ] } = {}
