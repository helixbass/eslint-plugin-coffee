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
npm i --save-dev coffeescript@^2.5.0 eslint@^6.0.0
```

Then install the plugin:

```
npm i --save-dev eslint-plugin-coffee
```

If you want to use rules from `eslint-plugin-react`, `eslint-plugin-import` and/or `eslint-plugin-react-native`
(whether rules that "just work" or CoffeeScript custom overrides), install supported versions of those dependencies:

```
npm i --save-dev eslint-plugin-react
npm i --save-dev eslint-plugin-import
npm i --save-dev eslint-plugin-react-native
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

## Supported Rules

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
