import {defineConfig} from 'vite';
import {resolve} from 'path';
import react from '@vitejs/plugin-react-swc';

// https://vitejs.dev/config/
export default defineConfig({
  base: '/osom-ui/',
  plugins: [react()],
  build: {
    outDir: resolve(__dirname, 'pages'),
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
      },
    },
  },
});
