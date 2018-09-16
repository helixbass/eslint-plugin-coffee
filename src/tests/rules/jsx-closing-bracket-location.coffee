###*
# @fileoverview Validate closing bracket location in JSX
# @author Yannick Croissant
###
'use strict'

# ------------------------------------------------------------------------------
# Requirements
# ------------------------------------------------------------------------------

rule = require '../../rules/jsx-closing-bracket-location'
{RuleTester} = require 'eslint'
MESSAGE_AFTER_PROPS = [
  message: 'The closing bracket must be placed after the last prop'
]
MESSAGE_AFTER_TAG = [
  message: 'The closing bracket must be placed after the opening tag'
]

MESSAGE_PROPS_ALIGNED = 'The closing bracket must be aligned with the last prop'
# MESSAGE_TAG_ALIGNED = 'The closing bracket must be aligned with the opening tag'
MESSAGE_LINE_ALIGNED =
  'The closing bracket must be aligned with the line containing the opening tag'

messageWithDetails = (message, expectedColumn, expectedNextLine) ->
  details = " (expected column #{expectedColumn}#{
    if expectedNextLine then ' on the next line)' else ')'
  }"
  message + details

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------

ruleTester = new RuleTester parser: '../../..'
ruleTester.run 'jsx-closing-bracket-location', rule,
  valid: [
    code: ['<App />'].join('\n')
  ,
    code: ['<App foo />'].join('\n')
  ,
    code: ['<App ', '  foo', '/>'].join('\n')
  ,
    code: ['<App foo />'].join '\n'
    options: [location: 'after-props']
  ,
    # ,
    #   code: ['<App foo />'].join '\n'
    #   options: [location: 'tag-aligned']
    code: ['<App foo />'].join '\n'
    options: [location: 'line-aligned']
  ,
    code: ['<App ', '  foo />'].join '\n'
    options: ['after-props']
  ,
    code: ['<App ', '  foo', '  />'].join '\n'
    options: ['props-aligned']
  ,
    code: ['<App ', '  foo />'].join '\n'
    options: [location: 'after-props']
  ,
    # ,
    #   code: ['<App ', '  foo', '/>'].join '\n'
    #   options: [location: 'tag-aligned']
    code: ['<App ', '  foo', '/>'].join '\n'
    options: [location: 'line-aligned']
  ,
    code: ['<App ', '  foo', '  />'].join '\n'
    options: [location: 'props-aligned']
  ,
    code: ['<App foo></App>'].join('\n')
  ,
    # ,
    #   code: ['<App', '  foo', '></App>'].join '\n'
    #   options: [location: 'tag-aligned']
    code: ['<App', '  foo', '></App>'].join '\n'
    options: [location: 'line-aligned']
  ,
    code: ['<App', '  foo', '  ></App>'].join '\n'
    options: [location: 'props-aligned']
  ,
    code: ['<App', '  foo={->', "    console.log('bar')", '  } />'].join '\n'
    options: [location: 'after-props']
  ,
    code: ['<App', '  foo={->', "    console.log('bar')", '  }', '  />'].join(
      '\n'
    )
    options: [location: 'props-aligned']
  ,
    # ,
    #   code: ['<App', '  foo={->', "    console.log('bar')", '  }', '/>'].join(
    #     '\n'
    #   )
    #   options: [location: 'tag-aligned']
    code: ['<App', '  foo={->', "    console.log('bar')", '  }', '/>'].join(
      '\n'
    )
    options: [location: 'line-aligned']
  ,
    code: ['<App foo={->', "  console.log('bar')", '}/>'].join '\n'
    options: [location: 'after-props']
  ,
    code: '''
      <App
        foo={->
          console.log('bar')
        }
        />
    '''
    options: [location: 'props-aligned']
  ,
    # ,
    #   code: ['<App foo={->', "  console.log('bar')", '}', '/>'].join '\n'
    #   options: [location: 'tag-aligned']
    code: ['<App foo={->', "  console.log('bar')", '}', '/>'].join '\n'
    options: [location: 'line-aligned']
  ,
    code: ['<Provider store>', '  <App', '    foo />', '</Provider>'].join '\n'
    options: [selfClosing: 'after-props']
  ,
    code: [
      '<Provider '
      '  store'
      '>'
      '  <App'
      '    foo />'
      '</Provider>'
    ].join '\n'
    options: [selfClosing: 'after-props']
  ,
    code: [
      '<Provider '
      '  store>'
      '  <App '
      '    foo'
      '  />'
      '</Provider>'
    ].join '\n'
    options: [nonEmpty: 'after-props']
  ,
    code: [
      '<Provider store>'
      '  <App '
      '    foo'
      '    />'
      '</Provider>'
    ].join '\n'
    options: [selfClosing: 'props-aligned']
  ,
    code: [
      '<Provider'
      '  store'
      '  >'
      '  <App '
      '    foo'
      '  />'
      '</Provider>'
    ].join '\n'
    options: [nonEmpty: 'props-aligned']
  ,
    code: [
      'x = ->'
      '  return <App'
      '    foo={->'
      "      console.log('bar')"
      '    }'
      '  />'
    ].join '\n'
    options: [location: 'line-aligned']
  ,
    code: ['x = <App', '  foo={->', "    console.log('bar')", '  }', '/>'].join(
      '\n'
    )
    options: [location: 'line-aligned']
  ,
    code: [
      '<Provider'
      '  store'
      '>'
      '  <App'
      '    foo={->'
      "      console.log('bar')"
      '    }'
      '  />'
      '</Provider>'
    ].join '\n'
    options: [location: 'line-aligned']
  ,
    code: [
      '<Provider'
      '  store'
      '>'
      '  {baz && <App'
      '    foo={->'
      "      console.log('bar')"
      '    }'
      '  />}'
      '</Provider>'
    ].join '\n'
    options: [location: 'line-aligned']
  ,
    code: [
      '<App>'
      '  <Foo'
      '    bar'
      '  >'
      '  </Foo>'
      '  <Foo'
      '    bar />'
      '</App>'
    ].join '\n'
    options: [
      nonEmpty: no
      selfClosing: 'after-props'
    ]
  ,
    code: [
      '<App>'
      '  <Foo'
      '    bar>'
      '  </Foo>'
      '  <Foo'
      '    bar'
      '  />'
      '</App>'
    ].join '\n'
    options: [
      nonEmpty: 'after-props'
      selfClosing: no
    ]
  ,
    # ,
    #   code: [
    #     '<div className={['
    #     '  "some",'
    #     '  "stuff",'
    #     '  2 ]}'
    #     '>'
    #     '  Some text'
    #     '</div>'
    #   ].join '\n'
    #   options: [location: 'tag-aligned']
    code: [
      '<div className={['
      '  "some",'
      '  "stuff",'
      '  2 ]}'
      '>'
      '  Some text'
      '</div>'
    ].join '\n'
    options: [location: 'line-aligned']
  ,
    code: ['<App ', '\tfoo', '/>'].join('\n')
  ,
    code: ['<App ', '\tfoo />'].join '\n'
    options: ['after-props']
  ,
    code: ['<App ', '\tfoo', '\t/>'].join '\n'
    options: ['props-aligned']
  ,
    code: ['<App ', '\tfoo />'].join '\n'
    options: [location: 'after-props']
  ,
    # ,
    #   code: ['<App ', '\tfoo', '/>'].join '\n'
    #   options: [location: 'tag-aligned']
    code: ['<App ', '\tfoo', '/>'].join '\n'
    options: [location: 'line-aligned']
  ,
    code: ['<App ', '\tfoo', '\t/>'].join '\n'
    options: [location: 'props-aligned']
  ,
    # ,
    #   code: ['<App', '\tfoo', '></App>'].join '\n'
    #   options: [location: 'tag-aligned']
    code: ['<App', '\tfoo', '></App>'].join '\n'
    options: [location: 'line-aligned']
  ,
    code: ['<App', '\tfoo', '\t></App>'].join '\n'
    options: [location: 'props-aligned']
  ,
    code: ['<App', '\tfoo={->', "\t\tconsole.log('bar')", '\t} />'].join '\n'
    options: [location: 'after-props']
  ,
    code: ['<App', '\tfoo={->', "\t\tconsole.log('bar')", '\t}', '\t/>'].join(
      '\n'
    )
    options: [location: 'props-aligned']
  ,
    # ,
    #   code: ['<App', '\tfoo={->', "\t\tconsole.log('bar')", '\t}', '/>'].join(
    #     '\n'
    #   )
    #   options: [location: 'tag-aligned']
    code: ['<App', '\tfoo={->', "\t\tconsole.log('bar')", '\t}', '/>'].join(
      '\n'
    )
    options: [location: 'line-aligned']
  ,
    code: ['<App foo={->', "\tconsole.log('bar')", '}/>'].join '\n'
    options: [location: 'after-props']
  ,
    # ,
    #   code: ['<App foo={->', "\tconsole.log('bar')", '}', '/>'].join '\n'
    #   options: [location: 'tag-aligned']
    code: ['<App foo={->', "\tconsole.log('bar')", '}', '/>'].join '\n'
    options: [location: 'line-aligned']
  ,
    code: ['<Provider store>', '\t<App', '\t\tfoo />', '</Provider>'].join '\n'
    options: [selfClosing: 'after-props']
  ,
    code: [
      '<Provider '
      '\tstore'
      '>'
      '\t<App'
      '\t\tfoo />'
      '</Provider>'
    ].join '\n'
    options: [selfClosing: 'after-props']
  ,
    code: [
      '<Provider '
      '\tstore>'
      '\t<App '
      '\t\tfoo'
      '\t/>'
      '</Provider>'
    ].join '\n'
    options: [nonEmpty: 'after-props']
  ,
    code: [
      '<Provider store>'
      '\t<App '
      '\t\tfoo'
      '\t\t/>'
      '</Provider>'
    ].join '\n'
    options: [selfClosing: 'props-aligned']
  ,
    code: [
      '<Provider'
      '\tstore'
      '\t>'
      '\t<App '
      '\t\tfoo'
      '\t/>'
      '</Provider>'
    ].join '\n'
    options: [nonEmpty: 'props-aligned']
  ,
    # ,
    #   code: ['x = <App', '        foo', '    />'].join '\n'
    #   options: [location: 'tag-aligned']
    code: [
      'x = ->'
      '\treturn <App'
      '\t\tfoo={->'
      "\t\t\tconsole.log('bar')"
      '\t\t}'
      '\t/>'
    ].join '\n'
    options: [location: 'line-aligned']
  ,
    code: ['x = <App', '\tfoo={->', "\t\tconsole.log('bar')", '\t}', '/>'].join(
      '\n'
    )
    options: [location: 'line-aligned']
  ,
    code: [
      '<Provider'
      '\tstore'
      '>'
      '\t<App'
      '\t\tfoo={->'
      "\t\t\tconsole.log('bar')"
      '\t\t}'
      '\t/>'
      '</Provider>'
    ].join '\n'
    options: [location: 'line-aligned']
  ,
    code: [
      '<Provider'
      '\tstore'
      '>'
      '\t{baz && <App'
      '\t\tfoo={->'
      "\t\t\tconsole.log('bar')"
      '\t\t}'
      '\t/>}'
      '</Provider>'
    ].join '\n'
    options: [location: 'line-aligned']
  ,
    code: [
      '<App>'
      '\t<Foo'
      '\t\tbar'
      '\t>'
      '\t</Foo>'
      '\t<Foo'
      '\t\tbar />'
      '</App>'
    ].join '\n'
    options: [
      nonEmpty: no
      selfClosing: 'after-props'
    ]
  ,
    code: [
      '<App>'
      '\t<Foo'
      '\t\tbar>'
      '\t</Foo>'
      '\t<Foo'
      '\t\tbar'
      '\t/>'
      '</App>'
    ].join '\n'
    options: [
      nonEmpty: 'after-props'
      selfClosing: no
    ]
  ,
    # ,
    #   code: [
    #     '<div className={['
    #     '\t"some",'
    #     '\t"stuff",'
    #     '\t2 ]}'
    #     '>'
    #     '\tSome text'
    #     '</div>'
    #   ].join '\n'
    #   options: [location: 'tag-aligned']
    code: [
      '<div className={['
      '\t"some",'
      '\t"stuff",'
      '\t2 ]}'
      '>'
      '\tSome text'
      '</div>'
    ].join '\n'
    options: [location: 'line-aligned']
  ]

  invalid: [
    code: ['<App ', '/>'].join '\n'
    output: ['<App />'].join '\n'
    errors: MESSAGE_AFTER_TAG
  ,
    code: ['<App foo ', '/>'].join '\n'
    output: ['<App foo/>'].join '\n'
    errors: MESSAGE_AFTER_PROPS
  ,
    code: ['<App foo', '></App>'].join '\n'
    output: ['<App foo></App>'].join '\n'
    errors: MESSAGE_AFTER_PROPS
  ,
    code: ['<App ', '  foo />'].join '\n'
    output: ['<App ', '  foo', '  />'].join '\n'
    options: [location: 'props-aligned']
    errors: [
      message: messageWithDetails MESSAGE_PROPS_ALIGNED, 3, yes
      line: 2
      column: 7
    ]
  ,
    # ,
    #   code: ['<App ', '  foo />'].join '\n'
    #   output: ['<App ', '  foo', '/>'].join '\n'
    #   options: [location: 'tag-aligned']
    #   errors: [
    #     message: messageWithDetails MESSAGE_TAG_ALIGNED, 1, yes
    #     line: 2
    #     column: 7
    #   ]
    code: ['<App ', '  foo />'].join '\n'
    output: ['<App ', '  foo', '/>'].join '\n'
    options: [location: 'line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 1, yes
      line: 2
      column: 7
    ]
  ,
    code: ['<App ', '  foo', '/>'].join '\n'
    output: ['<App ', '  foo/>'].join '\n'
    options: [location: 'after-props']
    errors: MESSAGE_AFTER_PROPS
  ,
    code: ['<App ', '  foo', '/>'].join '\n'
    output: ['<App ', '  foo', '  />'].join '\n'
    options: [location: 'props-aligned']
    errors: [
      message: messageWithDetails MESSAGE_PROPS_ALIGNED, 3, no
      line: 3
      column: 1
    ]
  ,
    code: ['<App ', '  foo', '  />'].join '\n'
    output: ['<App ', '  foo/>'].join '\n'
    options: [location: 'after-props']
    errors: MESSAGE_AFTER_PROPS
  ,
    # ,
    #   code: ['<App ', '  foo', '  />'].join '\n'
    #   output: ['<App ', '  foo', '/>'].join '\n'
    #   options: [location: 'tag-aligned']
    #   errors: [
    #     message: messageWithDetails MESSAGE_TAG_ALIGNED, 1, no
    #     line: 3
    #     column: 3
    #   ]
    code: ['<App ', '  foo', '  />'].join '\n'
    output: ['<App ', '  foo', '/>'].join '\n'
    options: [location: 'line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 1, no
      line: 3
      column: 3
    ]
  ,
    code: ['<App', '  foo', '></App>'].join '\n'
    output: ['<App', '  foo></App>'].join '\n'
    options: [location: 'after-props']
    errors: MESSAGE_AFTER_PROPS
  ,
    code: ['<App', '  foo', '></App>'].join '\n'
    output: ['<App', '  foo', '  ></App>'].join '\n'
    options: [location: 'props-aligned']
    errors: [
      message: messageWithDetails MESSAGE_PROPS_ALIGNED, 3, no
      line: 3
      column: 1
    ]
  ,
    code: ['<App', '  foo', '  ></App>'].join '\n'
    output: ['<App', '  foo></App>'].join '\n'
    options: [location: 'after-props']
    errors: MESSAGE_AFTER_PROPS
  ,
    # ,
    #   code: ['<App', '  foo', '  ></App>'].join '\n'
    #   output: ['<App', '  foo', '></App>'].join '\n'
    #   options: [location: 'tag-aligned']
    #   errors: [
    #     message: messageWithDetails MESSAGE_TAG_ALIGNED, 1, no
    #     line: 3
    #     column: 3
    #   ]
    code: ['<App', '  foo', '  ></App>'].join '\n'
    output: ['<App', '  foo', '></App>'].join '\n'
    options: [location: 'line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 1, no
      line: 3
      column: 3
    ]
  ,
    code: [
      '<Provider '
      '  store>' # <--
      '  <App '
      '    foo'
      '    />'
      '</Provider>'
    ].join '\n'
    output: [
      '<Provider '
      '  store'
      '>'
      '  <App '
      '    foo'
      '    />'
      '</Provider>'
    ].join '\n'
    options: [selfClosing: 'props-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 1, yes
      line: 2
      column: 8
    ]
  ,
    code: [
      'Button = (props) ->'
      '  return ('
      '    <Button'
      '      size={size}'
      '      onClick={onClick}'
      '    >'
      '      Button Text'
      '    </Button>'
      '  )'
    ].join '\n'
    output: [
      'Button = (props) ->'
      '  return ('
      '    <Button'
      '      size={size}'
      '      onClick={onClick}'
      '      >'
      '      Button Text'
      '    </Button>'
      '  )'
    ].join '\n'
    options: ['props-aligned']
    errors: [
      message: messageWithDetails MESSAGE_PROPS_ALIGNED, 7, no
      line: 6
      column: 5
    ]
  ,
    # ,
    #   code: [
    #     'Button = (props) ->'
    #     '  return ('
    #     '    <Button'
    #     '      size={size}'
    #     '      onClick={onClick}'
    #     '     >'
    #     '      Button Text'
    #     '    </Button>'
    #     '  )'
    #   ].join '\n'
    #   output: [
    #     'Button = (props) ->'
    #     '  return ('
    #     '    <Button'
    #     '      size={size}'
    #     '      onClick={onClick}'
    #     '    >'
    #     '      Button Text'
    #     '    </Button>'
    #     '  )'
    #   ].join '\n'
    #   options: ['tag-aligned']
    #   errors: [
    #     message: messageWithDetails MESSAGE_TAG_ALIGNED, 5, no
    #     line: 6
    #     column: 6
    #   ]
    code: [
      'Button = (props) ->'
      '  return ('
      '    <Button'
      '      size={size}'
      '      onClick={onClick}'
      '      >'
      '      Button Text'
      '    </Button>'
      '  )'
    ].join '\n'
    output: [
      'Button = (props) ->'
      '  return ('
      '    <Button'
      '      size={size}'
      '      onClick={onClick}'
      '    >'
      '      Button Text'
      '    </Button>'
      '  )'
    ].join '\n'
    options: ['line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 5, no
      line: 6
      column: 7
    ]
  ,
    code: [
      '<Provider'
      '  store'
      '  >'
      '  <App '
      '    foo'
      '    />' # <--
      '</Provider>'
    ].join '\n'
    output: [
      '<Provider'
      '  store'
      '  >'
      '  <App '
      '    foo'
      '  />'
      '</Provider>'
    ].join '\n'
    options: [nonEmpty: 'props-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 3, no
      line: 6
      column: 5
    ]
  ,
    code: [
      '<Provider '
      '  store>' # <--
      '  <App'
      '    foo />'
      '</Provider>'
    ].join '\n'
    output: [
      '<Provider '
      '  store'
      '>'
      '  <App'
      '    foo />'
      '</Provider>'
    ].join '\n'
    options: [selfClosing: 'after-props']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 1, yes
      line: 2
      column: 8
    ]
  ,
    code: [
      '<Provider '
      '  store>'
      '  <App '
      '    foo'
      '    />' # <--
      '</Provider>'
    ].join '\n'
    output: [
      '<Provider '
      '  store>'
      '  <App '
      '    foo'
      '  />' # <--
      '</Provider>'
    ].join '\n'
    options: [nonEmpty: 'after-props']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 3, no
      line: 5
      column: 5
    ]
  ,
    code: ['x = ->', '  return <App', '    foo', '    />'].join '\n'
    output: ['x = ->', '  return <App', '    foo', '  />'].join '\n'
    options: [location: 'line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 3, no
      line: 4
      column: 5
    ]
  ,
    code: ['x = <App', '  foo', '  />'].join '\n'
    output: ['x = <App', '  foo', '/>'].join '\n'
    options: [location: 'line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 1, no
      line: 3
      column: 3
    ]
  ,
    code: [
      'x = ('
      '  <div'
      '    className="MyComponent"'
      '    {...props} />'
      ')'
    ].join '\n'
    output: [
      'x = ('
      '  <div'
      '    className="MyComponent"'
      '    {...props}'
      '  />'
      ')'
    ].join '\n'
    options: [location: 'line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 3, yes
      line: 4
      column: 16
    ]
  ,
    code: ['x = (', '  <Something', '    content={<Foo />} />', ')'].join '\n'
    output: [
      'x = ('
      '  <Something'
      '    content={<Foo />}'
      '  />'
      ')'
    ].join '\n'
    options: [location: 'line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 3, yes
      line: 3
      column: 23
    ]
  ,
    code: ['x = (', '  <Something ', '  />', ')'].join '\n'
    output: ['x = (', '  <Something />', ')'].join '\n'
    options: [location: 'line-aligned']
    errors: [MESSAGE_AFTER_TAG]
  ,
    # ,
    #   code: [
    #     '<div className={['
    #     '  "some",'
    #     '  "stuff",'
    #     '  2 ]}>'
    #     '  Some text'
    #     '</div>'
    #   ].join '\n'
    #   output: [
    #     '<div className={['
    #     '  "some",'
    #     '  "stuff",'
    #     '  2 ]}'
    #     '>'
    #     '  Some text'
    #     '</div>'
    #   ].join '\n'
    #   options: [location: 'tag-aligned']
    #   errors: [
    #     message: messageWithDetails MESSAGE_TAG_ALIGNED, 1, yes
    #     line: 4
    #     column: 7
    #   ]
    code: [
      '<div className={['
      '  "some",'
      '  "stuff",'
      '  2 ]}>'
      '  Some text'
      '</div>'
    ].join '\n'
    output: [
      '<div className={['
      '  "some",'
      '  "stuff",'
      '  2 ]}'
      '>'
      '  Some text'
      '</div>'
    ].join '\n'
    options: [location: 'line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 1, yes
      line: 4
      column: 7
    ]
  ,
    code: ['<App ', '\tfoo />'].join '\n'
    output: ['<App ', '\tfoo', '\t/>'].join '\n'
    options: [location: 'props-aligned']
    errors: [
      message: messageWithDetails MESSAGE_PROPS_ALIGNED, 2, yes
      line: 2
      column: 6
    ]
  ,
    # ,
    #   code: ['<App ', '\tfoo />'].join '\n'
    #   output: ['<App ', '\tfoo', '/>'].join '\n'
    #   options: [location: 'tag-aligned']
    #   errors: [
    #     message: messageWithDetails MESSAGE_TAG_ALIGNED, 1, yes
    #     line: 2
    #     column: 6
    #   ]
    code: ['<App ', '\tfoo />'].join '\n'
    output: ['<App ', '\tfoo', '/>'].join '\n'
    options: [location: 'line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 1, yes
      line: 2
      column: 6
    ]
  ,
    code: ['<App ', '\tfoo', '/>'].join '\n'
    output: ['<App ', '\tfoo/>'].join '\n'
    options: [location: 'after-props']
    errors: MESSAGE_AFTER_PROPS
  ,
    code: ['<App ', '\tfoo', '/>'].join '\n'
    output: ['<App ', '\tfoo', '\t/>'].join '\n'
    options: [location: 'props-aligned']
    errors: [
      message: messageWithDetails MESSAGE_PROPS_ALIGNED, 2, no
      line: 3
      column: 1
    ]
  ,
    code: ['<App ', '\tfoo', '\t/>'].join '\n'
    output: ['<App ', '\tfoo/>'].join '\n'
    options: [location: 'after-props']
    errors: MESSAGE_AFTER_PROPS
  ,
    # ,
    #   code: ['<App ', '\tfoo', '\t/>'].join '\n'
    #   output: ['<App ', '\tfoo', '/>'].join '\n'
    #   options: [location: 'tag-aligned']
    #   errors: [
    #     message: messageWithDetails MESSAGE_TAG_ALIGNED, 1, no
    #     line: 3
    #     column: 2
    #   ]
    code: ['<App ', '\tfoo', '\t/>'].join '\n'
    output: ['<App ', '\tfoo', '/>'].join '\n'
    options: [location: 'line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 1, no
      line: 3
      column: 2
    ]
  ,
    code: ['<App', '\tfoo', '></App>'].join '\n'
    output: ['<App', '\tfoo></App>'].join '\n'
    options: [location: 'after-props']
    errors: MESSAGE_AFTER_PROPS
  ,
    code: ['<App', '\tfoo', '></App>'].join '\n'
    output: ['<App', '\tfoo', '\t></App>'].join '\n'
    options: [location: 'props-aligned']
    errors: [
      message: messageWithDetails MESSAGE_PROPS_ALIGNED, 2, no
      line: 3
      column: 1
    ]
  ,
    code: ['<App', '\tfoo', '\t></App>'].join '\n'
    output: ['<App', '\tfoo></App>'].join '\n'
    options: [location: 'after-props']
    errors: MESSAGE_AFTER_PROPS
  ,
    # ,
    #   code: ['<App', '\tfoo', '\t></App>'].join '\n'
    #   output: ['<App', '\tfoo', '></App>'].join '\n'
    #   options: [location: 'tag-aligned']
    #   errors: [
    #     message: messageWithDetails MESSAGE_TAG_ALIGNED, 1, no
    #     line: 3
    #     column: 2
    #   ]
    code: ['<App', '\tfoo', '\t></App>'].join '\n'
    output: ['<App', '\tfoo', '></App>'].join '\n'
    options: [location: 'line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 1, no
      line: 3
      column: 2
    ]
  ,
    code: [
      '<Provider '
      '\tstore>' # <--
      '\t<App '
      '\t\tfoo'
      '\t\t/>'
      '</Provider>'
    ].join '\n'
    output: [
      '<Provider '
      '\tstore'
      '>'
      '\t<App '
      '\t\tfoo'
      '\t\t/>'
      '</Provider>'
    ].join '\n'
    options: [selfClosing: 'props-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 1, yes
      line: 2
      column: 7
    ]
  ,
    # ,
    #   code: [
    #     'Button = (props) ->'
    #     '\treturn ('
    #     '\t\t<Button'
    #     '\t\t\tsize={size}'
    #     '\t\t\tonClick={onClick}'
    #     '\t\t\t>'
    #     '\t\t\tButton Text'
    #     '\t\t</Button>'
    #     '\t)'
    #   ].join '\n'
    #   output: [
    #     'Button = (props) ->'
    #     '\treturn ('
    #     '\t\t<Button'
    #     '\t\t\tsize={size}'
    #     '\t\t\tonClick={onClick}'
    #     '\t\t>'
    #     '\t\t\tButton Text'
    #     '\t\t</Button>'
    #     '\t)'
    #   ].join '\n'
    #   options: ['tag-aligned']
    #   errors: [
    #     message: messageWithDetails MESSAGE_TAG_ALIGNED, 3, no
    #     line: 6
    #     column: 4
    #   ]
    code: [
      'Button = (props) ->'
      '\treturn ('
      '\t\t<Button'
      '\t\t\tsize={size}'
      '\t\t\tonClick={onClick}'
      '\t\t\t>'
      '\t\t\tButton Text'
      '\t\t</Button>'
      '\t)'
    ].join '\n'
    output: [
      'Button = (props) ->'
      '\treturn ('
      '\t\t<Button'
      '\t\t\tsize={size}'
      '\t\t\tonClick={onClick}'
      '\t\t>'
      '\t\t\tButton Text'
      '\t\t</Button>'
      '\t)'
    ].join '\n'
    options: ['line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 3, no
      line: 6
      column: 4
    ]
  ,
    code: [
      '<Provider'
      '\tstore'
      '\t>'
      '\t<App '
      '\t\tfoo'
      '\t\t/>' # <--
      '</Provider>'
    ].join '\n'
    output: [
      '<Provider'
      '\tstore'
      '\t>'
      '\t<App '
      '\t\tfoo'
      '\t/>'
      '</Provider>'
    ].join '\n'
    options: [nonEmpty: 'props-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 2, no
      line: 6
      column: 3
    ]
  ,
    code: [
      '<Provider '
      '\tstore>' # <--
      '\t<App'
      '\t\tfoo />'
      '</Provider>'
    ].join '\n'
    output: [
      '<Provider '
      '\tstore'
      '>'
      '\t<App'
      '\t\tfoo />'
      '</Provider>'
    ].join '\n'
    options: [selfClosing: 'after-props']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 1, yes
      line: 2
      column: 7
    ]
  ,
    code: [
      '<Provider '
      '\tstore>'
      '\t<App '
      '\t\tfoo'
      '\t\t/>' # <--
      '</Provider>'
    ].join '\n'
    output: [
      '<Provider '
      '\tstore>'
      '\t<App '
      '\t\tfoo'
      '\t/>' # <--
      '</Provider>'
    ].join '\n'
    options: [nonEmpty: 'after-props']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 2, no
      line: 5
      column: 3
    ]
  ,
    code: ['x = ->', '\treturn <App', '\t\tfoo', '\t\t/>'].join '\n'
    output: ['x = ->', '\treturn <App', '\t\tfoo', '\t/>'].join '\n'
    options: [location: 'line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 2, no
      line: 4
      column: 3
    ]
  ,
    code: [
      'x = ('
      '\t<div'
      '\t\tclassName="MyComponent"'
      '\t\t{...props} />'
      ')'
    ].join '\n'
    output: [
      'x = ('
      '\t<div'
      '\t\tclassName="MyComponent"'
      '\t\t{...props}'
      '\t/>'
      ')'
    ].join '\n'
    options: [location: 'line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 2, yes
      line: 4
      column: 14
    ]
  ,
    code: ['x = (', '\t<Something', '\t\tcontent={<Foo />} />', ')'].join '\n'
    output: [
      'x = ('
      '\t<Something'
      '\t\tcontent={<Foo />}'
      '\t/>'
      ')'
    ].join '\n'
    options: [location: 'line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 2, yes
      line: 3
      column: 21
    ]
  ,
    code: ['x = (', '\t<Something ', '\t/>', ')'].join '\n'
    output: ['x = (', '\t<Something />', ')'].join '\n'
    options: [location: 'line-aligned']
    errors: [MESSAGE_AFTER_TAG]
  ,
    # ,
    #   code: [
    #     '<div className={['
    #     '\t"some",'
    #     '\t"stuff",'
    #     '\t2 ]}>'
    #     '\tSome text'
    #     '</div>'
    #   ].join '\n'
    #   output: [
    #     '<div className={['
    #     '\t"some",'
    #     '\t"stuff",'
    #     '\t2 ]}'
    #     '>'
    #     '\tSome text'
    #     '</div>'
    #   ].join '\n'
    #   options: [location: 'tag-aligned']
    #   errors: [
    #     message: messageWithDetails MESSAGE_TAG_ALIGNED, 1, yes
    #     line: 4
    #     column: 6
    #   ]
    code: [
      '<div className={['
      '\t"some",'
      '\t"stuff",'
      '\t2 ]}>'
      '\tSome text'
      '</div>'
    ].join '\n'
    output: [
      '<div className={['
      '\t"some",'
      '\t"stuff",'
      '\t2 ]}'
      '>'
      '\tSome text'
      '</div>'
    ].join '\n'
    options: [location: 'line-aligned']
    errors: [
      message: messageWithDetails MESSAGE_LINE_ALIGNED, 1, yes
      line: 4
      column: 6
    ]
  ]
