<template>
    <q-expansion-item icon="fa-solid fa-face-smile" label="Appearance" group="main-menu" class="q-pt-md">
        <div class="q-pl-md q-pr-md flex column">
            <div class="title flex justify-center items-center text-center q-mt-sm bg-grey-9 text-uppercase text-bold">
                Cabelo</div>

            <div class="flex row no-wrap items-center q-mt-sm q-mb-sm">
                <span class="d1">Modelo:</span>
                <q-slider class="q-ml-md q-mr-md" v-model.number="pedHair.current" :min="0" :max="pedHair.max"
                    @update:model-value="setHair" />
                <span class="d1">{{ pedHair.current }}</span>
            </div>
           
            <div class="color-panel flex column">
                <div class="d1 flex justify-center items-center ">Primeira Cor</div>
                <ColorPanel @update:model-value="setHair" color-type="hair" v-model.number="pedHair.color1" />
            </div>

            <div class="color-panel flex column q-mt-sm q-mb-sm">
                <div class="d1 flex justify-center items-center ">Segunda Cor</div>
                <ColorPanel @update:model-value="setHair" color-type="hair" v-model.number="pedHair.color2" />
            </div>


            <div class="title flex justify-center items-center text-center q-mt-sm bg-grey-9 text-uppercase text-bold">
                Lente
                de Contato</div>
            <div class="flex row no-wrap items-center q-mt-sm q-mb-sm">
                <q-slider class="q-ml-md q-mr-md" v-model.number="faceEye" :min="0" :max="31"
                    @update:model-value="setEye" />
                <span class="d1">{{ faceEye }}</span>
            </div>
            <template v-for="overlay in Object.values(faceOverlay)" :key="`face_${overlay.id}`">
                <div
                    class="title flex justify-center items-center text-center q-mt-sm bg-grey-9 text-uppercase text-bold">
                    {{ overlay.label }}</div>
                <div class="flex row no-wrap items-center q-mt-sm q-mb-sm">
                    <span class="d1">Modelo:</span>
                    <q-slider class="q-ml-md q-mr-md" v-model.number="overlay.current" :min="-1" :max="overlay.max"
                        @update:model-value="setOverlay(overlay)" />
                    <span class="d1">{{ overlay.current }}</span>
                </div>
                <div class="flex row no-wrap items-center">
                    <span class="d1">Transparência:</span>
                    <q-slider class="q-ml-md q-mr-md" v-model.number="overlay.opacity" :min="0.0" :max="1.0"
                        :step="0.01" @update:model-value="setOverlay(overlay)" />
                    <span class="d1">{{ overlay.opacity }}</span>
                </div>

                <div class="color-panel flex column" v-if="overlay.color1">
                    <div class="d1 flex justify-center items-center ">Primeira Cor</div>
                    <ColorPanel :color-type="overlay.colorType" v-model.number="overlay.color1Value"
                        @update:model-value="setOverlay(overlay)" />
                </div>

                <div class="color-panel flex column" v-if="overlay.color2">
                    <div class="d1 flex justify-center items-center ">Segunda Cor</div>
                    <ColorPanel :color-type="overlay.colorType" v-model.number="overlay.color2Value"
                        @update:model-value="setOverlay(overlay)" />
                </div>
            </template>
        </div>
    </q-expansion-item>
</template>
<script setup lang="ts">

import { FaceOverlay, TFaceOverlay } from '@/utils/appareance';
import { reactive, ref, onMounted, nextTick } from 'vue';
import ColorPanel from './ColorPanel.vue'
import { nuiRequest } from '@/utils/nui-request';
import { useNuiEvent } from '@/utils/use-nui';

const faceOverlay = reactive<Record<string, TFaceOverlay>>(FaceOverlay)

const faceEye = ref(0)

const pedHair = ref({
    max: 10,
    current: 0,
    maxTexture: 1,
    currentTexture: 0,
    color1: 0,
    color2: 0
})

async function updateOverlay() {
    await nextTick();
    nuiRequest('getOverlays', {}).then((response) => {        
        const { max, current, hair, eyeIndex } = response;
        pedHair.value.color1 = hair.current.color1
        pedHair.value.color2 = hair.current.color2
        pedHair.value.current = hair.current.style
        pedHair.value.maxTexture = hair.maxtexture
        pedHair.value.max = hair.max
        pedHair.value.currentTexture = hair.current.texture
        faceEye.value = eyeIndex

        Object.keys(faceOverlay).forEach(k => {
            faceOverlay[k].name = k
            faceOverlay[k].max = max[k]
            faceOverlay[k].color1Value = current[k]?.color1 || 0
            faceOverlay[k].color2Value = current[k]?.color2 || 0            
            faceOverlay[k].current = current[k]?.d || 0
            faceOverlay[k].opacity = parseFloat(current[k]?.opacity?.toPrecision(2)) || 1.0
        })

    })
}

async function setOverlay(overlay: TFaceOverlay) {
    await nextTick();
    nuiRequest('setOverlay', {
        name: overlay.name,
        id: overlay.id,
        d: overlay.current,
        color1: overlay.color1Value,
        color2: overlay.color2Value,
        opacity: parseFloat(overlay.opacity.toPrecision(2))
    }).then(() => { })
}


async function setHair() {
    await nextTick();
    nuiRequest('setHair', {
        style: pedHair.value.current,
        texture: pedHair.value.currentTexture,
        palette: 0,
        color1: pedHair.value.color1,
        color2: pedHair.value.color2
    }).then(() => { })
}

async function setEye() {
    await nextTick();
    nuiRequest('setEye', {
        index: faceEye.value
    }).then(() => { })
}

onMounted(() => {
    updateOverlay()
})

useNuiEvent('updatePed', () => {
    updateOverlay()
})

</script>
<style scoped lang="scss"></style>