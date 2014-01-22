(function() {
  var Quad, exports, jsMegaHal,
    __slice = [].slice;

  Quad = (function() {
    function Quad(tokens) {
      this.tokens = tokens;
      this.canStart = false;
      this.canEnd = false;
    }

    Quad.prototype.hash = function() {
      return this.tokens.join(',');
    };

    return Quad;

  })();

  /*
  TODO load from a big string
  TODO load from a remote URL
  */


  jsMegaHal = (function() {
    jsMegaHal.prototype.wordRegex = /[a-zA-Z0-9]/;

    jsMegaHal.prototype.words = {};

    jsMegaHal.prototype.quads = {};

    jsMegaHal.prototype.next = {};

    jsMegaHal.prototype.prev = {};

    /*
    	@markov - the markov order to use for this jsMegaHal instance, defaults to 4
    */


    function jsMegaHal(markov, defaultReply) {
      this.markov = markov != null ? markov : 4;
      this.defaultReply = defaultReply != null ? defaultReply : '';
    }

    /*
    	generate a number between min and max, inclusive
    
    	@min the lower bound
    	@max the upper bound
    */


    jsMegaHal.prototype.randomInt = function(min, max) {
      return Math.floor(Math.random() * (max - min + 1) + min);
    };

    /*
    		a convenience method to add a quad to the quads list
    
    		@quad the quad to add to the list
    */


    jsMegaHal.prototype.addQuad = function(quad) {
      return this.quads[quad.hash()] = quad;
    };

    /*
    	add a sentence to jsMegaHal
    
    	@sentence the sentence to add to jsMegaHal. ignored if there are fewer than @markov words in it
    */


    jsMegaHal.prototype.add = function(sentence) {
      var buffer, ch, chars, i, nextToken, parts, partsLength, prevToken, q, quad, token, _i, _j, _k, _ref, _ref1, _ref2, _results;
      sentence = sentence.trim();
      if (sentence.split(' ').length < this.markov) {
        return;
      }
      parts = [];
      chars = sentence.split('');
      buffer = '';
      for (i = _i = 0, _ref = chars.length; _i < _ref; i = _i += 1) {
        ch = chars[i];
        if (!(this.wordRegex.test(ch))) {
          if (buffer.length !== 0) {
            parts.push(buffer);
          }
          buffer = '';
          continue;
        }
        buffer += ch;
      }
      if (buffer.length !== 0) {
        parts.push(buffer);
      }
      partsLength = parts.length;
      _results = [];
      for (i = _j = 0, _ref1 = partsLength - (this.markov - 1); _j < _ref1; i = _j += 1) {
        quad = new Quad(__slice.call(parts.slice(i, +(i + 3) + 1 || 9e9)));
        this.addQuad(quad);
        quad.canStart = i === 0;
        quad.canEnd = i === partsLength - this.markov;
        for (q = _k = 0, _ref2 = this.markov; _k < _ref2; q = _k += 1) {
          token = quad.tokens[q];
          if (!(token in this.words)) {
            this.words[token] = [];
          }
          this.words[token].push(quad);
        }
        if (i !== 0) {
          prevToken = parts[i - 1];
          if (!(quad.hash() in this.prev)) {
            this.prev[quad.hash()] = [];
          }
          this.prev[quad.hash()].push(prevToken);
        }
        if (i < partsLength - this.markov) {
          nextToken = parts[i + this.markov];
          if (!(quad.hash() in this.next)) {
            this.next[quad.hash()] = [];
          }
          _results.push(this.next[quad.hash()].push(nextToken));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    /*
    	generate a reply from a sentence instead of just a word
    
    	@sentence the sentence to pick a token from
    */


    jsMegaHal.prototype.getReplyFromSentence = function(sentence) {
      var tokens;
      tokens = sentence.trim().split(' ');
      return this.getReply(tokens[this.randomInt(0, tokens.length - 1)]);
    };

    /*
    	generate a reply from a single word
    
    	@word the seed word, can be null/undefined
    */


    jsMegaHal.prototype.getReply = function(word) {
      var middleQuad, newQuad, nextToken, nextTokens, parts, prevToken, prevTokens, quad, quadHash, quads;
      word = word.trim();
      quads = [];
      if (word && (word in this.words)) {
        quads = this.words[word];
      } else {
        quads = Object.keys(this.quads);
      }
      if (quads.length === 0) {
        return this.defaultReply;
      }
      quadHash = quads[this.randomInt(0, quads.length - 1)];
      if (typeof quadHash !== 'string') {
        quadHash = quadHash.tokens.join(',');
      }
      quad = middleQuad = this.quads[quadHash];
      parts = quad.tokens.slice(0);
      while (!quad.canEnd) {
        nextTokens = this.next[quad.hash()];
        if (!nextTokens) {
          break;
        }
        nextToken = nextTokens[this.randomInt(0, nextTokens.length - 1)];
        newQuad = new Quad(__slice.call(quad.tokens.slice(1, this.markov)).concat([nextToken]));
        this.addQuad(newQuad);
        quad = this.quads[newQuad.hash()];
        parts.push(nextToken);
      }
      quad = middleQuad;
      while (!quad.canStart) {
        prevTokens = this.prev[quad.hash()];
        if (!prevTokens) {
          break;
        }
        prevToken = prevTokens[this.randomInt(0, prevTokens.length - 1)];
        newQuad = new Quad([prevToken].concat(__slice.call(quad.tokens.slice(0, this.markov - 1))));
        this.addQuad(newQuad);
        quad = this.quads[newQuad.hash()];
        parts.unshift(prevToken);
      }
      return parts.join(' ');
    };

    return jsMegaHal;

  })();

  module.exports = exports = jsMegaHal;

}).call(this);
