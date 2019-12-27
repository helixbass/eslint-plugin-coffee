### eslint-env jest ###
###*
# @fileoverview <audio> and <video> elements must have a <track> for captions.
# @author Ethan Cohen
###

# -----------------------------------------------------------------------------
# Requirements
# -----------------------------------------------------------------------------

path = require 'path'
{RuleTester} = require 'eslint'
{
  default: parserOptionsMapper
} = require '../eslint-plugin-jsx-a11y-parser-options-mapper'
rule = require 'eslint-plugin-jsx-a11y/lib/rules/media-has-caption'

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

ruleTester = new RuleTester parser: path.join __dirname, '../../..'

expectedError =
  message:
    'Media elements such as <audio> and <video> must have a <track> for captions.'
  type: 'JSXOpeningElement'

customSchema = [
  audio: ['Audio']
  video: ['Video']
  track: ['Track']
]

ruleTester.run 'media-has-caption', rule,
  valid: [
    code: '<div />'
  ,
    code: '<MyDiv />'
  ,
    code: '<audio><track kind="captions" /></audio>'
  ,
    code: '<audio><track kind="Captions" /></audio>'
  ,
    code: '<audio><track kind="Captions" /><track kind="subtitles" /></audio>'
  ,
    code: '<video><track kind="captions" /></video>'
  ,
    code: '<video><track kind="Captions" /></video>'
  ,
    code: '<video><track kind="Captions" /><track kind="subtitles" /></video>'
  ,
    code: '<audio muted={true}></audio>'
  ,
    code: '<video muted={true}></video>'
  ,
    code: '<video muted></video>'
  ,
    code: '<Audio><track kind="captions" /></Audio>'
    options: customSchema
  ,
    code: '<audio><Track kind="captions" /></audio>'
    options: customSchema
  ,
    code: '<Video><track kind="captions" /></Video>'
    options: customSchema
  ,
    code: '<video><Track kind="captions" /></video>'
    options: customSchema
  ,
    code: '<Audio><Track kind="captions" /></Audio>'
    options: customSchema
  ,
    code: '<Video><Track kind="captions" /></Video>'
    options: customSchema
  ,
    code: '<Video muted></Video>'
    options: customSchema
  ,
    code: '<Video muted={true}></Video>'
    options: customSchema
  ,
    code: '<Audio muted></Audio>'
    options: customSchema
  ,
    code: '<Audio muted={true}></Audio>'
    options: customSchema
  ].map parserOptionsMapper
  invalid: [
    code: '<audio><track /></audio>', errors: [expectedError]
  ,
    code: '<audio><track kind="subtitles" /></audio>'
    errors: [expectedError]
  ,
    code: '<audio />', errors: [expectedError]
  ,
    code: '<video><track /></video>', errors: [expectedError]
  ,
    code: '<video><track kind="subtitles" /></video>'
    errors: [expectedError]
  ,
    code: '<Audio muted={false}></Audio>'
    options: customSchema
    errors: [expectedError]
  ,
    code: '<Video muted={false}></Video>'
    options: customSchema
    errors: [expectedError]
  ,
    code: '<video />', errors: [expectedError]
  ,
    code: '<audio>Foo</audio>', errors: [expectedError]
  ,
    code: '<video>Foo</video>', errors: [expectedError]
  ,
    code: '<Audio />', options: customSchema, errors: [expectedError]
  ,
    code: '<Video />', options: customSchema, errors: [expectedError]
  ,
    code: '<audio><Track /></audio>'
    options: customSchema
    errors: [expectedError]
  ,
    code: '<video><Track /></video>'
    options: customSchema
    errors: [expectedError]
  ,
    code: '<Audio><Track kind="subtitles" /></Audio>'
    options: customSchema
    errors: [expectedError]
  ,
    code: '<Video><Track kind="subtitles" /></Video>'
    options: customSchema
    errors: [expectedError]
  ].map parserOptionsMapper
