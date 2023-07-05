import {defineConfig} from 'vite';
import {resolve} from 'path';
import react from '@vitejs/plugin-react-swc';
import dts from 'vite-plugin-dts';

// https://vitejs.dev/config/
export default defineConfig({
  base: '/',
  plugins: [
    react(),
    dts({
      entryRoot: resolve(__dirname, 'src', 'lib'),
      insertTypesEntry: true,
    }),
  ],
  build: {
    lib: {
      entry: resolve(__dirname, 'src', 'lib', 'index.ts'),
      name: 'osom-ui',
      formats: ['es', 'umd'],
      fileName: format => `osom-ui.${format}.js`,
    },
    rollupOptions: {
      external: ['react', 'react-dom'],
      output: {
        globals: {
          react: 'React',
          'react-dom': 'ReactDOM',
        },
      },
    },
  },
});
