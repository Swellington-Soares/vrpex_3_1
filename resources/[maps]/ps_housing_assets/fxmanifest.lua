fx_version 'cerulean'
game "gta5"
author "Xirvin#0985 and Project Sloth"
version '1.2.2'
lua54 'yes'

files {
  'stream/starter_shells_k4mb1.ytyp'
}

this_is_a_map 'yes'
data_file 'DLC_ITYP_REQUEST' 'starter_shells_k4mb1.ytyp'

-- Fix for "stuck in black loading screen"
data_file 'DLC_ITYP_REQUEST' 'x64c:/levels/gta5/interiors/int_props/int_corporate.rpf/int_corporate.ytyp'
data_file 'DLC_ITYP_REQUEST' 'x64c:/levels/gta5/interiors/int_props/int_industrial.rpf/int_industrial.ytyp'
data_file 'DLC_ITYP_REQUEST' 'x64c:/levels/gta5/interiors/int_props/int_lev_des.rpf/int_lev_des.ytyp'
data_file 'DLC_ITYP_REQUEST' 'x64c:/levels/gta5/interiors/int_props/int_residential.rpf/int_residential.ytyp'
data_file 'DLC_ITYP_REQUEST' 'x64c:/levels/gta5/interiors/int_props/int_retail.rpf/int_retail.ytyp'
data_file 'DLC_ITYP_REQUEST' 'x64c:/levels/gta5/interiors/int_props/int_services.rpf/int_services.ytyp'

file 'stream/**.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/**.ytyp'
