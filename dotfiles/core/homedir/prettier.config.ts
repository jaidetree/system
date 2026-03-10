import organizeImports from 'prettier-plugin-organize-imports'

export default {
	arrowParens: 'avoid',
	bracketSameLine: false,
	bracketSpacing: true,
	embeddedLanguageFormatting: 'auto',
	htmlWhitespaceSensitivity: 'css',
	jsxSingleQuote: false,
	overrides: [
		{
			files: [
				'*.cts',
				'*.mts',
				'*.ts',
				'*.tsx',
				'*.cjs',
				'*.js',
				'*.jsx',
				'*.mjs',
			],
			options: {
				parser: 'typescript',
				plugins: [organizeImports],
			},
		},
		{
			files: ['*.md', '*.mdx'],
			options: {
				useTabs: false,
			},
		},
	],
	printWidth: 80,
	proseWrap: 'always',
	quoteProps: 'consistent',
	semi: false,
	singleQuote: true,
	trailingComma: 'all',
	useTabs: true,
}
