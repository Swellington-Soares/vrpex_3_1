
-- Este arquivo pode ser usado para colocar marcador e blips estáticos.

local cfg = {}

---@type { name: string, sprite: integer, pos: vector3, color: integer, size: number}
cfg.blips = {
  { name = 'Teste de Blip', sprite = 53, pos = vec3(-1202.96 , -1566.143, 4.61 ), color = 17, size = 0.5 },
}


---@type { id: number, pos:vector3, direction?: vector3, size: vector3, rotation?: vector3, color?: {r: integer, g: integer, b:integer , a: integer}, updown: boolean, rotate: boolean, dict?: string, dictName?: string }[]
cfg.markers = {
}

return cfg
