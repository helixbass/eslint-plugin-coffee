if a
  b = c
  d = e *
    f
  e = f # <-
# ->
  g = ->
    if h
      i = j

  while k l++
  while m
   n-- # ->

  for s in t
    u++

  for [0..1]
      v++ # <-

  if w
    x++
  else if y
      z++ # <-
      aa++
  else
   bb++ # ->

arr = [
  a,
  b,
  c,
  ->
     d # <-
  {},
  {
    a: b,
    c: d,
    d: e
  },
  [
    f,
    g,
    h,
    i
  ],
  [j]
]

obj =
  a
    b
      c: d
      e: f
      g: h +
    i # NO ERROR: DON'T VALIDATE MULTILINE STATEMENTS
  g: [
    h
    i
    j
    k
  ]

arrObject = {a:[
  a,
  b, # NO ERROR: INDENT ONCE WHEN MULTIPLE INDENTED EXPRESSIONS ARE ON SAME LINE
  c
]}

arrObject = a:[
  a,
  b, # NO ERROR: INDENT ONCE WHEN MULTIPLE INDENTED EXPRESSIONS ARE ON SAME LINE
  c
]

objArray = [{
  a: b,
  b: c, # NO ERROR: INDENT ONCE WHEN MULTIPLE INDENTED EXPRESSIONS ARE ON SAME LINE
  c: d
}]

objArray = [
  a: b,
  b: c, # NO ERROR: INDENT ONCE WHEN MULTIPLE INDENTED EXPRESSIONS ARE ON SAME LINE
  c: d
]

arrArray = [[
  a,
  b, # NO ERROR: INDENT ONCE WHEN MULTIPLE INDENTED EXPRESSIONS ARE ON SAME LINE
  c
]]

objObject = {a:{
  a: b,
  b: c, # NO ERROR: INDENT ONCE WHEN MULTIPLE INDENTED EXPRESSIONS ARE ON SAME LINE
  c: d
}}

objObject = a
  a: b,
  b: c, # NO ERROR: INDENT ONCE WHEN MULTIPLE INDENTED EXPRESSIONS ARE ON SAME LINE
  c: d

switch (a) {
  when 'a'
   a = 'b' # ->
  when 'b'
    a = 'b'
  when 'c'
      a = 'b' # <-
  when 'd'
    a = 'b'
  when 'f'
    a = 'b'
  when 'g'
    a = 'b'
  when 'z'
  else
      break # <-

a.b 'hi'
   .c a.b() # <-
   .d() # <-

if  a
  if b
    d.e(f)
      .g()
      .h()

    n.o(p)
    .q()
    .r()

c = (a, b) ->
  if (a or (a and
            b)) # NO ERROR: DON'T VALIDATE MULTILINE STATEMENTS
    return d

a({
  d: 1
})

a
  d: 1

a(
  1
)

a(
  b {
    d: 1
  }
)

a(
  b(
    c({
      d: 1,
      e: 1,
      f: 1
    })
  )
)

a({ d: 1 })

aa(
  b({ # NO ERROR: CallExpression args not linted by default
   c: d, # ->
   e: f, # ->
   f: g  # ->
    }) # <-
)

aaaaaa(
  b,
  c,
  {
    d: a
  }
)

a(b, c,
  d, e,
    f, g  # NO ERROR: alignment of arguments of callExpression not checked
  )  # <-

a(
  ) # <-

aaaaaa(
  b,
  c, {
    d: a
  }, {
    e: f
  }
)

a.b()
  .c(->
    a
  ).d.e

if a == 'b'
  if c and d then e = f
  else g('h').i('j')

a = (b, c) ->
  return a ->
    d = e
    f = g
    h = i

    unless j then k 'l', (m = n)
    if o then p
    else if q then r

a = ->
  "b"
    .replace(/a/, "a")
    .replace(/bc?/, (e) ->
      return "b" + (if e.f is 2 then "c" else "f")
    )
    .replace(/d/, "d")

$(b)
  .on 'a', 'b', -> $(c).e('f')
  .on 'g', 'h', -> $(i).j('k')

a
  .b('c',
           'd') # NO ERROR: CallExpression args not linted by default

a
  .b('c', [ 'd', (e) ->
    e++
  ])

# holes in arrays indentation
x = [
 1,
 1,
 1,
 1,
 1,
 1,
 1,
 1,
 1,
 1
]

try
   a++ # <-
   b++ # <-
   c++ # <-
catch d
 e++ # ->
 f++ # ->
 g++ # ->
finally
    h++ # <-
    i++ # <-
    j++ # <-

if array.some(->
  return true
)
  a++
  b++
  c++

switch yes
  when a and
      b
   ; # ->
  when (c &&
  d)
    ;
  when (g
&& h)
      i = j # <-
      k = l # <-
      m = n # <-

if a
  b()
else
 c() # ->
 d() # ->
 e() # ->

if a then b()
else
    c() # <-
    d() # <-
    e() # <-

if a
  b()
else c()

a()

if( "very very long multi line" +
      "with weird indentation" )
    b() # <-
    a() # <-
    c() # <-

a( "very very long multi line" +
    "with weird indentation", function() {
  b()
a() # ->
    c() # <-
    }) # <-

a = function(content, dom) {
  b()
    c() # <-
d() # ->
}

a = function(content, dom) {
      b()
        c() # <-
    d() # ->
    }

a = function(content, dom) {
    b() # ->
    }

a = function(content, dom) {
b() # ->
    }

a('This is a terribly long description youll ' +
  'have to read', function () {
    b() # <-
    c() # <-
  }) # <-

if (
  array.some(function(){
    return true
  })
) {
a++ # ->
  b++
    c++ # <-
}

function c(d) {
  return {
    e: function(f, g) {
    }
  }
}

function a(b) {
  switch(x) {
    when 1
      if (foo) {
        return 5
      }
  }
}

function a(b) {
  switch(x) {
    when 1
      c
  }
}

function a(b) {
  switch(x) {
    when 1: c
  }
}

function test() {
  a = 1
  {
    a()
  }
}

{
  a()
}

function a(b) {
  switch(x) {
    when 1
        { # <-
      a() # ->
      }
      break
    default
      {
        b()
        }
  }
}

switch (a) {
  default
    if (b)
      c()
}

function test(x) {
  switch (x) {
    when 1
      return function() {
        a = 5
        return a
      }
  }
}

switch (a) {
  default
    if (b)
      c()
}
