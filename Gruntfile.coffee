module.exports = (grunt) ->

    grunt.initConfig
        pkg: 
            grunt.file.readJSON 'package.json'

        coffee:
          dist:
            src: ['lib/**/*.coffee']
            dest: 'dist/jsmegahal.js'

        watch:
            dist:
                files: '<%= coffee.dist.src %>'
                tasks: [ 'default' ]

        mochaTest:
            dist:
                options:
                    ui: 'bdd'
                    reporter: 'nyan'
                src:
                    'test/**/*.coffee'

        uglify:
            dist:
                files:
                    'dist/jsmegahal.min.js': 'dist/jsmegahal.js'

    grunt.event.on 'coffee.error', (msg) ->
        grunt.log.write msg

    grunt.task.loadNpmTasks 'grunt-contrib-coffee'
    grunt.task.loadNpmTasks 'grunt-contrib-watch'
    grunt.task.loadNpmTasks 'grunt-contrib-uglify'
    grunt.task.loadNpmTasks 'grunt-mocha-test'

    grunt.registerTask 'test', ['coffee', 'mochaTest']
    grunt.registerTask 'default', ['test', 'uglify']
    grunt.registerTask 'dev', ['watch']