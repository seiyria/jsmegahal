chai = require 'chai'
expect = chai.expect
chai.should()

jsMegaHal = require '../lib/jsMegaHal'

describe 'jsMegaHal.tokenizer', ->
	
	it 'should tokenize a simple sentence properly', ->
		markovTokenizerOne = new jsMegaHal()
		markovTokenizerOne.add 'The cake is a lie.'
		Object.keys(markovTokenizerOne.quads).length.should.equal 2
		Object.keys(markovTokenizerOne.words).length.should.equal 5

	it 'should tokenize multiple sentences properly', ->
		markovTokenizerTwo = new jsMegaHal()
		markovTokenizerTwo.addMass 'The cake is a lie. I like cake a lot.'
		Object.keys(markovTokenizerTwo.quads).length.should.equal 4
		Object.keys(markovTokenizerTwo.words).length.should.equal 8
	
	it 'should not tokenize a sentence below the current markov order', ->
		markovTokenizerThree = new jsMegaHal()
		markovTokenizerThree.add 'Cake is good.'
		Object.keys(markovTokenizerThree.quads).length.should.equal 0
		Object.keys(markovTokenizerThree.words).length.should.equal 0