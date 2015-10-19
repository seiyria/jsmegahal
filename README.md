jsmegahal [![Build Status](https://travis-ci.org/seiyria/jsmegahal.png?branch=master)](https://travis-ci.org/seiyria/jsmegahal)
=========

Implementation of the MegaHAL AI in JS for consumption with node.js

Installation
============
```
npm install jsmegahal
```

Sample Usage
============
```js
jsmegahal = require('jsmegahal');

//you can pass in the markov order you want to use. it defaults to 4.
var megahal = new jsmegahal(4);

//add a single sentence
megahal.add("This is a singular sentence and megahal will deconstruct it accordingly.");

//add a lot of data
megahal.addMass("This is a lot of data. Also, it is in multiple sentences!");

//get a string based on the markov data -- this picks a random token in the sentence
console.log(megahal.getReplyFromSentence("Pick a keyword"));

//get a string based on the markob data -- this can take a token, or nothing at all
console.log(megahal.getReply());
```

Projects Using This
===================
[alexa-chatterbot](https://github.com/moof2k/alexa-chatterbot)
