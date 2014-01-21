
Quad = require './Quad'

class jsMegaHal
	wordRegex: /[a-zA-Z0-9]/
	punctRegex: /\.\!\?/g

	words: {}
	quads: {}
	next: {}
	prev: {}

	constructor: (@markov = 4) ->

	randomInt: (min,max) ->
		return Math.floor Math.random() * (max - min + 1) + min

	add: (sentence) ->
		sentence = sentence.trim()
		parts = []
		chars = sentence.split ''
		buffer = ''

		for i in [0...chars.length] by 1
			ch = chars[i]

			if not (@wordRegex.test ch)
				parts.push buffer if buffer.length isnt 0
				buffer = ''
				continue

			buffer += ch

		parts.push buffer if buffer.length isnt 0

		partsLength = parts.length

		return if partsLength < @markov

		for i in [0..partsLength - @markov - 1] by 1
			quad = new Quad [ parts[i..i+3]... ]
			@quads[quad.hash()] = quad

			quad.canStart = (i is 0)
			quad.canEnd = (i is partsLength - @markov)

			for q in [0..@markov] by 1
				token = quad.tokens[q]
				@words[token] = [] if not (token of @words)
				@words[token].push quad

			if i isnt 0
				prevToken = parts[i-1]
				@prev[quad.hash()] = [] if not (quad.hash() of @prev)
				@prev[quad.hash()].push prevToken

			if i < partsLength - @markov
				nextToken = parts[i+1]
				@next[quad.hash()] = [] if not (quad.hash() of @next)
				@next[quad.hash()].push nextToken

	getSentence: (word) ->
		word = word.trim()
		parts = []
		quads = []
		if word then quads = @words[word] else quads = Object.keys @quads

		return if quads.length is 0

		quad = middleQuad = quads[@randomInt 0, quads.length-1 ]

		for i in [0...@markov] by 1
			parts.push quad.tokens[i]

		while not quad?.canEnd
			nextTokens = @next[quad.hash()]
			break if not nextTokens
			nextToken = nextTokens[@randomInt 0, nextTokens.length-1]
			newQuad = new Quad [quad.tokens[0..@markov-1]..., nextToken]
			@quads[newQuad.hash()] = newQuad
			quad = @quads[newQuad.hash()]
			parts.push nextToken

		quad = middleQuad

		while not quad?.canStart
			prevTokens = @prev[quad.hash()]
			break if not prevTokens
			prevToken = prevTokens[@randomInt 0, prevTokens.length-1]
			newQuad = new Quad [quad.tokens[0..@markov-1]..., prevToken]
			@quads[newQuad.hash()] = newQuad
			quad = @quads[newQuad.hash()]
			parts.unshift prevToken

		parts.join ' '