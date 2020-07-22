import html from '@rollup/plugin-html'
import babel from '@rollup/plugin-babel'
import css from 'rollup-plugin-postcss'
import execute from 'rollup-plugin-execute'
import { terser } from 'rollup-plugin-terser'
import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';
import beep from '@rollup/plugin-beep';
import inject from '@rollup/plugin-inject';
import alias from '@rollup/plugin-alias';

// `npm run build` -> `production` is true
// `npm run dev` -> `production` is false
const production = !process.env.ROLLUP_WATCH
const libraryPath = '../../../../bin/targets/js/'
const outputPath = '../../../../bin/examples/counter/web/js/'
const outputFolder = production ? 'out' : 'bin'
const finalFolder = outputPath + outputFolder

export default {
	input: __dirname + '/src/index.js',
	output: {
		dir: finalFolder,
		format: 'iife', // immediately-invoked function expression — suitable for <script> tags
		// format: 'es', // Keep the bundle as an ES module file, suitable for other bundlers and inclusion as a <script type=module> tag in modern browsers (alias: esm, module)
		// format: 'esm', // { type: 'module' } is automatically added to attributes.script
		// format: 'cjs', // CommonJS, suitable for Node and other bundlers (alias: commonjs)
		// format: 'umd', // Universal Module Definition, works as amd, cjs and iife all in one
		// name: 'counter-js-app', // Other scripts on the same page can use this variable name to access the exports of your bundle.
		sourceMap: 'inline',
		entryFileNames: production ? '[name].[hash].js' : '[name].js',
	},
	watch: { include: __dirname + '/src/**' },
	plugins: [
		// inject({
			// include: __dirname + '/src/wire.js',
			// Wire: ['window', 'Wire'],
			// Wire: __dirname + '/src/wire.js',
		// }),
		resolve({
			customResolveOptions: {
				moduleDirectory: libraryPath
			}
		}),
		commonjs(),
		alias({
			entries: {
				components: './components',
			}
		}),
		babel({
			babelHelpers: 'bundled',
			exclude: '/node_modules/**'
		}), // https://github.com/rollup/rollup-plugin-babel
		css({
			extract: true,
			use: ['less'],
			minimize: production,
			extensions: ['.less']
		}), // https://www.npmjs.com/package/rollup-plugin-postcss
		html({
			fileName: 'index.html',
			publicPath: './', // appended before index.js - <script src="[publicPath]index.js"></script>
			title: 'Wire - Counter - JS',
			attributes: {
				html: { lang: 'en' },
			},
			meta: [
				{ charset: 'utf-8' },
				{ name: 'viewport', content: 'minimum-scale=1, initial-scale=1, width=device-width' }
			],
		}),
		beep(),
		execute([
			'(echo >/dev/tcp/localhost/7771) &>/dev/null && echo "TCP port 7771 open" || reload -b -p 7771 -d ' + finalFolder + ' &'
		]),
		production && terser()
	]
};
