const nuiRequest = async (endpoint: string, data: any) => {
    const rr = await fetch(`https://sw-appearance/${endpoint}`, { body: JSON.stringify(data), method: 'POST' })
    return await rr.json()
}

export { nuiRequest }