const clothes: Record<string, { id: number, label: string }> = {
    d1: { id: 1, label: "Máscaras", },
    d3: { id: 3, label: "Troncos", },
    d4: { id: 4, label: "Pernas", },
    d5: { id: 5, label: "Bolsas", },
    d6: { id: 6, label: "Sapatos", },
    d7: { id: 7, label: "Acessórios", },
    d8: { id: 8, label: "Camisetas Internas", },
    d9: { id: 9, label: "Coletes à Prova de Balas", },
    d11: { id: 11, label: "Blusas", },
}

const accessories: Record<string, { id: number, label: string }> = {
    p0: { id: 0, label: 'Chapéus' },
    p1: { id: 1, label: 'Óculos' },
    p2: { id: 2, label: 'Orelhas' },
    p6: { id: 6, label: 'Relógios' },
    p7: { id: 7, label: 'Pulseiras' }
}

export { clothes, accessories }