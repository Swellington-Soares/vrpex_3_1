<template>
    <q-expansion-item icon="fa-solid fa-shirt" label="Clothes" group="main-menu" class="q-pt-md">
        <div class="q-pl-md q-pr-md flex column">
            <template v-for="clothe in Object.values(pedClothes)" :key="`face_${clothe.id}`">
                <div
                    class="title flex justify-center items-center text-center q-mt-sm bg-grey-9 text-uppercase text-bold">
                    {{ clothe.label }}</div>
                <div class="flex row no-wrap items-center">
                    <span class="d1">Modelo:</span>
                    <q-slider class="q-mr-md q-ml-md" v-model.number="clothe.current" :min="0"
                        @update:model-value="updateClotheMaxTexture(clothe.id, clothe.current)"
                        :max="clothe.max" />
                    <span class="d1">{{ clothe.current }}</span>

                </div>
                <div class="flex row no-wrap items-center">
                    <span class="d1">Textura:</span>
                    <q-slider class="q-mr-md q-ml-md" v-model.number="clothe.currentTexture" :min="0"
                        :max="clothe.maxtexture" :disable="clothe.maxtexture <= 1" @update:model-value="updateClotheTexture(clothe.id, clothe.current, clothe.currentTexture)" />
                    <span class="d1">{{ clothe.currentTexture }}</span>
                </div>
            </template>
        </div>
    </q-expansion-item>

</template>

<script setup lang="ts">
import { onMounted, reactive } from 'vue';
import { objectMap } from '@/utils/js'
import { clothes } from '@/utils/clothes'
import { nuiRequest } from '@/utils/nui-request';
import { useNuiEvent } from '@/utils/use-nui';

const pedClothes = reactive(
    objectMap(clothes, (v, _k, _i) => {
        return {
            ...v,
            max : 1,
            current: 0,
            maxtexture: 1,
            currentTexture: 0
        }
    })
)

function updateClothes() {
    nuiRequest('getDrawables', {}).then(response => {
        const { max, current } = response
        Object.keys(pedClothes).forEach(k => {
            pedClothes[k].max = max[k].d
            pedClothes[k].maxtexture = max[k].t
            pedClothes[k].current = current[k].d > 0 ? current[k].d : 0
            pedClothes[k].currentTexture = current[k].t > 0 ? current[k].t : 0
        })        
    })
}


function updateClotheMaxTexture(component: number, drawableId: number) {
    pedClothes[`d${component}`].currentTexture = 0
    nuiRequest('getDrawableMaxTexture', { component, drawableId }).then(response => {
        const {max} = response
        pedClothes[`d${component}`].maxtexture = max
    })
}


function updateClotheTexture(component: number, drawableId: number, texture: number) {
    nuiRequest('setDrawableTexture', { component, drawableId, texture }).then(() => {})
}


onMounted(() => {
    updateClothes()
})

useNuiEvent('updatePed', () => {
    updateClothes()
})

</script>
<style scoped lang="scss"></style>