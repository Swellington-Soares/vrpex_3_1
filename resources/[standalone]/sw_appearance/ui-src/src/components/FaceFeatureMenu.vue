<template>
    <q-expansion-item icon="fa-solid fa-face-viewfinder" label="Face Feature" group="main-menu" class="q-pt-md">
        <div class="q-pl-md q-pr-lg flex column">
            <template v-for="face in Object.values(pedFaceFeature)" :key="`face_${face.id}`">
                <div
                    class="title flex justify-center items-center text-center q-mt-sm bg-grey-9 text-uppercase text-bold">
                    {{ face.label }}</div>
                <q-slider label class="q-ml-sm q-mr-sm q-mt-sm q-mb-sm" v-model.number="face.scale" :min="-1.0"
                    :max="1.0" @update:model-value="setFaceFeature(face.id, face.scale)" :step="0.05" />
            </template>
        </div>
    </q-expansion-item>
</template>
<script setup lang="ts">

import { onMounted, reactive } from 'vue';
import { FaceFeature } from '@/utils/face-feature';
import { nuiRequest } from '@/utils/nui-request';
import { objectMap } from '@/utils/js';
import { useNuiEvent } from '@/utils/use-nui';


const pedFaceFeature = reactive(objectMap(FaceFeature, (v) => {
    return {
        ...v,
        scale: 0.0
    }
}))


function updateFaceFeature() {
    nuiRequest('getFaceFeature', {}).then(response => {
        Object.keys(pedFaceFeature).forEach(k => {
            if (response[k]) {
                pedFaceFeature[k].scale = parseFloat(response[k]?.toPrecision(2))
            }
        })
    })
}

function setFaceFeature(k: number, scale: number) {
    nuiRequest('setFaceFeature', { k, scale: parseFloat(scale.toPrecision(2)) }).then(() => { })
}

onMounted(() => {
    updateFaceFeature()
})

useNuiEvent('updatePed', () => {
    updateFaceFeature()
})


</script>
<style scoped lang="scss"></style>