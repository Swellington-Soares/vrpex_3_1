// FILE: vite.config.js

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { quasar, transformAssetUrls } from '@quasar/vite-plugin'
// import { fileURLToPath } from 'bun'

// https://vitejs.dev/config/
export default defineConfig({
  build: {
    cssMinify: true,
    emptyOutDir: true,
    outDir: '../ui',
  },
  plugins: [
    vue({
      template: { transformAssetUrls }
    }),

    // @quasar/plugin-vite options list:
    // https://github.com/quasarframework/quasar/blob/dev/vite-plugin/index.d.ts
    quasar({
      sassVariables: 'src/quasar-variables.sass',
      autoImportComponentCase: 'kebab',

    })
  ],
  base: "./",
  resolve: {
    alias: [
      { find: '@', replacement: Bun.fileURLToPath(new URL('./src', import.meta.url)) },
      { find: '@components', replacement: Bun.fileURLToPath(new URL('./src/components', import.meta.url)) },
    ]
  }
})
