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
            test:
                files: '<%= mochaTest.dist.src %>'
                tasks: [ 'mochaTest' ]

        mochaTest:
            dist:
                options:
                    ui: 'bdd'
                    reporter: 'nyan'
                src:
                    'test/**/*.coffee'

        coffeelint:
            dist: 
                files:
                    src: [ 'lib/**/*.coffee', 'test/**/*.coffee' ]
            options:

                no_tabs: #I like using tabs!
                    level: 'ignore'

                camel_case_classes: #Maybe I'll not break backwards compat later
                    level: 'ignore'

                indentation:
                    level: 'ignore'

        uglify:
            dist:
                files:
                    'dist/jsmegahal.min.js': 'dist/jsmegahal.js'

    grunt.event.on 'coffee.error', (msg) ->
        grunt.log.write msg

    grunt.task.loadNpmTasks 'grunt-contrib-coffee'
    grunt.task.loadNpmTasks 'grunt-contrib-watch'
    grunt.task.loadNpmTasks 'grunt-contrib-uglify'
    grunt.task.loadNpmTasks 'grunt-coffeelint'
    grunt.task.loadNpmTasks 'grunt-mocha-test'

    grunt.registerTask 'test', ['coffee', 'coffeelint', 'mochaTest']
    grunt.registerTask 'default', ['test', 'uglify']
    grunt.registerTask 'dev', ['watch']