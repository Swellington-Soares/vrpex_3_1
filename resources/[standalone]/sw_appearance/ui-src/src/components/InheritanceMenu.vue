<template>
    <q-expansion-item icon="fa-solid fa-family" label="Inhritance" group="main-menu" class="q-pt-md">
        <div class="q-pl-md q-pr-md flex column">
            <div class="title flex justify-center q-mt-sm bg-grey-9 text-uppercase text-bold">Mãe</div>
            <div class="flex row no-wrap items-center">                
                <q-slider class="q-mr-md q-ml-md" v-model="motherIndex" :min="0" :max="getTotalMothers"
                    @update:model-value="setHeadBlend()" />
                <span>{{ getMotherId }}</span>
            </div>

            <div class="title flex justify-center q-mt-sm bg-grey-9 text-uppercase text-bold">Pai</div>
            <div class="flex row no-wrap items-center">                
                <q-slider class="q-mr-md q-ml-md" v-model="fatherIndex" :min="0" :max="getTotalFathers"
                    @update:model-value="setHeadBlend()" />
                <span>{{ getFatherId }}</span>
            </div>

            <div class="title flex justify-center q-mt-sm bg-grey-9 text-uppercase text-bold">Tom da Pele Mãe</div>
            <div class="flex row no-wrap items-center">
             
                <q-slider class="q-mr-md q-ml-md" v-model="motherSkin" :min="0" :max="getTotalMothers"
                    @update:model-value="setHeadBlend()" />
                <span>{{ getMotherSkinId }}</span>
            </div>

            <div class="title flex justify-center q-mt-sm bg-grey-9 text-uppercase text-bold">Tom da Pele Pai</div>
            <div class="flex row no-wrap items-center">
              
                <q-slider class="q-mr-md q-ml-md" v-model="fatherSkin" :min="0" :max="getTotalFathers"
                    @update:model-value="setHeadBlend()" />
                <span>{{ getFatherSkinId }}</span>
            </div>

            <div class="title flex justify-center q-mt-sm bg-grey-9 text-uppercase text-bold">Características</div>
            <div class="flex row no-wrap items-center">
                <q-icon name="fa-solid fa-person"></q-icon>
                <q-slider class="q-mr-md q-ml-md" v-model.number="shapeMix" :min="0" :max="1.0" :step="0.01"
                    @update:model-value="setHeadBlend()" />
                <q-icon name="fa-solid fa-person-dress"></q-icon>
            </div>

            <div class="title flex justify-center q-mt-sm bg-grey-9 text-uppercase text-bold">Mistura de Tom</div>
            <div class="flex row no-wrap items-center">
                <q-icon name="fa-solid fa-person"></q-icon>
                <q-slider class="q-mr-md q-ml-md" v-model.number="skinMix" :min="0" :max="1.0" :step="0.01"
                    @update:model-value="setHeadBlend()" />
                <q-icon name="fa-solid fa-person-dress"></q-icon>
            </div>
        </div>
    </q-expansion-item>

</template>
<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';
import { fathers, mothers } from '@/utils/parents'
import { nuiRequest } from '@/utils/nui-request';
import { useNuiEvent } from '@/utils/use-nui';


const motherIndex = ref(0)
const fatherIndex = ref(0)

const motherSkin = ref(0)
const fatherSkin = ref(0)

const shapeMix = ref(0.0)
const skinMix = ref(0.0)

const getTotalMothers = computed(() => mothers.length - 1)
const getTotalFathers = computed(() => fathers.length - 1)
const getMotherId = computed(() => mothers[motherIndex.value])
const getFatherId = computed(() => fathers[fatherIndex.value])
const getMotherSkinId = computed(() => mothers[motherSkin.value])
const getFatherSkinId = computed(() => fathers[fatherSkin.value])


function updateHeadBlend() {
    nuiRequest('getHeadblend', {}).then(response => {
        shapeMix.value = parseFloat(response.shapeMix.toPrecision(2))
        skinMix.value = parseFloat(response.skinMix.toPrecision(2))
        motherIndex.value = mothers.indexOf(response.shapeFirst)
        fatherIndex.value = fathers.indexOf(response.shapeSecond)
        motherSkin.value = mothers.indexOf(response.skinFirst)
        fatherSkin.value = fathers.indexOf(response.skinSecond)
    })
}

function setHeadBlend() {
    nuiRequest('setHeadBlend', {
        hasParent: false,
        shapeFirst: getMotherId.value,
        shapeSecond: getFatherId.value,
        skinFirst: getMotherSkinId.value,
        skinSecond: getFatherSkinId.value,
        skinMix: parseFloat(skinMix.value.toPrecision(2)),
        shapeMix: parseFloat(shapeMix.value.toPrecision(2)),
        shapeThird: 0,
        skinThird: 0,
        thirdMix: 0
    })
}

onMounted(() => {
    updateHeadBlend()
})

useNuiEvent('updatePed', () => {
    updateHeadBlend()
})

</script>
<style scoped lang="scss"></style>