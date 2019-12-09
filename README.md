# eslint-plugin-coffee
ESLint custom parser + rules for linting CoffeeScript source files

## Table of Contents

- [Getting Started](#getting-started)
- [Why does this project exist?](#why-does-this-project-exist)
- [How does eslint-plugin-coffee work?](#how-does-eslint-plugin-coffee-work)
- [Can I use all of the existing ESLint plugins and rules without any changes?](#can-i-use-all-of-the-existing-eslint-plugins-and-rules-without-any-changes)
- [Installation](#installation)
- [Usage](#usage)
- [Usage with Prettier](#usage-with-prettier)
- [Supported Rules](#supported-rules)
- [Supported CoffeeScript version](#supported-coffeescript-version)
- [Supported ESLint version](#supported-eslint-version)
- [Supported versions of eslint-plugin-import, eslint-plugin-react, eslint-plugin-react-native](#supported-versions-of-eslint-plugin-import-eslint-plugin-react-eslint-plugin-react-native)
- [How can I help?](#how-can-i-help)
- [License](#license)

## Getting Started

The following sections will give you an overview of what this project is, why it exists and how it works.

If you are ready to get started you can jump to [Installation](#installation).

## Why does this project exist?

ESLint is the preeminent linter in the JavaScript world.

As of [CoffeeScript v2.5.0](http://coffeescript.org/), the CoffeeScript compiler exposes an Abstract Syntax Tree (AST) representation
of your source code which enables usage with AST-based tools like ESLint.

`eslint-plugin-coffee` is the package that allows you to use ESLint in CoffeeScript-based projects :sparkles: :rainbow: :sparkles:

## How does `eslint-plugin-coffee` work?

The AST (see above) produced by CoffeeScript is different than the AST format that ESLint requires to work.

This means that by default, the CoffeeScript AST is not compatible with the 1000s of rules which have been written
by and for ESLint users over the many years the project has been going.

The great thing is, though, we can provide ESLint with an alternative parser to use - that is a first-class use case
offered by ESLint. `eslint-plugin-coffee` provides ESLint with that alternative parser for CoffeeScript.

At that point, ESLint is capable of "digesting" CoffeeScript source code. But what about the rules? Keep reading...

## Can I use all of the existing ESLint plugins and rules without any changes?

The short answer is, no.

The great news is, **there are many rules which will "just work"** without you having to change anything about them
or provide any custom alternatives.

For rules which don't "just work" for CoffeeScript, `eslint-plugin-coffee` aims to provide a CoffeeScript-compatible
custom alternative rule - this includes rules that come with ESLint, as well as from the popular ESLint plugins
[`eslint-plugin-react`](https://github.com/yannickcr/eslint-plugin-react), [`eslint-plugin-import`](https://github.com/benmosher/eslint-plugin-import),
and [`eslint-plugin-react-native`](https://github.com/intellicode/eslint-plugin-react-native).

**Here's a [guide to all of the supported rules](#supported-rules).**

## Installation

Make sure you have supported versions of CoffeeScript and ESLint installed:

```
npm install --save-dev coffeescript@^2.5.0 eslint@^6.0.0
```

Then install the plugin:

```
npm install --save-dev eslint-plugin-coffee
```

## Usage

Add `eslint-plugin-coffee` to the `parser` field and `coffee` to the plugins section of your `.eslintrc` configuration file:

```
{
  "parser": "eslint-plugin-coffee",
  "plugins": ["coffee"]
}
```

Then configure the rules you want to use under the rules section.
```
{
  "parser": "eslint-plugin-coffee",
  "plugins": ["coffee"],
  "rules": {
    // Can include existing rules that "just work":
    "no-undef": "error",
    "react/no-array-index-key": "error",
    // ...CoffeeScript-specific rules:
    "coffee/spread-direction": ["error", "postfix"],
    // ...and CoffeeScript custom overriding rules.
    // For these, the corresponding existing rule should also be disabled if need be:
    "no-unused-vars": "off",
    "coffee/no-unused-vars": "error"
}
```

You can also use [eslint:recommended](https://eslint.org/docs/rules/) (the set of rules which are recommended for all
projects by the ESLint team) with this plugin. As noted [above](#can-i-use-all-of-the-existing-eslint-plugins-and-rules-without-any-changes), not all ESLint core rules are compatible with CoffeeScript, so you need to add both `eslint:recommended` and `plugin:coffee/eslint-recommended` (which will adjust the one from ESLint appropriately for CoffeeScript) to your config:

```
{
  "extends": [
    "eslint:recommended",
    "plugin:coffee/eslint-recommended"
  ]
}
```

If you want to use rules from `eslint-plugin-react`, `eslint-plugin-import` and/or `eslint-plugin-react-native`
(whether rules that "just work" or CoffeeScript custom overrides), install supported versions of those dependencies:

```
npm install --save-dev eslint-plugin-react
npm install --save-dev eslint-plugin-import
npm install --save-dev eslint-plugin-react-native
```

And correspondingly add those plugins and rules to your config:
```
{
  "plugins": [
    "coffee",
    "react",
    "import",
    "react-native"
  ],
  "rules": {
    // Can include existing rules that "just work":
    "react/no-array-index-key": "error",
    "import/prefer-default-export": "error",
    "react-native/no-inline-styles": "error",
    // ...and CoffeeScript custom overriding rules.
    // For these, the corresponding existing rule should also be disabled if need be:
    "react/prop-types": "off",
    "coffee/prop-types": "error",
    "import/no-anonymous-default-export": "off",
    "coffee/no-anonymous-default-export": "error",
    "react-native/no-unused-styles": "off",
    "coffee/no-unused-styles": "error",
  }
} 
```

### Running from the command line

To invoke ESLint from the command line, you can add an appropriate script to your `package.json` scripts section, for example:

```
{
  "scripts": {
    "lint": "eslint 'src/**/*.coffee'",
    "lint-fix": "eslint --fix 'src/**/*.coffee'"
  }
}
```

Then you can invoke those scripts as needed from the command line to lint the CoffeeScript source files in your project:
```
npm run lint
```

### Running from your editor

Running ESLint directly from your code editor (e.g. on save) provides a quick feedback loop while developing.

Depending on your editor, there may or may not currently be a straightforward way to get ESLint running against `.coffee` files (e.g. using an ESLint editor plugin).

If you're having trouble getting ESLint running in your editor (and it's not listed below), please [file an issue](https://github.com/coffeescript/eslint-plugin-coffee/issues) and we'll try and help with support for your editor.

We will add instructions for different code editors here as they become supported.

If you've gotten ESLint running in an editor not listed here and would like to share back, please [file an issue](https://github.com/coffeescript/eslint-plugin-coffee/issues)!

## Usage with Prettier

To disable our code formatting related rules, install [`eslint-config-prettier`](https://github.com/prettier/eslint-config-prettier):

```
npm install --save-dev eslint-config-prettier
```

Then use the `prettier` config exposed by this plugin:
```
{
  "extends": ["plugin:coffee/prettier"]
}
```

Alternatively, if you want to run Prettier as an ESLint rule (a nice option especially if you're running ESLint in fix mode
via your editor):

```
npm install --save-dev eslint-config-prettier eslint-plugin-prettier
```

Then use the `prettier-run-as-rule` config exposed by this plugin:
```
{
  "extends": ["plugin:coffee/prettier-run-as-rule"]
}
```

## Supported Rules

**Key**: :heavy_check_mark: = ESLint recommended, :wrench: = fixable

### ESLint-included rules

#### Possible Errors

|                    |          | Name                                    | Description |
| ------------------ | -------- | --------------------------------------- | ----------- |
| :heavy_check_mark: |          | [`coffee/no-async-promise-executor`](https://eslint.org/docs/rules/no-async-promise-executor)   | disallow using an async function as a Promise executor |
|                    |          | [`coffee/no-await-in-loop`](https://eslint.org/docs/rules/no-await-in-loop) | disallow `await` inside of loops |
| :heavy_check_mark: |          | [`coffee/no-compare-neg-zero`](https://eslint.org/docs/rules/no-compare-neg-zero) | disallow comparing against -0 |
| :heavy_check_mark: |          | [`coffee/no-cond-assign`](https://eslint.org/docs/rules/no-cond-assign) | disallow assignment operators in conditional expressions |
|                    |          | [`no-console`](https://eslint.org/docs/rules/no-console) | disallow the use of `console` |
| :heavy_check_mark: |          | [`coffee/no-constant-condition`](https://eslint.org/docs/rules/no-constant-condition) | disallow constant expressions in conditions |
| :heavy_check_mark: |          | [`no-control-regex`](https://eslint.org/docs/rules/no-control-regex) | disallow control characters in regular expressions |
| :heavy_check_mark: |          | [`no-debugger`](https://eslint.org/docs/rules/no-debugger) | disallow the use of `debugger` |
| :heavy_check_mark: |          | [`no-dupe-keys`](https://eslint.org/docs/rules/no-dupe-keys) | disallow duplicate keys in object literals |
| :heavy_check_mark: |          | [`no-duplicate-case`](https://eslint.org/docs/rules/no-duplicate-case) | disallow duplicate case labels |
| :heavy_check_mark: |          | [`no-empty`](https://eslint.org/docs/rules/no-empty) | disallow empty block statements |
| :heavy_check_mark: |          | [`coffee/no-empty-character-class`](https://eslint.org/docs/rules/no-empty-character-class) | disallow empty character classes in regular expressions |
| :heavy_check_mark: |          | [`no-ex-assign`](https://eslint.org/docs/rules/no-ex-assign) | disallow reassigning exceptions in `catch` clauses |
| :heavy_check_mark: |          | [`coffee/no-extra-boolean-cast`](https://eslint.org/docs/rules/no-extra-boolean-cast) | disallow unnecessary boolean casts <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
| :heavy_check_mark: |          | [`coffee/no-inner-declarations`](https://eslint.org/docs/rules/no-inner-declarations) | disallow variable or `function` "declarations" in nested blocks |
| :heavy_check_mark: |          | [`no-invalid-regexp`](https://eslint.org/docs/rules/no-invalid-regexp) | disallow invalid regular expression strings in `RegExp` constructors |
| :heavy_check_mark: |          | [`no-irregular-whitespace`](https://eslint.org/docs/rules/no-irregular-whitespace) | disallow irregular whitespace |
| :heavy_check_mark: |          | [`no-misleading-character-class`](https://eslint.org/docs/rules/no-misleading-character-class) | disallow characters which are made with multiple code points in character class syntax |
| :heavy_check_mark: |          | [`no-obj-calls`](https://eslint.org/docs/rules/no-obj-calls) | disallow calling global object properties as functions |
| :heavy_check_mark: |          | [`no-prototype-builtins`](https://eslint.org/docs/rules/no-prototype-builtins) | disallow calling some `Object.prototype` methods directly on objects |
| :heavy_check_mark: | :wrench: | [`coffee/no-regex-spaces`](https://eslint.org/docs/rules/no-regex-spaces) | disallow multiple spaces in regular expressions |
| :heavy_check_mark: |          | [`no-sparse-arrays`](https://eslint.org/docs/rules/no-sparse-arrays) | disallow sparse arrays |
|                    |          | [`coffee/no-template-curly-in-string`](https://eslint.org/docs/rules/no-template-curly-in-string) | disallow template literal placeholder syntax in regular strings |
| :heavy_check_mark: |          | [`coffee/no-unreachable`](https://eslint.org/docs/rules/no-unreachable) | disallow unreachable code after `return`, `throw`, `continue`, and `break` statements |
| :heavy_check_mark: |          | [`no-unsafe-finally`](https://eslint.org/docs/rules/no-unsafe-finally) | disallow control flow statements in `finally` blocks |
| :heavy_check_mark: |          | [`coffee/no-unsafe-negation`](https://eslint.org/docs/rules/no-unsafe-negation) | disallow negating the left operand of relational operators |
| :heavy_check_mark: |          | [`require-atomic-updates`](https://eslint.org/docs/rules/require-atomic-updates) | disallow assignments that can lead to race conditions due to usage of `await` or `yield` |
| :heavy_check_mark: |          | [`coffee/use-isnan`](https://eslint.org/docs/rules/use-isnan) | require calls to `isNaN()` when checking for `NaN` |
| :heavy_check_mark: |          | [`coffee/valid-typeof`](https://eslint.org/docs/rules/valid-typeof) | enforce comparing `typeof` expressions against valid strings |

#### Best Practices

|                    |          | Name                                    | Description |
| ------------------ | -------- | --------------------------------------- | ----------- |
|                    |          | [`accessor-pairs`](https://eslint.org/docs/rules/accessor-pairs) | enforce getter and setter pairs in objects and classes <br> :warning: Only checks e.g. `Object.defineProperty()` since CoffeeScript doesn't support getters/setters |
|                    |          | [`coffee/block-scoped-var`](https://eslint.org/docs/rules/block-scoped-var) | enforce the use of variables within the scope they are defined |
|                    |          | [`coffee/class-methods-use-this`](https://eslint.org/docs/rules/class-methods-use-this) | enforce that class methods utilize `this` |
|                    |          | [`coffee/complexity`](https://eslint.org/docs/rules/complexity) | enforce a maximum cyclomatic complexity allowed in a program |
|                    |          | [`default-case`](https://eslint.org/docs/rules/default-case) | require `else` cases in `switch` statements |
|                    | :wrench: | [`dot-location`](https://eslint.org/docs/rules/dot-location) | enforce consistent newlines before and after dots |
|                    | :wrench: | [`coffee/dot-notation`](https://eslint.org/docs/rules/dot-notation) | enforce dot notation whenever possible |
|                    |          | [`coffee/guard-for-in`](https://eslint.org/docs/rules/guard-for-in) | require `for-of` loops to include `own` or an `if` statement |
|                    |          | [`max-classes-per-file`](https://eslint.org/docs/rules/max-classes-per-file) | enforce a maximum number of classes per file |
|                    |          | [`no-alert`](https://eslint.org/docs/rules/no-alert) | disallow the use of `alert`, `confirm`, and `prompt` |
|                    |          | [`no-caller`](https://eslint.org/docs/rules/no-caller) | disallow the use of `arguments.caller` or `arguments.callee` |
|                    | :wrench: | [`coffee/no-div-regex`](https://eslint.org/docs/rules/no-div-regex) | disallow division operators explicitly at the beginning of regular expressions |
|                    |          | [`coffee/no-else-return`](https://eslint.org/docs/rules/no-else-return) | disallow `else` blocks after `return` statements in `if` statements <br> :warning: Unlike the ESLint rule, the CoffeeScript version is not fixable |
|                    |          | [`coffee/no-empty-function`](https://eslint.org/docs/rules/no-empty-function) | disallow empty functions |
| :heavy_check_mark: |          | [`no-empty-pattern`](https://eslint.org/docs/rules/no-empty-pattern) | disallow empty destructuring patterns |
|                    |          | [`no-eval`](https://eslint.org/docs/rules/no-eval) | disallow the use of `eval()` |
|                    |          | [`no-extend-native`](https://eslint.org/docs/rules/no-extend-native) | disallow extending native types |
|                    | :wrench: | [`coffee/no-extra-bind`](https://eslint.org/docs/rules/no-extra-bind) | disallow unnecessary calls to `.bind()` |
|                    | :wrench: | [`no-floating-decimal`](https://eslint.org/docs/rules/no-floating-decimal) | disallow leading or trailing decimal points in numeric literals |
| :heavy_check_mark: |          | [`no-global-assign`](https://eslint.org/docs/rules/no-global-assign) | disallow assignments to native objects or read-only global variables <br> :warning: Only applies to e.g. `++` operations since CoffeeScript generates declarations on other write references. |
|                    | :wrench: | [`coffee/no-implicit-coercion`](https://eslint.org/docs/rules/no-implicit-coercion) | disallow shorthand type conversions |
|                    |          | [`no-implied-eval`](https://eslint.org/docs/rules/no-implied-eval) | disallow the use of `eval()`-like methods |
|                    |          | [`coffee/no-invalid-this`](https://eslint.org/docs/rules/no-invalid-this) | disallow `this` keywords outside of classes or class-like objects |
|                    |          | [`no-iterator`](https://eslint.org/docs/rules/no-iterator) | disallow the use of the `__iterator__` property |
|                    |          | [`coffee/no-loop-func`](https://eslint.org/docs/rules/no-loop-func) | disallow function declarations that contain unsafe references inside loop statements |
|                    |          | [`coffee/no-magic-numbers`](https://eslint.org/docs/rules/no-magic-numbers) | disallow magic numbers |
|                    | :wrench: | [`coffee/no-multi-spaces`](https://eslint.org/docs/rules/no-multi-spaces) | disallow multiple spaces |
|                    |          | [`no-multi-str`](https://eslint.org/docs/rules/no-multi-str) | disallow multiline strings |
|                    |          | [`no-new`](https://eslint.org/docs/rules/no-new) | disallow `new` operators outside of assignments or comparisons |
|                    |          | [`no-new-func`](https://eslint.org/docs/rules/no-new-func) | disallow `new` operators with the `Function` object |
|                    |          | [`no-new-wrappers`](https://eslint.org/docs/rules/no-new-wrappers) | disallow `new` operators with the `String`, `Number`, and `Boolean` objects |
|                    |          | [`no-param-reassign`](https://eslint.org/docs/rules/no-param-reassign) | disallow reassigning `function` parameters |
|                    |          | [`no-proto`](https://eslint.org/docs/rules/no-proto) | disallow the use of the `__proto__` property |
|                    |          | [`no-restricted-properties`](https://eslint.org/docs/rules/no-restricted-properties) | disallow certain properties on certain objects |
|                    |          | [`coffee/no-return-assign`](https://eslint.org/docs/rules/no-return-assign) | disallow assignment operators in `return` statements <br> :warning: Currently, this also flags assignments in implicit return statements |
|                    |          | [`no-script-url`](https://eslint.org/docs/rules/no-script-url) | disallow `javascript:` urls |
| :heavy_check_mark: |          | [`coffee/no-self-assign`](https://eslint.org/docs/rules/no-self-assign) | disallow assignments where both sides are exactly the same |
|                    |          | [`coffee/no-self-compare`](https://eslint.org/docs/rules/no-self-compare) | disallow comparisons where both sides are exactly the same |
|                    |          | [`coffee/no-sequences`](https://eslint.org/docs/rules/no-sequences) | disallow semicolon operators |
|                    |          | [`no-throw-literal`](https://eslint.org/docs/rules/no-throw-literal) | disallow throwing literals as exceptions |
|                    |          | [`coffee/no-unmodified-loop-condition`](https://eslint.org/docs/rules/no-unmodified-loop-condition) | disallow unmodified loop conditions |
|                    |          | [`coffee/no-unused-expressions`](https://eslint.org/docs/rules/no-unused-expressions) | disallow unused expressions |
|                    |          | [`no-useless-call`](https://eslint.org/docs/rules/no-useless-call) | disallow unnecessary calls to `.call()` and `.apply()` |
|                    |          | [`no-useless-concat`](https://eslint.org/docs/rules/no-useless-concat) | disallow unnecessary concatenation of literals or template literals |
| :heavy_check_mark: |          | [`coffee/no-useless-escape`](https://eslint.org/docs/rules/no-useless-escape) | disallow unnecessary escape characters |
|                    | :wrench: | [`coffee/no-useless-return`](https://eslint.org/docs/rules/no-useless-return) | disallow redundant return statements |
|                    |          | [`no-warning-comments`](https://eslint.org/docs/rules/no-warning-comments) | disallow specified warning terms in comments |

### Non-applicable ESLint-included rules

Some rules included with ESLint don't apply to CoffeeScript. These include:

- [`for-direction`](https://eslint.org/docs/rules/for-direction)
- [`getter-return`](https://eslint.org/docs/rules/getter-return)
- [`no-dupe-args`](https://eslint.org/docs/rules/no-dupe-args)
- [`no-extra-semi`](https://eslint.org/docs/rules/no-extra-semi)
- [`no-func-assign`](https://eslint.org/docs/rules/no-func-assign)
- [`no-unexpected-multiline`](https://eslint.org/docs/rules/no-unexpected-multiline)
- [`array-callback-return`](https://eslint.org/docs/rules/array-callback-return)
- [`consistent-return`](https://eslint.org/docs/rules/consistent-return)
- [`curly`](https://eslint.org/docs/rules/curly)
- [`eqeqeq`](https://eslint.org/docs/rules/eqeqeq)
- [`no-case-declarations`](https://eslint.org/docs/rules/no-case-declarations)
- [`no-eq-null`](https://eslint.org/docs/rules/no-eq-null)
- [`no-extra-label`](https://eslint.org/docs/rules/no-extra-label)
- [`no-fallthrough`](https://eslint.org/docs/rules/no-fallthrough)
- [`no-implicit-globals`](https://eslint.org/docs/rules/no-implicit-globals)
- [`no-labels`](https://eslint.org/docs/rules/no-labels)
- [`no-lone-blocks`](https://eslint.org/docs/rules/no-lone-blocks)
- [`no-octal`](https://eslint.org/docs/rules/no-octal)
- [`no-octal-escape`](https://eslint.org/docs/rules/no-octal-escape)
- [`no-redeclare`](https://eslint.org/docs/rules/no-redeclare)
- [`no-unused-labels`](https://eslint.org/docs/rules/no-unused-labels)
- [`no-void`](https://eslint.org/docs/rules/no-void)
- [`no-with`](https://eslint.org/docs/rules/no-with)


## Supported CoffeeScript version

We will always endeavor to support the latest stable version of CoffeeScript.

**The version range of CoffeeScript currently supported by this plugin is `>=2.5.0`.**

## Supported ESLint version

**The version range of ESLint currently supported by this plugin is `>=6.0.0`.**

## Supported versions of `eslint-plugin-import`, `eslint-plugin-react`, `eslint-plugin-react-native`



## How can I help?

See an issue? [Report it](https://github.com/coffeescript/eslint-plugin-coffee/issues)!

If you have the time and inclination, you can even take it a step further and submit a PR to improve the project.

## License

`eslint-plugin-coffee` is licensed under the MIT License.
