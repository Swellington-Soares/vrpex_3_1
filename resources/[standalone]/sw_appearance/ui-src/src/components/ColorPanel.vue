<template>
    <div class="color-panel q-pa-sm">
        <div class="color-item" :class="{ selected: model == index }" v-for="(item, index) in getColor"
            :style="{ backgroundColor: item }" @click.stop="updateColor(index)">
            {{ index }}
        </div>
    </div>
</template>
<script setup lang="ts">

import { makeupColor, hairColor } from '@/interfaces/colors'
import { computed } from 'vue';

const prop = withDefaults(defineProps<{ colorType?: 'hair' | 'makeup' }>(), { colorType: 'hair' })
const model = defineModel({ default: 0, type: Number })

const getColor = computed(() => {
    switch (prop.colorType) {
        case 'hair': return hairColor;
        case 'makeup': return makeupColor
    }
})

const updateColor = (index: number) => {
    if (model.value != index) {
        model.value = index
    }
}

</script>
<style scoped lang="scss">
.color-panel {
    display: grid;
    grid-template-columns: repeat(10, 1fr);
    gap: 0.5vh;
}

.color-item {
    height: 3.5vh;
    display: flex;
    justify-content: center;
    align-items: center;
    font-weight: bold;
    font-size: 1.2vh;
    cursor: pointer;
    transition: scale 250ms cubic-bezier(0.175, 0.885, 0.32, 1.275);

    &:hover,
    &.selected {
        scale: 1.3;
        z-index: 20;
    }

    &.selected {
        border: 0.2vh solid black;
    }
}
</style>