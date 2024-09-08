interface TFaceOverlay {
    id: number;    
    current: number;
    max: number;
    opacity: number;
    color1Value: number;
    color2Value: number;
    label: string;
    color1: boolean;
    color2: boolean;
    colorType?: 'hair' | 'makeup',
    name?: string
}

const FaceOverlay: Record<string, TFaceOverlay> = {

    beard: { colorType: 'hair', id: 1, current: 0, max: 10, opacity: 1.0, color1Value: 0, color2Value: 0, label: "Barba/Bigode", color1: true, color2: false },
    eyebrows: { colorType: 'hair', id: 2, current: 0, max: 10, opacity: 1.0, color1Value: 0, color2Value: 0, label: "Sobrancelhas", color1: true, color2: false },
    makeUp: { colorType: 'makeup', id: 4, current: 0, max: 10, opacity: 1.0, color1Value: 0, color2Value: 0, label: "Maquiagem", color1: true, color2: true },
    blush: { colorType: 'makeup', id: 5, current: 0, max: 10, opacity: 1.0, color1Value: 0, color2Value: 0, label: "Blush", color1: true, color2: false },
    lipstick: { colorType: 'makeup', id: 8, current: 0, max: 10, opacity: 1.0, color1Value: 0, color2Value: 0, label: "Batom", color1: true, color2: false },
    chestHair: { colorType: 'hair', id: 10, current: 0, max: 10, opacity: 1.0, color1Value: 0, color2Value: 0, label: "Pelos no Peito", color1: true, color2: false },

    ageing: { id: 3, current: 0, max: 10, opacity: 1.0, color1Value: 0, color2Value: 0, label: "Envelhecimento", color1: false, color2: false },
    complexion: { id: 6, current: 0, max: 10, opacity: 1.0, color1Value: 0, color2Value: 0, label: "Textura da Pele", color1: false, color2: false },
    sunDamage: { id: 7, current: 0, max: 10, opacity: 1.0, color1Value: 0, color2Value: 0, label: "Danos Solares", color1: false, color2: false },
    moleAndFreckles: { id: 9, current: 0, max: 10, opacity: 1.0, color1Value: 0, color2Value: 0, label: "Sardas/Manchas", color1: false, color2: false },
    bodyBlemishes: { id: 11, current: 0, max: 10, opacity: 1.0, color1Value: 0, color2Value: 0, label: "Manchas no Corpo", color1: false, color2: false },
    blemishes: {  id: 0, current: 0, max: 10, opacity: 1.0, color1Value: 0, color2Value: 0, label: "Manchas", color1: false, color2: false },
}

export type { TFaceOverlay };
export { FaceOverlay  }