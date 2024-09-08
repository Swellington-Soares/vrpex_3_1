<template>
  <q-card flat square class="main-container" v-if="show">
    <div class="button-menu q-pl-sm q-pt-sm flex column">
      <q-fab color="white" class="bg-dark q-pa-xs" push icon="fa-solid fa-camera" direction="right" flat padding="xs">
        <q-fab-action color="white" class="bg-dark q-pa-xs" icon="fa-solid fa-head-side" flat padding="xs"
          @click.stop="changeCam('head')" />
        <q-fab-action color="white" class="bg-dark q-pa-xs" icon="fa-solid fa-child-reaching" flat padding="xs"
          @click.stop="changeCam('body')" />
        <q-fab-action color="white" class="bg-dark q-pa-xs" icon="fa-solid fa-shoe-prints" flat padding="xs"
          @click.stop="changeCam('foot')" />
      </q-fab>
      <!-- <q-btn  color="white" icon="fa-solid fa-camera" flat round></q-btn> -->
      <q-btn color="white" class="bg-dark" icon="fa-solid fa-person-walking-arrow-loop-left" flat round
        @click.stop="changeCam('rotatePed')"></q-btn>
      <q-btn color="white" class="bg-dark" icon="fa-solid fa-rotate-left" flat round @click.stop="changeCam('left')"
        :class="{ 'bg-red': side == 'left' }"></q-btn>
      <q-btn color="white" class="bg-dark" icon="fa-solid fa-rotate-right" flat round @click.stop="changeCam('right')"
        :class="{ 'bg-red': side == 'right' }"></q-btn>
      <q-btn color="white" class="bg-dark" icon="fa-solid fa-floppy-disk" flat round @click.stop="finish"></q-btn>
      <q-btn color="white" class="bg-dark" icon="fa-solid fa-right-from-bracket" flat round @click.stop="quit(false)"
        v-if="configComponents.allowExit"></q-btn>
    </div>
    <q-list style="height: 100vh; overflow-y: auto;">
      <PedMenu v-if="configComponents.ped" />
      <InheritanceMenu v-if="configComponents.inherirance" />
      <FaceFeatureMenu v-if="configComponents.faceFeature" />
      <FaceOverlayMenu v-if="configComponents.appearance" />
      <ClotheMenu v-if="configComponents.clothes" />
      <PropMenu v-if="configComponents.props" />
      <TattooMenu v-if="configComponents.tattoo" />
    </q-list>
  </q-card>
</template>

<script setup lang="ts">
import { defineAsyncComponent, reactive, ref } from 'vue';
import { useNuiEvent } from './utils/use-nui'
import { useQuasar } from 'quasar';

import FinishDialog from './components/FinishDialog.vue';
import { nuiRequest } from './utils/nui-request';

const InheritanceMenu = defineAsyncComponent(() => import('./components/InheritanceMenu.vue'));
const FaceFeatureMenu = defineAsyncComponent(() => import('./components/FaceFeatureMenu.vue'));
const FaceOverlayMenu = defineAsyncComponent(() => import('./components/FaceOverlayMenu.vue'));
const ClotheMenu = defineAsyncComponent(() => import('./components/ClotheMenu.vue'));
const PropMenu = defineAsyncComponent(() => import('./components/PropMenu.vue'));
const TattooMenu = defineAsyncComponent(() => import('./components/TattooMenu.vue'));
const PedMenu = defineAsyncComponent(() => import('./components/PedMenu.vue'));

const $q = useQuasar()

const configComponents = reactive({
  ped: false,
  inherirance: false,
  faceFeature: false,
  appearance: false,
  clothes: false,
  props: false,
  tattoo: false,
  allowExit: false,
  gender: 'Masculino'
})

const side = ref('')
const show = ref(false)

useNuiEvent('OPEN', (data: any) => {
  const { config } = data
  configComponents.ped = config.ped
  configComponents.inherirance = config.headBlend
  configComponents.faceFeature = config.faceFeatures
  configComponents.appearance = config.headOverlays
  configComponents.clothes = config.components
  configComponents.props = config.props
  configComponents.allowExit = config.allowExit
  show.value = true
})

useNuiEvent('CLOSE', () => {
  side.value = ''
  show.value = false;
  configComponents.ped = false,
  configComponents.inherirance = false,
  configComponents.faceFeature = false,
  configComponents.appearance = false,
  configComponents.clothes = false,
  configComponents.props = false,
  configComponents.tattoo = false,
  configComponents.allowExit = false,
  configComponents.gender = 'Masculino'
})

useNuiEvent('updatePed', (data: any) => {
  const { gender } = data;
  configComponents.gender = gender
})

const changeCam = async (cam: string) => {
  if (cam == 'left' || cam == 'right') {
    if (side.value == cam) side.value = '';
    else side.value = cam;
  }
  await nuiRequest('change-cam', { cam })
}

// const makeAction = async (action: string) => {
//   await nuiRequest('make-action', { action })
// }

const quit = async (state: boolean) => {  
  await nuiRequest('quit', { save : state })
}

const finish = () => {
  $q.dialog({
    component: FinishDialog,
  }).onOk(async () => {
    await quit(true)
  })
}

</script>

<style scoped lang="scss">
.main-container {
  min-width: 40vh;
  height: 100vh;
  position: relative;
  padding: 0;
}

.button-menu {
  position: absolute;
  right: 0;
  transform: translateX(100%);
  z-index: 25;
  gap: 1em;
}
</style>
