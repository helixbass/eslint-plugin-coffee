###*
# @fileoverview Tests for arrow-spacing
# @author Jxck
###
'use strict'

#------------------------------------------------------------------------------
# Requirements
#------------------------------------------------------------------------------
#

rule = require '../../rules/arrow-spacing'
{RuleTester} = require 'eslint'
path = require 'path'

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

valid = [
  code: '(a) => a'
  options: [after: yes, before: yes]
,
  code: '(a) -> a'
  options: [after: yes, before: yes]
,
  code: '() => {}'
  options: [after: yes, before: yes]
,
  code: '=> {}'
  options: [after: yes, before: yes]
,
  code: 'f ->'
  options: [after: yes, before: yes]
,
  code: 'f(->)'
  options: [after: yes, before: yes]
,
  code: 'f(->, b)'
  options: [after: yes, before: yes]
,
  code: '''
    f ->
    .b
  '''
  options: [after: yes, before: yes]
,
  code: '(a) => {}'
  options: [after: yes, before: yes]
,
  code: '(a)=> a'
  options: [after: yes, before: no]
,
  code: '()=> {}'
  options: [after: yes, before: no]
,
  code: '(a)=> {}'
  options: [after: yes, before: no]
,
  code: '(a) =>a'
  options: [after: no, before: yes]
,
  code: '() =>{}'
  options: [after: no, before: yes]
,
  code: '(a) =>{}'
  options: [after: no, before: yes]
,
  code: '(a)=>a'
  options: [after: no, before: no]
,
  code: '()=>{}'
  options: [after: no, before: no]
,
  code: '(a)=>{}'
  options: [after: no, before: no]
,
  code: '(a) => a'
  options: [{}]
,
  code: '() => {}'
  options: [{}]
,
  code: '(a) => {}'
  options: [{}]
,
  '(a) =>\n  {}'
  '(a) =>\r\n  {}'
  '(a) =>\n    0'
,
  code: '(a)  =>\n  {}'
  options: [after: no]
,
  '-> -> b'
  '=> => b'
]

invalid = [
  code: '(a)=>a'
  output: '(a) => a'
  options: [after: yes, before: yes]
  errors: [
    column: 3, line: 1, type: 'Punctuator', messageId: 'expectedBefore'
  ,
    column: 6, line: 1, type: 'Identifier', messageId: 'expectedAfter'
  ]
,
  code: '(a)->a'
  output: '(a) -> a'
  options: [after: yes, before: yes]
  errors: [
    column: 3, line: 1, type: 'Punctuator', messageId: 'expectedBefore'
  ,
    column: 6, line: 1, type: 'Identifier', messageId: 'expectedAfter'
  ]
,
  code: '()=>{}'
  output: '() => {}'
  options: [after: yes, before: yes]
  errors: [
    column: 2, line: 1, type: 'Punctuator', messageId: 'expectedBefore'
  ,
    column: 5, line: 1, type: 'Punctuator', messageId: 'expectedAfter'
  ]
,
  code: 'f(=>{})'
  output: 'f(=> {})'
  options: [after: yes, before: yes]
  errors: [column: 5, line: 1, type: 'Punctuator', messageId: 'expectedAfter']
,
  code: '(a)=>{}'
  output: '(a) => {}'
  options: [after: yes, before: yes]
  errors: [
    column: 3, line: 1, type: 'Punctuator', messageId: 'expectedBefore'
  ,
    column: 6, line: 1, type: 'Punctuator', messageId: 'expectedAfter'
  ]
,
  code: '(a)=> a'
  output: '(a) =>a'
  options: [after: no, before: yes]
  errors: [
    column: 3, line: 1, type: 'Punctuator', messageId: 'expectedBefore'
  ,
    column: 7, line: 1, type: 'Identifier', messageId: 'unexpectedAfter'
  ]
,
  code: '()=> {}'
  output: '() =>{}'
  options: [after: no, before: yes]
  errors: [
    column: 2, line: 1, type: 'Punctuator', messageId: 'expectedBefore'
  ,
    column: 6, line: 1, type: 'Punctuator', messageId: 'unexpectedAfter'
  ]
,
  code: '(a)=> {}'
  output: '(a) =>{}'
  options: [after: no, before: yes]
  errors: [
    column: 3, line: 1, type: 'Punctuator', messageId: 'expectedBefore'
  ,
    column: 7, line: 1, type: 'Punctuator', messageId: 'unexpectedAfter'
  ]
,
  code: '()=>  {}'
  output: '() =>{}'
  options: [after: no, before: yes]
  errors: [
    column: 2, line: 1, type: 'Punctuator', messageId: 'expectedBefore'
  ,
    column: 7, line: 1, type: 'Punctuator', messageId: 'unexpectedAfter'
  ]
,
  code: '(a)=>  {}'
  output: '(a) =>{}'
  options: [after: no, before: yes]
  errors: [
    column: 3, line: 1, type: 'Punctuator', messageId: 'expectedBefore'
  ,
    column: 8, line: 1, type: 'Punctuator', messageId: 'unexpectedAfter'
  ]
,
  code: '(a) =>a'
  output: '(a)=> a'
  options: [after: yes, before: no]
  errors: [
    column: 3, line: 1, type: 'Punctuator', messageId: 'unexpectedBefore'
  ,
    column: 7, line: 1, type: 'Identifier', messageId: 'expectedAfter'
  ]
,
  code: '() =>{}'
  output: '()=> {}'
  options: [after: yes, before: no]
  errors: [
    column: 2, line: 1, type: 'Punctuator', messageId: 'unexpectedBefore'
  ,
    column: 6, line: 1, type: 'Punctuator', messageId: 'expectedAfter'
  ]
,
  code: '(a) =>{}'
  output: '(a)=> {}'
  options: [after: yes, before: no]
  errors: [
    column: 3, line: 1, type: 'Punctuator', messageId: 'unexpectedBefore'
  ,
    column: 7, line: 1, type: 'Punctuator', messageId: 'expectedAfter'
  ]
,
  code: '(a)  =>a'
  output: '(a)=> a'
  options: [after: yes, before: no]
  errors: [
    column: 3, line: 1, type: 'Punctuator', messageId: 'unexpectedBefore'
  ,
    column: 8, line: 1, type: 'Identifier', messageId: 'expectedAfter'
  ]
,
  code: '()  =>{}'
  output: '()=> {}'
  options: [after: yes, before: no]
  errors: [
    column: 2, line: 1, type: 'Punctuator', messageId: 'unexpectedBefore'
  ,
    column: 7, line: 1, type: 'Punctuator', messageId: 'expectedAfter'
  ]
,
  code: '(a)  =>{}'
  output: '(a)=> {}'
  options: [after: yes, before: no]
  errors: [
    column: 3, line: 1, type: 'Punctuator', messageId: 'unexpectedBefore'
  ,
    column: 8, line: 1, type: 'Punctuator', messageId: 'expectedAfter'
  ]
,
  code: '(a) => a'
  output: '(a)=>a'
  options: [after: no, before: no]
  errors: [
    column: 3, line: 1, type: 'Punctuator', messageId: 'unexpectedBefore'
  ,
    column: 8, line: 1, type: 'Identifier', messageId: 'unexpectedAfter'
  ]
,
  code: '() => {}'
  output: '()=>{}'
  options: [after: no, before: no]
  errors: [
    column: 2, line: 1, type: 'Punctuator', messageId: 'unexpectedBefore'
  ,
    column: 7, line: 1, type: 'Punctuator', messageId: 'unexpectedAfter'
  ]
,
  code: '(a) => {}'
  output: '(a)=>{}'
  options: [after: no, before: no]
  errors: [
    column: 3, line: 1, type: 'Punctuator', messageId: 'unexpectedBefore'
  ,
    column: 8, line: 1, type: 'Punctuator', messageId: 'unexpectedAfter'
  ]
,
  code: '(a)  =>  a'
  output: '(a)=>a'
  options: [after: no, before: no]
  errors: [
    column: 3, line: 1, type: 'Punctuator', messageId: 'unexpectedBefore'
  ,
    column: 10, line: 1, type: 'Identifier', messageId: 'unexpectedAfter'
  ]
,
  code: '()  =>  {}'
  output: '()=>{}'
  options: [after: no, before: no]
  errors: [
    column: 2, line: 1, type: 'Punctuator', messageId: 'unexpectedBefore'
  ,
    column: 9, line: 1, type: 'Punctuator', messageId: 'unexpectedAfter'
  ]
,
  code: '(a)  =>  {}'
  output: '(a)=>{}'
  options: [after: no, before: no]
  errors: [
    column: 3, line: 1, type: 'Punctuator', messageId: 'unexpectedBefore'
  ,
    column: 10, line: 1, type: 'Punctuator', messageId: 'unexpectedAfter'
  ]
,
  # https://github.com/eslint/eslint/issues/7079
  code: '(a = ()=>0)=>1'
  output: '(a = () => 0) => 1'
  errors: [
    column: 7, line: 1, messageId: 'expectedBefore'
  ,
    column: 10, line: 1, messageId: 'expectedAfter'
  ,
    column: 11, line: 1, messageId: 'expectedBefore'
  ,
    column: 14, line: 1, messageId: 'expectedAfter'
  ]
,
  code: '(a = ()=>0)=>(1)'
  output: '(a = () => 0) => (1)'
  errors: [
    column: 7, line: 1, messageId: 'expectedBefore'
  ,
    column: 10, line: 1, messageId: 'expectedAfter'
  ,
    column: 11, line: 1, messageId: 'expectedBefore'
  ,
    column: 14, line: 1, messageId: 'expectedAfter'
  ]
,
  code: '->->1'
  output: '-> -> 1'
  errors: [
    column: 3, line: 1, messageId: 'expectedAfter'
  ,
    column: 5, line: 1, messageId: 'expectedAfter'
  ]
,
  code: '=>=>1'
  output: '=> => 1'
  errors: [
    column: 3, line: 1, messageId: 'expectedAfter'
  ,
    column: 5, line: 1, messageId: 'expectedAfter'
  ]
]

ruleTester.run 'arrow-spacing', rule, {
  valid
  invalid
}
