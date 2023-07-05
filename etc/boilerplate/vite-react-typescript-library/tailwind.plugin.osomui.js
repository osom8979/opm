/** @type {import('tailwindcss/plugin').Plugin} */
const plugin = require('tailwindcss/plugin'); // eslint-disable-line @typescript-eslint/no-var-requires

const osomUiPlugin = plugin(
  () => {
    // EMPTY.
  },
  {
    theme: {
      extend: {
        fontFamily: {
          sans: ['sans-serif', 'system-ui'],
          serif: ['serif', 'system-ui'],
          mono: ['monospace', 'system-ui'],
        },
        colors: {
          background: '#36363F',
          foreground: '#FFFFFF',
          header: '#2b2b32',
          button: '#2b2b32',
          error: '#B00020',
          warning: '#FB8C00',
          info: '#2196F3',
          success: '#4CAF50',
        },
        spacing: {
          topbar: '2.5rem',
        },
      },
    },
  },
);

module.exports = osomUiPlugin;
