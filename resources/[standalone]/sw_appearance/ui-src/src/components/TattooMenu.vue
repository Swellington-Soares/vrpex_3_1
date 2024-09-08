<template>
    <q-expansion-item icon="fa-solid fa-skull" label="Tattoos" group="main-menu" class="q-pt-md">
        <q-expansion-item :label="`${zone}`" group="tattoo-zone" v-for="(_, zone) in getTattoos"
            :key="`tattoo_zone_${zone}`">
            <q-list>
                <q-item v-for="tattoo in paginatedTattoos(zone)" :key="`tattoo_${tattoo.label}`">
                    <q-item-section>
                        <div class="q-gutter-xs flex row items-center no-wrap justify-between">
                            <span class="text-bold text-amber tattoo-label">{{ tattoo.label }}</span>
                            <q-btn class="gt-xs q-pr-sm q-pl-sm" dense size="xs" color="primary"
                                :disable="checkTattoo(tattoo)" @click.stop="tattooAction(tattoo)">colocar</q-btn>
                            <q-btn class="gt-xs q-pr-sm q-pl-sm" dense size="xs" color="negative"
                                :disable="!checkTattoo(tattoo)" @click.stop="tattooAction(tattoo)">retirar</q-btn>
                        </div>
                    </q-item-section>
                </q-item>
            </q-list>
            <div class="q-pa-sm flex flex-center">
                <q-pagination v-model="currentPage[zone]" :max="totalPages(zone)" :max-pages="10" size="md"
                    :min="1"></q-pagination>
            </div>
        </q-expansion-item>
    </q-expansion-item>
</template>
<script setup lang="ts">
import { groupBy } from '@/utils/js';
import { nuiRequest } from '@/utils/nui-request';
import { useNuiEvent } from '@/utils/use-nui';
import { computed, nextTick, onMounted, ref } from 'vue';

type TattooDef = {
    collection: string;
    cost: number;
    overlayMale: string;
    overlayFemale: string;
    label: string;
    zone: string;
    hashMale: string;
    hashFemale: string;
};

const addedTattoos = ref(new Set())
const tattooList = ref<TattooDef[]>([])
const getTattoos = computed(() => groupBy(tattooList.value, "zone"))
const gender = ref('Masculino')

const currentPage = ref<Record<string, number>>({})
const rowsPerPage = 10

const paginatedTattoos = (zone: any) => {
    const start = (currentPage.value[zone] - 1) * rowsPerPage
    const end = start + rowsPerPage
    return getTattoos.value[zone].slice(start, end)
}

const totalPages = (zone: any) => {
    return Math.ceil(getTattoos.value[zone].length / rowsPerPage)
}

function updateTattooList() {
    nuiRequest('getTattooList', {}).then(response => {
        tattooList.value = response.tattooList
        Object.keys(getTattoos.value).forEach(zone => {
            currentPage.value[zone] = 1;
        })
        if (response.current && response.current.length > 0) {
            response.current.forEach((value: [number, number]) => {
                addedTattoos.value.add(`${value[0]}_${value[1]}`)
            })
        }
    })
}

async function tattooAction(tattoo: TattooDef) {
    await nextTick();
    const hash = gender.value == 'Masculino' ? tattoo.hashMale : tattoo.hashFemale
    if (addedTattoos.value.has(hash)) {
        addedTattoos.value.delete(hash)
        nuiRequest('setTattoo', { action: 'remove', hash: hash })
    } else {
        addedTattoos.value.add(hash)
        nuiRequest('setTattoo', { action: 'add', hash: hash, c: tattoo.collection, o: gender.value == 'Masculino' ? tattoo.overlayMale : tattoo.overlayFemale })
    }
}

function checkTattoo(tattoo: TattooDef): boolean {
    return addedTattoos.value.has(gender.value == 'Masculino' ? tattoo.hashMale : tattoo.hashFemale)
}

onMounted(async () => {
    updateTattooList()

})

useNuiEvent('updatePed', (data: any) => {
    gender.value = data.gender
    addedTattoos.value.clear()
})

</script>
<style scoped lang="scss">
.tattoo-label {
    flex: 1;
}
</style>