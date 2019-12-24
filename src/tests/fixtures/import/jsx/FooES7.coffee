### eslint-disable ###
# see issue #36

# Foo.jsx
class Foo
  # ES7 static members
  @bar: yes

export default Foo

export class Bar
  @baz: no

  render: ->
    {a, ...rest} = {a: 1, b: 2, c: 3}
