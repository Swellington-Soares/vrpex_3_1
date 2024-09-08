export type TBlendFace = {
    shapeFirst: number;
    shapeSecond: number;
    skinFirst: number;
    skinSecond: number;
    shapeMix: number;
    skinMix: number;
}

export type THair = {
    style: number;
    color1: number;
    color2: number;
    texture: number;
    pallete: number;
}

export type TComponent = {
    d: number;
    c: number;
    t: number;
}

export type TProp = TComponent

export type Overlay = {
    opacity: number;
    style: number;
    color1: number;
    color2?: number;
};

export type THeadOverlay = {
    blush: Overlay;
    chestHair: Overlay;
    complexion: Overlay;
    makeUp: Overlay;
    moleAndFreckles: Overlay;
    beard: Overlay;
    sunDamage: Overlay;
    blemishes: Overlay;
    lipstick: Overlay;
    eyebrows: Overlay;
    bodyBlemishes: Overlay;
    ageing: Overlay;
}

export type FaceFeatures = {
    noseWidth: number;
    nosePeakHigh: number;
    nosePeakSize: number;
    noseBoneHigh: number;
    nosePeakLowering: number;
    noseBoneTwist: number;
    eyeBrownHigh: number;
    eyeBrownForward: number;
    cheeksBoneHigh: number;
    cheeksBoneWidth: number;
    cheeksWidth: number;
    eyesOpening: number;
    lipsThickness: number;
    jawBoneWidth: number;
    jawBoneBackSize: number;
    chinBoneLowering: number;
    chinBoneLenght: number;
    chinBoneSize: number;
    chinHole: number;
    neckThickness: number;
};


export type TTattoo = [string | number, string | number];