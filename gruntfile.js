module.exports = function(grunt) {

	// load all grunt tasks matching the ['grunt-*', '@*/grunt-*'] patterns
	require('load-grunt-tasks')(grunt);
	require('time-grunt')(grunt);

	grunt.loadNpmTasks('grunt-exec');

	// Project configuration.
	grunt.initConfig({
		haxe: {
			usage: {
				hxml: 'builds/usage.hxml'
			},
			targets: {
				hxml: 'builds/targets.hxml'
			}
		},
		watch: {
			hx: {
				files: ['**/*.hx'],
				tasks: ['haxe'],
				options: {
					interrupt: true,
					livereload: true
				}
			},
			html: {
				files: 'bin/**/*.html',
				options: {
					livereload: true
				}
			},
			configGrunt: {
				files: ['Gruntfile.js'],
				options: {
					reload: true
				}
			}
		},
		exec: {
			run_reload_in_usage_web: '(echo >/dev/tcp/localhost/7770) &>/dev/null && echo "TCP port 7770 open" || reload -p 7770 -b -d ./bin/usage/web &'
		}
	});

	// Default task(s).
	grunt.registerTask('default', [
		'exec',
		'haxe',
		'watch'
	]);
};
