

class Quad
	constructor: (@tokens) ->
		@canStart = false
		@canEnd = false

	hash: () -> 
		@tokens.join ','

###
TODO load from a big string
TODO load from a remote URL
TODO more punctuation
###
class jsMegaHal
	#the regex to check the validity of a character
	wordRegex: /[^a-zA-Z0-9,']+/

	#the regex to split sentences by -- remove all \r\n
	sentenceRegex: /[!?\.]/

	#all of the current words jsMegaHal knows
	words: Object.create null

	#all of the quads, mapped by quad.hash() -> quad
	quads: {}

	#all of the quads that can come after a given quad, mapped by quad.hash() -> [quad, quad, ...]
	next: {}

	#all of the quads that can come before a given quad, mapped by quad.hash() -> [quad, quad, ...]
	prev: {}

	###
	@markov - the markov order to use for this jsMegaHal instance, defaults to 4
	###
	constructor: (@markov = 4, @defaultReply = '') ->

	###
	generate a number between min and max, inclusive

	@min the lower bound
	@max the upper bound
	###
	randomInt: (min,max) ->
		return Math.floor Math.random() * (max - min + 1) + min
	
	###
	a convenience method to add a quad to the quads list

	@quad the quad to add to the list
	###
	addQuad: (quad) -> @quads[quad.hash()] = quad if not (quad.hash() of @quads)

	###
	add a lot of text and split it by sentence

	@longSentence a lot of text separated by characters in @sentenceRegex
	###
	addMass: (longSentence) ->
		longSentence.split(@sentenceRegex).forEach (e) =>
			@add e

	###
	add a sentence to jsMegaHal

	@sentence the sentence to add to jsMegaHal. ignored if there are fewer than @markov words in it
	###
	add: (sentence) ->
		sentence = sentence.trim()

		return if sentence.split(' ').length < @markov

		#split the sentence by "words" and then remove any empty values from the array
		parts = sentence.split(@wordRegex).filter Boolean

		partsLength = parts.length

		#split the tokens into quads of @markov length
		for i in [0...partsLength - (@markov - 1)] by 1

			quad = new Quad [ parts[i...i+@markov]... ]
			@addQuad quad

			quad.canStart = (i is 0)
			quad.canEnd = (i is partsLength - @markov)

			#first by word
			for token in quad.tokens
				@words[token] = [] if not (token of @words)
				@words[token].push quad

			#then get the previous tokens
			if i isnt 0
				prevToken = parts[i-1]
				@prev[quad.hash()] = [] if not (quad.hash() of @prev)
				@prev[quad.hash()].push prevToken if not (prevToken in @prev[quad.hash()])

			#and then get the next tokens
			if i < partsLength - @markov
				nextToken = parts[i+@markov]
				@next[quad.hash()] = [] if not (quad.hash() of @next)
				@next[quad.hash()].push nextToken if not (nextToken in @next[quad.hash()])

	###
	generate a reply from a sentence instead of just a word

	@sentence the sentence to pick a token from
	###	
	getReplyFromSentence: (sentence) ->
		tokens = sentence.trim().split(' ')
		@getReply tokens[@randomInt 0, tokens.length-1]

	###
	generate a reply from a single word

	@word the seed word, can be null/undefined
	###
	getReply: (word) ->
		word = word?.trim()
		quads = []

		#if we don't have a specific word, everything is possible to choose from
		if word and (word of @words) then quads = @words[word] else quads = Object.keys @quads

		#empty brain? nothing to say
		return @defaultReply if quads.length is 0

		#quads are generated differently depending on origin
		quadHash = quads[@randomInt 0, quads.length-1]
		quadHash = quadHash.tokens.join(',') if typeof quadHash isnt 'string'
		quad = middleQuad = @quads[quadHash]

		#shallow copy this guy, otherwise problems happen
		parts = quad.tokens.slice 0

		#while we don't have an end, generate a next token
		while not quad.canEnd
			nextTokens = @next[quad.hash()]

			#no tokens, no dice -- skip
			break if not nextTokens
			nextToken = nextTokens[@randomInt 0, nextTokens.length-1]

			#we have a new quad, so we should probably ensure it's in our quad list
			newQuad = new Quad [quad.tokens[1...@markov]..., nextToken]
			@addQuad newQuad

			#change to our new quad
			quad = @quads[newQuad.hash()]
			parts.push nextToken

		quad = middleQuad

		#while we don't have a beginning, generate a previous token
		while not quad.canStart
			prevTokens = @prev[quad.hash()]
			break if not prevTokens
			prevToken = prevTokens[@randomInt 0, prevTokens.length-1]

			newQuad = new Quad [prevToken, quad.tokens[0...@markov-1]...]
			@addQuad newQuad
			quad = @quads[newQuad.hash()]
			parts.unshift prevToken

		parts.join ' '

module.exports = exports = jsMegaHal