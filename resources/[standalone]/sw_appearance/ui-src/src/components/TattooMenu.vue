<template>
    <q-expansion-item icon="fa-solid fa-skull" label="Tattoos" group="main-menu" class="q-pt-md">
        <q-expansion-item :label="`${zone}`" group="tattoo-zone" v-for="(item, zone) in getTattoos"
            :key="`tattoo_zone_${zone}`">
            <q-list>
                <q-item v-for="tattoo in item" :key="`tattoo_${tattoo.label}`">
                    <q-item-section>
                        <div class="q-gutter-xs flex row items-center no-wrap justify-between">
                            <span class="text-bold text-amber tattoo-label">{{ tattoo.label }}</span>
                            <q-btn class="gt-xs q-pr-sm q-pl-sm" dense size="xs" color="primary"
                                :disable="addedTattoos.has(tattoo.hash)" @click.stop="tattooAction(tattoo)">colocar</q-btn>
                            <q-btn class="gt-xs q-pr-sm q-pl-sm" dense size="xs" color="negative"
                                :disable="!addedTattoos.has(tattoo.hash)"  @click.stop="tattooAction(tattoo)">retirar</q-btn>
                        </div>
                    </q-item-section>
                </q-item>
            </q-list>
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
    overlay: string;
    label: string;
    zone: string;
    hash?: string;
};

const addedTattoos = ref(new Set())
const tattooList = ref<TattooDef[]>([])
const getTattoos = computed(() =>   groupBy(tattooList.value, "zone"))

function updateTattooList(){
    nuiRequest('getTattooList', {}).then(response => {
        tattooList.value = response.tattooList
        if (response.current && response.current.length > 0) {
            response.current.forEach((value: [number, number]) => {                
                addedTattoos.value.add( `${value[0]}_${value[1]}` )
            })
        }
    })
}

async function tattooAction(tattoo: TattooDef) {
    await nextTick();
    if (addedTattoos.value.has(tattoo.hash)) {
        addedTattoos.value.delete(tattoo.hash)
        nuiRequest('setTattoo', { action: 'remove', hash: tattoo.hash })
    } else {
        addedTattoos.value.add(tattoo.hash)
        nuiRequest('setTattoo', { action: 'add', hash: tattoo.hash, c: tattoo.collection, o: tattoo.overlay })
    }
}

onMounted(() => {
    updateTattooList()
})

useNuiEvent('updatePed', () => {
    updateTattooList()
})

</script>
<style scoped lang="scss">
.tattoo-label {
    flex: 1;
}
</style>