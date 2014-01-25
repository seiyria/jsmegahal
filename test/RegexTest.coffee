chai = require 'chai'
expect = chai.expect
chai.should()

jsMegaHal = require '../lib/jsMegaHal'

describe 'jsMegaHal.regexTest', ->

	it 'should support commas', ->
		markovRegexOne = new jsMegaHal()
		markovRegexOne.add 'I like cake, and cake is great!'
		Object.keys(markovRegexOne.quads).length.should.equal 4
		Object.keys(markovRegexOne.words).length.should.equal 7
		expect(markovRegexOne.words['cake,']).to.exist

	it 'should support apostrophes', ->
		markovRegexOne = new jsMegaHal()
		markovRegexOne.add "This cake's the best!"
		Object.keys(markovRegexOne.quads).length.should.equal 1
		Object.keys(markovRegexOne.words).length.should.equal 4
		expect(markovRegexOne.words["cake's"]).to.exist