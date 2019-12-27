###*
# @flow
###

# type ESLintTestRunnerTestCase = {
#   code: string,
#   errors: ?Array<{ message: string, type: string }>,
#   options: ?Array<mixed>,
#   parserOptions: ?Array<mixed>
# };

# export default function ruleOptionsMapperFactory(ruleOptions: Array<mixed> = []) {
exports.default = (ruleOptions) -> ({code, errors, options, parserOptions}) -> {
  code
  errors
  # Flatten the array of objects in an array of one object.
  options:
    (options or [])
    .concat ruleOptions
    .reduce(
      (acc, item) -> [
        {
          ...acc[0]
          ...item
        }
      ]
    ,
      [{}]
    )
  parserOptions
}
