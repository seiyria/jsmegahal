
class Quad

	constructor: (@tokens) ->
		@canStart = false
		@canEnd = false

	hash: () -> 
		@tokens.join ','

module.exports = exports = Quad