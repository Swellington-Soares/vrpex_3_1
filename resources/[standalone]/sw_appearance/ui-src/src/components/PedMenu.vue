<template>
  <q-expansion-item icon="fa-solid fa-person" label="Ped" group="main-menu" class="q-pt-md">
    <q-select filled v-model="model" use-input input-debounce="0" label="Seleção do Ped" :options="options"
      behavior="menu" @update:model-value="setPed">
      <template v-slot:no-option>
        <q-item>
          <q-item-section class="text-grey">
            No results
          </q-item-section>
        </q-item>
      </template>
    </q-select>
  </q-expansion-item>
</template>
<script setup lang="ts">
import { nuiRequest } from '@/utils/nui-request';
import { onMounted, ref } from 'vue';


const stringOptions = ['Masculino', 'Feminino']
const options = ref<string[]>(stringOptions)
const model = ref()

const setPed = () => {
    nuiRequest('setGender', { gender : model.value }).then(() => {})
}

function updatePed() {
  nuiRequest('getGender', {}).then(response => {
    model.value = response.gender
  })
}

onMounted(() => {
  updatePed()
})

</script>
<style scoped lang="scss"></style>