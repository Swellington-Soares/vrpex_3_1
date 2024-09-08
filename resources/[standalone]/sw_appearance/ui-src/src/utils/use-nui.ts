import { ref, onMounted, onUnmounted, Ref } from 'vue';

interface NuiMessageData<T = unknown> {
  action: string;
  data: T;
}

type NuiHandlerSignature<T> = (data: T) => void;

export function useNuiEvent<T = unknown>(action: string, handler: NuiHandlerSignature<T>) {
  const savedHandler: Ref<NuiHandlerSignature<T>> = ref(handler);
  onMounted(() => {
    const eventListener = (event: MessageEvent<NuiMessageData<T>>) => {
      const { action: eventAction, data } = event.data;

      if (savedHandler.value) {
        if (eventAction === action) {
          savedHandler.value(data);
        }
      }
    };
    window.addEventListener('message', eventListener);
    onUnmounted(() => {
      window.removeEventListener('message', eventListener);
    });
  });
}
