// eslint.config.cjs
const {FlatCompat} = require('@eslint/eslintrc');
const js = require('@eslint/js');
const globals = require('globals');

const compat = new FlatCompat();

module.exports = [
  js.configs.recommended,
  ...compat.config({
    extends: ['google'],
    rules: {
      'valid-jsdoc': 'off',
      'require-jsdoc': 'off',
      'max-len': ['error', {code: 120, ignoreUrls: true}],
      'linebreak-style': 'off',
      'object-curly-spacing': ['error', 'never'],
      'no-unused-vars': ['error', {
        argsIgnorePattern: '^_',
        varsIgnorePattern: '^_',
      }],
    },
  }),
  {
    languageOptions: {
      sourceType: 'commonjs',
      ecmaVersion: 2022,
      globals: {
        ...globals.node,
        ...globals.es2021,
      },
    },
  },
];
