<template>
    <q-dialog persistent maximized full-height full-width ref="dialogRef" @hide="onDialogHide">
        <div class="flex column justify-center items-center text-dialog">
            <span class="text-action text-bold text-uppercase">Finalizar?</span>
            <div class="btns">
                <q-btn flat @click.stop="onDialogOK()">sim</q-btn>
                <q-btn flat @click.stop="onDialogCancel()">não</q-btn>
            </div>
        </div>

    </q-dialog>
</template>

<script setup lang="ts">
import { useDialogPluginComponent } from 'quasar'

defineEmits([
    // REQUIRED; need to specify some events that your
    // component will emit through useDialogPluginComponent()
    ...useDialogPluginComponent.emits
])

const { dialogRef, onDialogHide, onDialogOK, onDialogCancel } = useDialogPluginComponent()

</script>

<style lang="scss" scoped>
.finish-dialog {
    position: fixed;
    left: 0;
    right: 0;
    top: 0;
    bottom: 0;
    z-index: 999;
    background-color: rgba(0, 0, 0, 0.818);
    display: flex !important;
    flex-direction: column !important;
}

.text-action {
    font-size: 5em;
    margin-bottom: 0.5em;
}

.btns {
    display: flex;
    gap: 2vh;
}

.text-dialog {
    background-color: rgba(0, 0, 0, 0.836);
}

@media screen and (min-width: 1900px) {
    .text-dialog {
        transform: scale(1.5);        
    }    

    .btns {        
        gap: 3em;
        scale: 1.5;
    }
    
}
</style>