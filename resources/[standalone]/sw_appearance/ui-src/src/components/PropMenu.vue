<template>
    <q-expansion-item icon="fa-solid fa-watch" label="Acessórios" group="main-menu" class="q-pt-md">
        <div class="q-pl-md q-pr-md flex column">
            <template v-for="prop in Object.values(pedProps)" :key="`face_${prop.id}`">
                <div
                    class="title flex justify-center items-center text-center q-mt-sm bg-grey-9 text-uppercase text-bold">
                    {{ prop.label }}</div>
                <div class="flex row no-wrap items-center">
                    <span class="d1">Modelo:</span>
                    <q-slider class="q-mr-md q-ml-md" v-model.number="prop.current" :min="-1" :max="prop.max"
                        @update:model-value="updatePropMaxTexture(prop.id, prop.current)" />
                    <span class="d1">{{ prop.current }}</span>

                </div>
                <div class="flex row no-wrap items-center">
                    <span class="d1">Textura:</span>
                    <q-slider class="q-mr-md q-ml-md" v-model.number="prop.currentTexture" :min="0"
                        :max="prop.maxtexture" :disable="prop.maxtexture <= 1"
                        @update:model-value="updatePropTexture(prop.id, prop.current, prop.currentTexture)" />
                    <span class="d1">{{ prop.currentTexture }}</span>
                </div>
            </template>
        </div>
    </q-expansion-item>

</template>

<script setup lang="ts">
import { onMounted, reactive } from 'vue';
import { accessories } from '@/utils/clothes'
import { nuiRequest } from '@/utils/nui-request';
import { objectMap } from '@/utils/js';
import { useNuiEvent } from '@/utils/use-nui';

const pedProps = reactive(
    objectMap(accessories, (v, _k, _i) => {
        return {
            ...v,
            max: 1,
            current: -1,
            maxtexture: 0,
            currentTexture: 0
        }
    })
)

function updateProps() {
    nuiRequest('getProps', {}).then(response => {
        const { max, current } = response;
        Object.keys(accessories).forEach(k => {
            pedProps[k].max = max[k].d
            pedProps[k].maxtexture = max[k].t
            pedProps[k].current = current[k].d > 0 ? current[k].d : 0
            pedProps[k].currentTexture = current[k].t > 0 ? current[k].t : 0
        })
    })

}

function updatePropMaxTexture(component: number, propId: number) {
    pedProps[`p${component}`].currentTexture = 0
    nuiRequest('getPropMaxTexture', { component, propId }).then(response => {
        const { max } = response;
        pedProps[`p${component}`].maxtexture = max
    })
}

function updatePropTexture(component: number, propId: number, texture: number) {
    nuiRequest('setPropTexture', { component, propId, texture }).then(() => { })
}

onMounted(() => {
    updateProps()
})


useNuiEvent('updatePed', () => {
    updateProps()
})

</script>
<style scoped lang="scss"></style>