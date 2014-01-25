chai = require 'chai' 
expect = chai.expect 
chai.should()

jsMegaHal = require '../lib/jsMegaHal'

describe 'jsMegaHal.options', ->

	it 'should respond correctly to a markov order of 3', ->
		markovOptionsOne = new jsMegaHal 3
		markovOptionsOne.add 'I like cake, and cake is great!'
		Object.keys(markovOptionsOne.quads).length.should.equal 5
		Object.keys(markovOptionsOne.words).length.should.equal 7