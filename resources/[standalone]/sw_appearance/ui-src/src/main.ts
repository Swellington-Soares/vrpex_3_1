// FILE: main.js

import { createApp } from 'vue'
import { Quasar, Dialog } from 'quasar'

import quasarIconSet from 'quasar/icon-set/fontawesome-v6'

// Import icon libraries
// import '@quasar/extras/roboto-font/roboto-font.css'
// import '@quasar/extras/fontawesome-v6/fontawesome-v6.css'
// Import Quasar css
import 'quasar/src/css/index.sass'

import './style.scss'


// Assumes your root component is App.vue
// and placed in same folder as main.js
import App from './App.vue'

const myApp = createApp(App)

myApp.use(Quasar, {
  plugins: {
    Dialog
  }, // import Quasar plugins and add here
  iconSet: quasarIconSet,
  config: {
    dark: true
  }
  /*
  config: {
    brand: {
      // primary: '#e46262',
      // ... or all other brand colors
    },
    notify: {...}, // default set of options for Notify Quasar plugin
    loading: {...}, // default set of options for Loading Quasar plugin
    loadingBar: { ... }, // settings for LoadingBar Quasar plugin
    // ..and many more (check Installation card on each Quasar component/directive/plugin)
  }
  */
})

// Assumes you have a <div id="app"></div> in your index.html
myApp.mount('#app')
