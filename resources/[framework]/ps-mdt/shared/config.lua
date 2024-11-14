Config = Config or {}

Config.UsingPsHousing = true
Config.UsingDefaultQBApartments = false
Config.OnlyShowOnDuty = true

-- RECOMMENDED Fivemerr Images. DOES NOT EXPIRE.
-- YOU NEED TO SET THIS UP FOLLOW INSTRUCTIONS BELOW.
-- Documents: https://docs.fivemerr.com/integrations/mdt-scripts/ps-mdt
Config.FivemerrMugShot = true

-- Discord webhook for images. NOT RECOMMENDED, IMAGES EXPIRE.
Config.MugShotWebhook = false
Config.UseCQCMugshot = true

-- Front, Back Side. Use 4 for both sides, we recommend leaving at 1 for default.
Config.MugPhotos = 1

-- If set to true = Fine gets automatically removed from bank automatically charging the player.
-- If set to false = The fine gets sent as an Invoice to their phone and it us to the player to pay for it, can remain unpaid and ignored.
Config.BillVariation = true

-- If set to false (default) = The fine amount is just being removed from the player's bank account
-- If set to true = The fine amount is beeing added to the society account after being removed from the player's bank account
Config.QBBankingUse = false

-- Set up your inventory to automatically retrieve images when a weapon is registered at a weapon shop or self-registered.
-- If you're utilizing lj-inventory's latest version from GitHub, no further modifications are necessary.
-- However, if you're using a different inventory system, please refer to the "Inventory Edit | Automatic Add Weapons with images" section in ps-mdt's README.
Config.InventoryForWeaponsImages = "ox_inventory"

-- Only compatible with ox_inventory
Config.RegisterWeaponsAutomatically = true

-- Set to true to register all weapons that are added via AddItem in ox_inventory
Config.RegisterCreatedWeapons = true

-- "LegacyFuel", "lj-fuel", "ps-fuel"
Config.Fuel = "ps-fuel"

-- Google Docs Link
Config.sopLink = {
    ['police'] = '',
    ['ambulance'] = '',
    ['bcso'] = '',
    ['doj'] = '',
    ['sast'] = '',
    ['sasp'] = '',
    ['doc'] = '',
    ['lssd'] = '',
    ['sapr'] = '',
}

-- Google Docs Link
Config.RosterLink = {
    ['police'] = '',
    ['ambulance'] = '',
    ['bcso'] = '',
    ['doj'] = '',
    ['sast'] = '',
    ['sasp'] = '',
    ['doc'] = '',
    ['lssd'] = '',
    ['sapr'] = '',
}

Config.PoliceJobs = {
    ['police'] = true,
    -- ['lspd'] = true,
    -- ['bcso'] = true,
    -- ['sast'] = true,
    -- ['sasp'] = true,
    -- ['doc'] = true,
    -- ['lssd'] = true,
    -- ['sapr'] = true,
    -- ['pa'] = true
}

Config.AmbulanceJobs = {
    ['emergency'] = true,
    -- ['doctor'] = true
}

Config.DojJobs = {
    -- ['lawyer'] = true,
    -- ['judge'] = true
}

-- This is a workaround solution because the qb-menu present in qb-policejob fills in an impound location and sends it to the event.
-- If the impound locations are modified in qb-policejob, the changes must also be implemented here to ensure consistency.

Config.ImpoundLocations = {
    [1] = vector4(436.68, -1007.42, 27.32, 180.0),
    [2] = vector4(-436.14, 5982.63, 31.34, 136.0),
}

-- Support for Wraith ARS 2X.

Config.UseWolfknightRadar = false
Config.WolfknightNotifyTime = 5000        -- How long the notification displays for in milliseconds (30000 = 30 seconds)
Config.PlateScanForDriversLicense = false -- If true, plate scanner will check if the owner of the scanned vehicle has a drivers license

-- IMPORTANT: To avoid making excessive database queries, modify this config to true 'CONFIG.use_sonorancad = true' setting in the configuration file located at 'wk_wars2x/config.lua'.
-- Enabling this setting will limit plate checks to only those vehicles that have been used by a player.

Config.LogPerms = {
    ['ambulance'] = {
        [4] = true,
    },
    ['police'] = {
        [4] = true,
    },
    -- ['bcso'] = {
    -- 	[4] = true,
    -- },
    -- ['sast'] = {
    -- 	[4] = true,
    -- },
    -- ['sasp'] = {
    -- 	[4] = true,
    -- },
    -- ['sapr'] = {
    -- 	[4] = true,
    -- },
    -- ['doc'] = {
    -- 	[4] = true,
    -- },
    -- ['lssd'] = {
    -- 	[4] = true,
    -- },
}

Config.RemoveIncidentPerms = {
    ['ambulance'] = {
        [4] = true,
    },
    ['police'] = {
        [4] = true,
    },
    -- ['bcso'] = {
    -- 	[4] = true,
    -- },
    -- ['sast'] = {
    -- 	[4] = true,
    -- },
    -- ['sasp'] = {
    -- 	[4] = true,
    -- },
    -- ['sapr'] = {
    -- 	[4] = true,
    -- },
    -- ['doc'] = {
    -- 	[4] = true,
    -- },
    -- ['lssd'] = {
    -- 	[4] = true,
    -- },
}

Config.RemoveReportPerms = {
    ['ambulance'] = {
        [4] = true,
    },
    ['police'] = {
        [4] = true,
    },
    -- ['bcso'] = {
    -- 	[4] = true,
    -- },
    -- ['sast'] = {
    -- 	[4] = true,
    -- },
    -- ['sasp'] = {
    -- 	[4] = true,
    -- },
    -- ['sapr'] = {
    -- 	[4] = true,
    -- },
    -- ['doc'] = {
    -- 	[4] = true,
    -- },
    -- ['lssd'] = {
    -- 	[4] = true,
    -- },
}

Config.RemoveWeaponsPerms = {
    ['ambulance'] = {
        [4] = true,
    },
    ['police'] = {
        [4] = true,
    },
    ['bcso'] = {
        [4] = true,
    },
    ['sast'] = {
        [4] = true,
    },
    ['sasp'] = {
        [4] = true,
    },
    ['sapr'] = {
        [4] = true,
    },
    ['doc'] = {
        [4] = true,
    },
    ['lssd'] = {
        [4] = true,
    },
}

Config.PenalCodeTitles = {
    [1] = 'OFFENSES AGAINST PERSONS',
    [2] = 'OFFENSES INVOLVING THEFT',
    [3] = 'OFFENSES INVOLVING FRAUD',
    [4] = 'OFFENSES INVOLVING DAMAGE TO PROPERTY',
    [5] = 'OFFENSES AGAINST PUBLIC ADMINISTRATION',
    [6] = 'OFFENSES AGAINST PUBLIC ORDER',
    [7] = 'OFFENSES AGAINST HEALTH AND MORALS',
    [8] = 'OFFENSES AGAINST PUBLIC SAFETY',
    [9] = 'OFFENSES INVOLVING THE OPERATION OF A VEHICLE',
    [10] = 'OFFENSES INVOLVING THE WELL-BEING OF WILDLIFE',
}

Config.PenalCode = {
    [1] = {
        [1] = { title = 'Agressão Simples', class = 'Contravenção Penal', id = 'C.P. 1001', months = 7, fine = 500, color = 'verde', description = 'Quando uma pessoa intencionalmente ou conscientemente causa contato físico com outra (sem uma arma)' },
        [2] = { title = 'Agressão', class = 'Contravenção Penal', id = 'C.P. 1002', months = 15, fine = 850, color = 'laranja', description = 'Se uma pessoa intencionalmente ou conscientemente causa lesão a outra (sem uma arma)' },
        [3] = { title = 'Agressão Agravada', class = 'Crime', id = 'C.P. 1003', months = 20, fine = 1250, color = 'laranja', description = 'Quando uma pessoa, sem intenção, e de forma imprudente, causa lesão corporal a outra como resultado de uma confrontação E causa lesão corporal' },
        [4] = { title = 'Agressão com Arma Letal', class = 'Crime', id = 'C.P. 1004', months = 30, fine = 3750, color = 'vermelho', description = 'Quando uma pessoa intencionalmente, conscientemente ou imprudentemente causa lesão corporal a outra pessoa E causa lesão grave ou usa ou exibe uma arma letal' },
        [5] = { title = 'Homicídio Culposo', class = 'Crime', id = 'C.P. 1005', months = 60, fine = 7500, color = 'vermelho', description = 'Quando uma pessoa, sem intenção e de forma imprudente, causa a morte de outra' },
        [6] = { title = 'Homicídio Culposo com Veículo', class = 'Crime', id = 'C.P. 1006', months = 75, fine = 7500, color = 'vermelho', description = 'Quando uma pessoa, sem intenção e de forma imprudente, causa a morte de outra com um veículo' },
        [7] = { title = 'Tentativa de Homicídio de Civil', class = 'Crime', id = 'C.P. 1007', months = 50, fine = 7500, color = 'vermelho', description = 'Quando uma pessoa não governamental ataca outra com a intenção de matar' },
        [8] = { title = 'Homicídio de Segundo Grau', class = 'Crime', id = 'C.P. 1008', months = 100, fine = 15000, color = 'vermelho', description = 'Qualquer assassinato intencional que não seja premeditado ou planejado. Situação em que o assassino pretende apenas infligir lesão corporal grave.' },
        [9] = { title = 'Cúmplice de Homicídio de Segundo Grau', class = 'Crime', id = 'C.P. 1009', months = 50, fine = 5000, color = 'vermelho', description = 'Estar presente e/ou participar do ato do crime principal' },
        [10] = { title = 'Homicídio de Primeiro Grau', class = 'Crime', id = 'C.P. 1010', months = 0, fine = 0, color = 'vermelho', description = 'Qualquer assassinato intencional que seja deliberado e premeditado com maldade.' },
        [11] = { title = 'Cúmplice de Homicídio de Primeiro Grau', class = 'Crime', id = 'C.P. 1011', months = 0, fine = 0, color = 'vermelho', description = 'Estar presente e/ou participar do ato do crime principal' },
        [12] = { title = 'Assassinato de Servidor Público ou Oficial de Paz', class = 'Crime', id = 'C.P. 1012', months = 0, fine = 0, color = 'vermelho', description = 'Qualquer assassinato intencional cometido contra um funcionário do governo' },
        [13] = { title = 'Tentativa de Assassinato de Servidor Público ou Oficial de Paz', class = 'Crime', id = 'C.P. 1013', months = 65, fine = 10000, color = 'vermelho', description = 'Qualquer ataque feito contra um funcionário do governo com intenção de causar morte' },
        [14] = { title = 'Cúmplice de Assassinato de Servidor Público ou Oficial de Paz', class = 'Crime', id = 'C.P. 1014', months = 0, fine = 0, color = 'vermelho', description = 'Estar presente e/ou participar do ato do crime principal' },
        [15] = { title = 'Prisão Ilegal', class = 'Contravenção Penal', id = 'C.P. 1015', months = 10, fine = 600, color = 'verde', description = 'O ato de tomar outra pessoa contra sua vontade e mantê-la por um período prolongado' },
        [16] = { title = 'Sequestro', class = 'Crime', id = 'C.P. 1016', months = 15, fine = 900, color = 'laranja', description = 'O ato de tomar outra pessoa contra sua vontade por um curto período de tempo' },
        [17] = { title = 'Cúmplice de Sequestro', class = 'Crime', id = 'C.P. 1017', months = 7, fine = 450, color = 'laranja', description = 'Estar presente e/ou participar do ato do crime principal' },
        [18] = { title = 'Tentativa de Sequestro', class = 'Crime', id = 'C.P. 1018', months = 10, fine = 450, color = 'laranja', description = 'O ato de tentar tomar alguém contra sua vontade' },
        [19] = { title = 'Tomada de Refém', class = 'Crime', id = 'C.P. 1019', months = 20, fine = 1200, color = 'laranja', description = 'O ato de tomar outra pessoa contra sua vontade para ganho pessoal' },
        [20] = { title = 'Cúmplice de Tomada de Refém', class = 'Crime', id = 'C.P. 1020', months = 10, fine = 600, color = 'laranja', description = 'Estar presente e/ou participar do ato do crime principal' },
        [21] = { title = 'Prisão Ilegal de Servidor Público ou Oficial de Paz', class = 'Crime', id = 'C.P. 1021', months = 25, fine = 4000, color = 'laranja', description = 'O ato de tomar um funcionário do governo contra sua vontade por um período prolongado' },
        [22] = { title = 'Ameaças Criminosas', class = 'Contravenção Penal', id = 'C.P. 1022', months = 5, fine = 500, color = 'laranja', description = 'O ato de declarar a intenção de cometer um crime contra outra pessoa' },
        [23] = { title = 'Perigo Imprudente', class = 'Contravenção Penal', id = 'C.P. 1023', months = 10, fine = 1000, color = 'laranja', description = 'O ato de desconsiderar a segurança de outra pessoa, colocando-a em risco de morte ou lesão corporal' },
        [24] = { title = 'Tiroteio Relacionado a Gangues', class = 'Crime', id = 'C.P. 1024', months = 30, fine = 2500, color = 'vermelho', description = 'O ato em que uma arma de fogo é disparada em relação à atividade de gangues' },
        [25] = { title = 'Canibalismo', class = 'Crime', id = 'C.P. 1025', months = 0, fine = 0, color = 'vermelho', description = 'O ato em que uma pessoa consome voluntariamente a carne de outra' },
        [26] = { title = 'Tortura', class = 'Crime', id = 'C.P. 1026', months = 40, fine = 4500, color = 'vermelho', description = 'O ato de causar dano a outra pessoa para extrair informações ou para prazer próprio' },
    },
    [2] = {
        [1] = { title = 'Furto de Pequeno Valor', class = 'Infração', id = 'P.C. 2001', months = 0, fine = 250, color = 'verde', description = 'O furto de propriedade com valor abaixo de $50' },
        [2] = { title = 'Furto Qualificado', class = 'Contravenção', id = 'P.C. 2002', months = 10, fine = 600, color = 'verde', description = 'Furto de propriedade com valor acima de $700' },
        [3] = { title = 'Furto de Veículo A', class = 'Crime Grave', id = 'P.C. 2003', months = 15, fine = 900, color = 'verde', description = 'O ato de roubar um veículo pertencente a outra pessoa sem permissão' },
        [4] = { title = 'Furto de Veículo B', class = 'Crime Grave', id = 'P.C. 2004', months = 35, fine = 3500, color = 'verde', description = 'O ato de roubar um veículo pertencente a outra pessoa sem permissão enquanto armado' },
        [5] = { title = 'Roubo de Carro', class = 'Crime Grave', id = 'P.C. 2005', months = 30, fine = 2000, color = 'laranja', description = 'O ato de alguém tomar forçadamente um veículo de seus ocupantes' },
        [6] = { title = 'Invasão de Domicílio', class = 'Contravenção', id = 'P.C. 2006', months = 10, fine = 500, color = 'verde', description = 'O ato de entrar ilegalmente em um prédio com intenção de cometer um crime, especialmente furto.' },
        [7] = { title = 'Roubo', class = 'Crime Grave', id = 'P.C. 2007', months = 25, fine = 2000, color = 'verde', description = 'A ação de tomar propriedade ilegalmente de uma pessoa ou lugar por força ou ameaça de força.' },
        [8] = { title = 'Cúmplice de Roubo', class = 'Crime Grave', id = 'P.C. 2008', months = 12, fine = 1000, color = 'verde', description = 'Estar presente e/ou participar no ato do crime principal' },
        [9] = { title = 'Tentativa de Roubo', class = 'Crime Grave', id = 'P.C. 2009', months = 20, fine = 1000, color = 'verde', description = 'Ação de tentar tomar propriedade ilegalmente de uma pessoa ou lugar por força ou ameaça de força.' },
        [10] = { title = 'Roubo à Mão Armada', class = 'Crime Grave', id = 'P.C. 2010', months = 30, fine = 3000, color = 'laranja', description = 'Ação de tomar propriedade ilegalmente de uma pessoa ou lugar por força ou ameaça de força enquanto armado.' },
        [11] = { title = 'Cúmplice de Roubo à Mão Armada', class = 'Crime Grave', id = 'P.C. 2011', months = 15, fine = 1500, color = 'laranja', description = 'Estar presente e/ou participar no ato do crime principal' },
        [12] = { title = 'Tentativa de Roubo à Mão Armada', class = 'Crime Grave', id = 'P.C. 2012', months = 25, fine = 1500, color = 'laranja', description = 'Ação de tentar tomar propriedade ilegalmente de uma pessoa ou lugar por força ou ameaça de força enquanto armado.' },
        [13] = { title = 'Grande Furto', class = 'Crime Grave', id = 'P.C. 2013', months = 45, fine = 7500, color = 'laranja', description = 'Furto de propriedade pessoal com valor acima de uma quantia legalmente especificada.' },
        [14] = { title = 'Sair Sem Pagar', class = 'Infração', id = 'P.C. 2014', months = 0, fine = 500, color = 'verde', description = 'O ato de sair de um estabelecimento sem pagar pelo serviço fornecido' },
        [15] = { title = 'Posse de Moeda Não Legal', class = 'Contravenção', id = 'P.C. 2015', months = 10, fine = 750, color = 'verde', description = 'Estar em posse de moeda roubada' },
        [16] = { title = 'Posse de Itens Emitidos pelo Governo', class = 'Contravenção', id = 'P.C. 2016', months = 15, fine = 1000, color = 'verde', description = 'Estar em posse de itens adquiridos apenas por funcionários do governo' },
        [17] = { title = 'Posse de Itens Usados na Comissão de um Crime', class = 'Contravenção', id = 'P.C. 2017', months = 10, fine = 500, color = 'verde', description = 'Estar em posse de itens que foram previamente usados para cometer crimes' },
        [18] = { title = 'Venda de Itens Usados na Comissão de um Crime', class = 'Crime Grave', id = 'P.C. 2018', months = 15, fine = 1000, color = 'laranja', description = 'O ato de vender itens que foram previamente usados para cometer crimes' },
        [19] = { title = 'Roubo de Aeronave', class = 'Crime Grave', id = 'P.C. 2019', months = 20, fine = 1000, color = 'verde', description = 'O ato de roubar uma aeronave' },
    },
    [3] = {
        [1] = { title = 'Personificação', class = 'Contravenção', id = 'P.C. 3001', months = 15, fine = 1250, color = 'verde', description = 'A ação de se passar falsamente por outra pessoa para enganar' },
        [2] = { title = 'Personificação de um Oficial de Paz ou Servidor Público', class = 'Crime Grave', id = 'P.C. 3002', months = 25, fine = 2750, color = 'verde', description = 'A ação de se passar falsamente por um funcionário do governo para enganar' },
        [3] = { title = 'Personificação de um Juiz', class = 'Crime Grave', id = 'P.C. 3003', months = 0, fine = 0, color = 'verde', description = 'A ação de se passar falsamente por um Juiz para enganar' },
        [4] = { title = 'Posse de Identificação Roubada', class = 'Contravenção', id = 'P.C. 3004', months = 10, fine = 750, color = 'verde', description = 'Estar em posse da identificação de outra pessoa sem consentimento' },
        [5] = { title = 'Posse de Identificação Governamental Roubada', class = 'Contravenção', id = 'P.C. 3005', months = 20, fine = 2000, color = 'verde', description = 'Estar em posse da identificação de um funcionário do governo sem consentimento' },
        [6] = { title = 'Extorsão', class = 'Crime Grave', id = 'P.C. 3006', months = 20, fine = 900, color = 'laranja', description = 'Ameaçar ou causar dano a uma pessoa ou propriedade para obter ganho financeiro' },
        [7] = { title = 'Fraude', class = 'Contravenção', id = 'P.C. 3007', months = 10, fine = 450, color = 'verde', description = 'Enganar outra pessoa para obter ganho financeiro' },
        [8] = { title = 'Falsificação', class = 'Contravenção', id = 'P.C. 3008', months = 15, fine = 750, color = 'verde', description = 'Falsificar documentos legais para ganho pessoal' },
        [9] = { title = 'Lavagem de Dinheiro', class = 'Crime Grave', id = 'P.C. 3009', months = 0, fine = 0, color = 'vermelho', description = 'O processo de converter dinheiro roubado em moeda legal' },
    },
    [4] = {
        [1] = { title = 'Invasão de Propriedade', class = 'Contravenção', id = 'P.C. 4001', months = 10, fine = 450, color = 'verde', description = 'Quando uma pessoa está dentro dos limites de um local no qual ela não tem permissão legal para estar' },
        [2] = { title = 'Invasão de Propriedade Grave', class = 'Crime Grave', id = 'P.C. 4002', months = 15, fine = 1500, color = 'verde', description = 'Quando uma pessoa entra repetidamente nos limites de um local onde ela sabe que não tem permissão legal' },
        [3] = { title = 'Incêndio Criminoso', class = 'Crime Grave', id = 'P.C. 4003', months = 15, fine = 1500, color = 'laranja', description = 'O uso de fogo e acelerantes de forma intencional e maliciosa para destruir, causar dano ou morte a uma pessoa ou propriedade' },
        [4] = { title = 'Vandalismo', class = 'Infração', id = 'P.C. 4004', months = 0, fine = 300, color = 'verde', description = 'A destruição intencional de propriedade' },
        [5] = { title = 'Vandalismo de Propriedade Governamental', class = 'Crime Grave', id = 'P.C. 4005', months = 20, fine = 1500, color = 'verde', description = 'A destruição intencional de propriedade governamental' },
        [6] = { title = 'Descarte Irregular de Lixo', class = 'Infração', id = 'P.C. 4006', months = 0, fine = 200, color = 'verde', description = 'O descarte intencional de lixo em local aberto e não em lixeiras designadas' },
    },
    [5] = {
        [1] = { title = 'Suborno de um Oficial do Governo', class = 'Crime Grave', id = 'P.C. 5001', months = 20, fine = 3500, color = 'verde', description = 'O uso de dinheiro, favores e/ou propriedades para obter vantagem com um oficial do governo' },
        [2] = { title = 'Lei Anti-Máscara', class = 'Infração', id = 'P.C. 5002', months = 0, fine = 750, color = 'verde', description = 'Usar uma máscara em uma zona proibida' },
        [3] = { title = 'Posse de Contrabando em Instalação Governamental', class = 'Crime Grave', id = 'P.C. 5003', months = 25, fine = 1000, color = 'verde', description = 'Estar em posse de itens ilegais dentro de um prédio do governo' },
        [4] = { title = 'Posse Criminosa de Propriedade Roubada', class = 'Contravenção', id = 'P.C. 5004', months = 10, fine = 500, color = 'verde', description = 'Estar em posse de itens roubados, sabendo ou não' },
        [5] = { title = 'Fuga', class = 'Crime Grave', id = 'P.C. 5005', months = 10, fine = 450, color = 'verde', description = 'O ato de fugir de custódia, sabendo e intencionalmente, enquanto preso, detido ou na cadeia' },
        [6] = { title = 'Fuga da Prisão', class = 'Crime Grave', id = 'P.C. 5006', months = 30, fine = 2500, color = 'laranja', description = 'O ato de deixar a custódia estadual de uma instalação de detenção estadual ou condal' },
        [7] = { title = 'Cúmplice em Fuga da Prisão', class = 'Crime Grave', id = 'P.C. 5007', months = 25, fine = 2000, color = 'laranja', description = 'Estar presente e/ou participar do ato principal' },
        [8] = { title = 'Tentativa de Fuga da Prisão', class = 'Crime Grave', id = 'P.C. 5008', months = 20, fine = 1500, color = 'laranja', description = 'A tentativa intencional e deliberada de escapar de uma instalação de detenção estadual ou condal' },
        [9] = { title = 'Perjúrio', class = 'Crime Grave', id = 'P.C. 5009', months = 0, fine = 0, color = 'verde', description = 'O ato de declarar falsidades enquanto legalmente obrigado a falar a verdade' },
        [10] = { title = 'Violação de Ordem de Restrição', class = 'Crime Grave', id = 'P.C. 5010', months = 20, fine = 2250, color = 'verde', description = 'A infração deliberada e consciente de uma ordem de proteção emitida pelo tribunal' },
        [11] = { title = 'Desfalque', class = 'Crime Grave', id = 'P.C. 5011', months = 45, fine = 10000, color = 'verde', description = 'O desvio consciente e intencional de fundos de contas não pessoais para contas pessoais para ganho pessoal' },
        [12] = { title = 'Exercício Ilegal de Profissão', class = 'Crime Grave', id = 'P.C. 5012', months = 15, fine = 1500, color = 'laranja', description = 'O ato de realizar um serviço sem a devida licença legal e aprovação' },
        [13] = { title = 'Uso Indevido de Sistemas de Emergência', class = 'Infração', id = 'P.C. 5013', months = 0, fine = 600, color = 'laranja', description = 'Uso de equipamentos de emergência governamentais para fins não destinados' },
        [14] = { title = 'Conspiração', class = 'Contravenção', id = 'P.C. 5014', months = 10, fine = 450, color = 'verde', description = 'O ato de planejar um crime, mas ainda não cometê-lo' },
        [15] = { title = 'Violação de Ordem Judicial', class = 'Contravenção', id = 'P.C. 5015', months = 0, fine = 0, color = 'laranja', description = 'A infração de documentação emitida pelo tribunal' },
        [16] = { title = 'Falta de Comparecimento', class = 'Contravenção', id = 'P.C. 5016', months = 0, fine = 0, color = 'laranja', description = 'Quando alguém que é legalmente obrigado a comparecer no tribunal não o faz' },
        [17] = { title = 'Desacato ao Tribunal', class = 'Crime Grave', id = 'P.C. 5017', months = 0, fine = 0, color = 'laranja', description = 'A interrupção de procedimentos judiciais em uma sala de audiência durante a sessão (decisão judicial)' },
        [18] = { title = 'Resistência à Prisão', class = 'Contravenção', id = 'P.C. 5018', months = 5, fine = 300, color = 'laranja', description = 'O ato de não permitir que os policiais te prendam voluntariamente' },
    },
    [6] = {
        [1] = { title = 'Desobediência a um Oficial de Paz', class = 'Infração', id = 'C.P. 6001', months = 0, fine = 750, color = 'green', description = 'Desrespeitar uma ordem legal de forma intencional' },
        [2] = { title = 'Conduta Desordeira', class = 'Infração', id = 'C.P. 6002', months = 0, fine = 250, color = 'green', description = 'Agir de forma que crie uma condição perigosa ou fisicamente ofensiva sem propósito legítimo' },
        [3] = { title = 'Perturbação da Paz', class = 'Infração', id = 'C.P. 6003', months = 0, fine = 350, color = 'green', description = 'Ação que causa inquietação e perturba a ordem pública' },
        [4] = { title = 'Falsa Denúncia', class = 'Contravenção', id = 'C.P. 6004', months = 10, fine = 750, color = 'green', description = 'O ato de denunciar um crime que não ocorreu' },
        [5] = { title = 'Assédio', class = 'Contravenção', id = 'C.P. 6005', months = 10, fine = 500, color = 'orange', description = 'Ataques repetidos ou verbais contra outra pessoa' },
        [6] = { title = 'Obstrução da Justiça (Contravenção)', class = 'Contravenção', id = 'C.P. 6006', months = 10, fine = 500, color = 'green', description = 'Ato de obstruir o processo de Justiça ou investigações legais' },
        [7] = { title = 'Obstrução da Justiça (Crime)', class = 'Crime', id = 'C.P. 6007', months = 15, fine = 900, color = 'green', description = 'Obstrução do processo de Justiça ou investigações legais com o uso de violência' },
        [8] = { title = 'Incitação a Motim', class = 'Crime', id = 'C.P. 6008', months = 25, fine = 1000, color = 'orange', description = 'Causar distúrbio civil de maneira a incitar um grupo a causar dano a pessoas ou propriedades' },
        [9] = { title = 'Permanência Ilegal em Propriedade do Governo', class = 'Infração', id = 'C.P. 6009', months = 0, fine = 500, color = 'green', description = 'Estar presente em uma propriedade do governo por um período de tempo prolongado' },
        [10] = { title = 'Interferência', class = 'Contravenção', id = 'C.P. 6010', months = 10, fine = 500, color = 'green', description = 'Ato de interferir de maneira intencional em uma investigação legal' },
        [11] = { title = 'Interferência em Veículos', class = 'Contravenção', id = 'C.P. 6011', months = 15, fine = 750, color = 'green', description = 'Ato de interferir intencionalmente no funcionamento normal de um veículo' },
        [12] = { title = 'Manipulação de Provas', class = 'Crime', id = 'C.P. 6012', months = 20, fine = 1000, color = 'green', description = 'Ato de interferir intencionalmente em evidências de uma investigação legal' },
        [13] = { title = 'Manipulação de Testemunhas', class = 'Crime', id = 'C.P. 6013', months = 0, fine = 0, color = 'green', description = 'Ato de coagir ou influenciar uma testemunha em uma investigação legal' },
        [14] = { title = 'Falha em Apresentar Identificação', class = 'Contravenção', id = 'C.P. 6014', months = 15, fine = 1500, color = 'green', description = 'Não apresentar identificação quando legalmente exigido' },
        [15] = { title = 'Vigilantismo', class = 'Crime', id = 'C.P. 6015', months = 30, fine = 1500, color = 'orange', description = 'Ato de fazer justiça com as próprias mãos sem autorização legal' },
        [16] = { title = 'Reunião Ilegal', class = 'Contravenção', id = 'C.P. 6016', months = 10, fine = 750, color = 'orange', description = 'Quando um grupo se reúne em um local que requer aprovação prévia' },
        [17] = { title = 'Corrupção Governamental', class = 'Crime', id = 'C.P. 6017', months = 0, fine = 0, color = 'red', description = 'O uso de posição política e poder para ganho pessoal' },
        [18] = { title = 'Perseguição', class = 'Crime', id = 'C.P. 6018', months = 40, fine = 1500, color = 'orange', description = 'Quando uma pessoa monitora outra sem o consentimento dela' },
        [19] = { title = 'Auxílio e Cumplicidade', class = 'Contravenção', id = 'C.P. 6019', months = 15, fine = 450, color = 'orange', description = 'Ajudar ou encorajar alguém a cometer um crime' },
        [20] = { title = 'Abrigo a um Fugitivo', class = 'Contravenção', id = 'C.P. 6020', months = 10, fine = 1000, color = 'green', description = 'Esconder alguém que é procurado pelas autoridades' },
    },
    [7] = {
        [1] = { title = 'Posse de Maconha como Contravenção', class = 'Contravenção', id = 'C.P. 7001', months = 5, fine = 250, color = 'verde', description = 'A posse de uma quantidade de maconha menor que 4 cigarros' },
        [2] = { title = 'Fabricação de Maconha como Crime Grave', class = 'Crime Grave', id = 'C.P. 7002', months = 15, fine = 1000, color = 'vermelho', description = 'A posse de uma quantidade de maconha resultante de fabricação' },
        [3] = { title = 'Cultivo de Maconha A', class = 'Contravenção', id = 'C.P. 7003', months = 10, fine = 750, color = 'verde', description = 'A posse de 4 ou menos plantas de maconha' },
        [4] = { title = 'Cultivo de Maconha B', class = 'Crime Grave', id = 'C.P. 7004', months = 30, fine = 1500, color = 'laranja', description = 'A posse de 5 ou mais plantas de maconha' },
        [5] = { title = 'Posse de Maconha com Intenção de Distribuir', class = 'Crime Grave', id = 'C.P. 7005', months = 30, fine = 3000, color = 'laranja', description = 'A posse de uma quantidade de maconha para distribuição' },
        [6] = { title = 'Posse de Cocaína como Contravenção', class = 'Contravenção', id = 'C.P. 7006', months = 7, fine = 500, color = 'verde', description = 'A posse de uma pequena quantidade de cocaína, geralmente para uso pessoal' },
        [7] = { title = 'Fabricação de Cocaína como Crime Grave', class = 'Crime Grave', id = 'C.P. 7007', months = 25, fine = 1500, color = 'vermelho', description = 'A posse de uma quantidade de cocaína resultante de fabricação' },
        [8] = { title = 'Posse de Cocaína com Intenção de Distribuir', class = 'Crime Grave', id = 'C.P. 7008', months = 35, fine = 4500, color = 'laranja', description = 'A posse de uma quantidade de cocaína para distribuição' },
        [9] = { title = 'Posse de Metanfetamina como Contravenção', class = 'Contravenção', id = 'C.P. 7009', months = 7, fine = 500, color = 'verde', description = 'A posse de uma pequena quantidade de metanfetamina, geralmente para uso pessoal' },
        [10] = { title = 'Fabricação de Metanfetamina como Crime Grave', class = 'Crime Grave', id = 'C.P. 7010', months = 25, fine = 1500, color = 'vermelho', description = 'A posse de uma quantidade de metanfetamina resultante de fabricação' },
        [11] = { title = 'Posse de Metanfetamina com Intenção de Distribuir', class = 'Crime Grave', id = 'C.P. 7011', months = 35, fine = 4500, color = 'laranja', description = 'A posse de uma quantidade de metanfetamina para distribuição' },
        [12] = { title = 'Posse de Oxy / Vicodin como Contravenção', class = 'Contravenção', id = 'C.P. 7012', months = 7, fine = 500, color = 'verde', description = 'A posse de uma pequena quantidade de oxy / vicodin, geralmente para uso pessoal sem prescrição' },
        [13] = { title = 'Fabricação de Oxy / Vicodin como Crime Grave', class = 'Crime Grave', id = 'C.P. 7013', months = 25, fine = 1500, color = 'vermelho', description = 'A posse de uma quantidade de oxy / vicodin resultante de fabricação' },
        [14] = { title = 'Posse de Oxy / Vicodin com Intenção de Distribuir', class = 'Crime Grave', id = 'C.P. 7014', months = 35, fine = 4500, color = 'laranja', description = 'A posse de uma quantidade de oxy / vicodin para distribuição' },
        [15] = { title = 'Posse de Ecstasy como Contravenção', class = 'Contravenção', id = 'C.P. 7015', months = 7, fine = 500, color = 'verde', description = 'A posse de uma pequena quantidade de ecstasy, geralmente para uso pessoal' },
        [16] = { title = 'Fabricação de Ecstasy como Crime Grave', class = 'Crime Grave', id = 'C.P. 7016', months = 25, fine = 1500, color = 'vermelho', description = 'A posse de uma quantidade de ecstasy resultante de fabricação' },
        [17] = { title = 'Posse de Ecstasy com Intenção de Distribuir', class = 'Crime Grave', id = 'C.P. 7017', months = 35, fine = 4500, color = 'laranja', description = 'A posse de uma quantidade de ecstasy para distribuição' },
        [18] = { title = 'Posse de Ópio como Contravenção', class = 'Contravenção', id = 'C.P. 7018', months = 7, fine = 500, color = 'verde', description = 'A posse de uma pequena quantidade de ópio, geralmente para uso pessoal' },
        [19] = { title = 'Fabricação de Ópio como Crime Grave', class = 'Crime Grave', id = 'C.P. 7019', months = 25, fine = 1500, color = 'vermelho', description = 'A posse de uma quantidade de ópio resultante de fabricação' },
        [20] = { title = 'Posse de Ópio com Intenção de Distribuir', class = 'Crime Grave', id = 'C.P. 7020', months = 35, fine = 4500, color = 'laranja', description = 'A posse de uma quantidade de ópio para distribuição' },
        [21] = { title = 'Posse de Adderall como Contravenção', class = 'Contravenção', id = 'C.P. 7021', months = 7, fine = 500, color = 'verde', description = 'A posse de uma pequena quantidade de adderall, geralmente para uso pessoal sem prescrição' },
        [22] = { title = 'Fabricação de Adderall como Crime Grave', class = 'Crime Grave', id = 'C.P. 7022', months = 25, fine = 1500, color = 'vermelho', description = 'A posse de uma quantidade de adderall resultante de fabricação' },
        [23] = { title = 'Posse de Adderall com Intenção de Distribuir', class = 'Crime Grave', id = 'C.P. 7023', months = 35, fine = 4500, color = 'laranja', description = 'A posse de uma quantidade de adderall para distribuição' },
        [24] = { title = 'Posse de Xanax como Contravenção', class = 'Contravenção', id = 'C.P. 7024', months = 7, fine = 500, color = 'verde', description = 'A posse de uma pequena quantidade de xanax, geralmente para uso pessoal sem prescrição' },
        [25] = { title = 'Fabricação de Xanax como Crime Grave', class = 'Crime Grave', id = 'C.P. 7025', months = 25, fine = 1500, color = 'vermelho', description = 'A posse de uma quantidade de xanax resultante de fabricação' },
        [26] = { title = 'Posse de Xanax com Intenção de Distribuir', class = 'Crime Grave', id = 'C.P. 7026', months = 35, fine = 4500, color = 'laranja', description = 'A posse de uma quantidade de xanax para distribuição' },
        [27] = { title = 'Posse de Cogumelos como Contravenção', class = 'Contravenção', id = 'C.P. 7027', months = 7, fine = 500, color = 'verde', description = 'A posse de uma pequena quantidade de cogumelos, geralmente para uso pessoal' },
        [28] = { title = 'Fabricação de Cogumelos como Crime Grave', class = 'Crime Grave', id = 'C.P. 7028', months = 25, fine = 1500, color = 'vermelho', description = 'A posse de uma quantidade de cogumelos resultante de fabricação' },
        [29] = { title = 'Posse de Shrooms com intenção de distribuir', class = 'Grau Maior', id = 'P.C. 7029', months = 35, fine = 4500, color = 'laranja', description = 'A posse de uma quantidade de shrooms para distribuição' },
        [30] = { title = 'Posse de LSD de menor grau', class = 'Menor Grau', id = 'P.C. 7030', months = 7, fine = 500, color = 'verde', description = 'A posse de LSD em pequena quantidade, geralmente para uso pessoal' },
        [31] = { title = 'Fabricação de posse de LSD de grau maior', class = 'Grau Maior', id = 'P.C. 7031', months = 25, fine = 1500, color = 'vermelho', description = 'A posse de uma quantidade de LSD proveniente de fabricação' },
        [32] = { title = 'Posse de LSD com intenção de distribuir', class = 'Grau Maior', id = 'P.C. 7032', months = 35, fine = 4500, color = 'laranja', description = 'A posse de uma quantidade de LSD para distribuição' },
        [33] = { title = 'Posse de Methaqualona de menor grau', class = 'Menor Grau', id = 'P.C. 7033', months = 7, fine = 500, color = 'verde', description = 'A posse de Methaqualona em pequena quantidade, geralmente para uso pessoal' },
        [34] = { title = 'Fabricação de posse de Methaqualona de grau maior', class = 'Grau Maior', id = 'P.C. 7034', months = 25, fine = 1500, color = 'vermelho', description = 'A posse de uma quantidade de Methaqualona proveniente de fabricação' },
        [35] = { title = 'Posse de Methaqualona com intenção de distribuir', class = 'Grau Maior', id = 'P.C. 7035', months = 35, fine = 4500, color = 'laranja', description = 'A posse de uma quantidade de Methaqualona para distribuição' },
        [36] = { title = 'Posse de PCP de menor grau', class = 'Menor Grau', id = 'P.C. 7036', months = 7, fine = 500, color = 'verde', description = 'A posse de PCP em pequena quantidade, geralmente para uso pessoal' },
        [37] = { title = 'Fabricação de posse de PCP de grau maior', class = 'Grau Maior', id = 'P.C. 7037', months = 25, fine = 1500, color = 'vermelho', description = 'A posse de uma quantidade de PCP proveniente de fabricação' },
        [38] = { title = 'Posse de PCP com intenção de distribuir', class = 'Grau Maior', id = 'P.C. 7038', months = 35, fine = 4500, color = 'laranja', description = 'A posse de uma quantidade de PCP para distribuição' },
        [39] = { title = 'Posse de anabolic steroids de menor grau', class = 'Menor Grau', id = 'P.C. 7039', months = 7, fine = 500, color = 'verde', description = 'A posse de esteroides anabolizantes em pequena quantidade, geralmente para uso pessoal' },
        [40] = { title = 'Fabricação de posse de anabolic steroids de grau maior', class = 'Grau Maior', id = 'P.C. 7040', months = 25, fine = 1500, color = 'vermelho', description = 'A posse de uma quantidade de esteroides anabolizantes proveniente de fabricação' },
        [41] = { title = 'Posse de anabolic steroids com intenção de distribuir', class = 'Grau Maior', id = 'P.C. 7041', months = 35, fine = 4500, color = 'laranja', description = 'A posse de uma quantidade de esteroides anabolizantes para distribuição' },
        [42] = { title = 'Posse de qualquer substância não regulamentada', class = 'Grau Maior', id = 'P.C. 7042', months = 30, fine = 1000, color = 'laranja', description = 'A posse de qualquer substância não regulamentada que não se encaixa em outras categorias' }
    },
    [8] = {
        [1] = { title = 'Posse Criminal de Arma Classe A', class = 'Crime', id = 'P.C. 8001', months = 10, fine = 500, color = 'green', description = 'Posse de uma arma de fogo Classe A sem licença' },
        [2] = { title = 'Posse Criminal de Arma Classe B', class = 'Crime', id = 'P.C. 8002', months = 15, fine = 1000, color = 'green', description = 'Posse de uma arma de fogo Classe B sem licença' },
        [3] = { title = 'Posse Criminal de Arma Classe C', class = 'Crime', id = 'P.C. 8003', months = 30, fine = 3500, color = 'green', description = 'Posse de uma arma de fogo Classe C sem licença' },
        [4] = { title = 'Posse Criminal de Arma Classe D', class = 'Crime', id = 'P.C. 8004', months = 25, fine = 1500, color = 'green', description = 'Posse de uma arma de fogo Classe D sem licença' },
        [5] = { title = 'Venda Criminal de Arma Classe A', class = 'Crime', id = 'P.C. 8005', months = 15, fine = 1000, color = 'orange', description = 'Ato de vender uma arma de fogo Classe A sem licença' },
        [6] = { title = 'Venda Criminal de Arma Classe B', class = 'Crime', id = 'P.C. 8006', months = 20, fine = 2000, color = 'orange', description = 'Ato de vender uma arma de fogo Classe B sem licença' },
        [7] = { title = 'Venda Criminal de Arma Classe C', class = 'Crime', id = 'P.C. 8007', months = 35, fine = 7000, color = 'orange', description = 'Ato de vender uma arma de fogo Classe C sem licença' },
        [8] = { title = 'Venda Criminal de Arma Classe D', class = 'Crime', id = 'P.C. 8008', months = 30, fine = 3000, color = 'orange', description = 'Ato de vender uma arma de fogo Classe D sem licença' },
        [9] = { title = 'Uso Criminal de Arma', class = 'Contravenção', id = 'P.C. 8009', months = 10, fine = 450, color = 'orange', description = 'Uso de uma arma durante a prática de um crime' },
        [10] = { title = 'Posse de Modificações Ilegais de Arma', class = 'Contravenção', id = 'P.C. 8010', months = 10, fine = 300, color = 'green', description = 'Estar na posse de modificações de armas de fogo de forma ilegal' },
        [11] = { title = 'Tráfico de Armas', class = 'Crime', id = 'P.C. 8011', months = 0, fine = 0, color = 'red', description = 'Transporte de uma grande quantidade de armas de um ponto a outro' },
        [12] = { title = 'Brandir uma Arma', class = 'Contravenção', id = 'P.C. 8012', months = 15, fine = 500, color = 'orange', description = 'Ato de tornar uma arma de fogo visível propositadamente' },
        [13] = { title = 'Insurreição', class = 'Crime', id = 'P.C. 8013', months = 0, fine = 0, color = 'red', description = 'Tentativa de derrubar o governo com violência' },
        [14] = { title = 'Sobrevoo em Espaço Aéreo Restrito', class = 'Crime', id = 'P.C. 8014', months = 20, fine = 1500, color = 'green', description = 'Pilotar uma aeronave em espaço aéreo controlado pelo governo' },
        [15] = { title = 'Atravessar Fora da Faixa', class = 'Infração', id = 'P.C. 8015', months = 0, fine = 150, color = 'green', description = 'Atravessar uma via de maneira que seja perigosa para veículos motorizados' },
        [16] = { title = 'Uso Criminal de Explosivos', class = 'Crime', id = 'P.C. 8016', months = 30, fine = 2500, color = 'orange', description = 'Uso de explosivos para cometer um crime' },
    },
    [9] = {
        [1] = { title = 'Dirigindo Sob Efeito de Álcool', class = 'Contravenção', id = 'P.C. 9001', months = 5, fine = 300, color = 'green', description = 'Operar um veículo motorizado enquanto estiver sob efeito de álcool' },
        [2] = { title = 'Fuga', class = 'Contravenção', id = 'P.C. 9002', months = 5, fine = 400, color = 'green', description = 'Esconder-se ou fugir de uma detenção legal' },
        [3] = { title = 'Fuga Imprudente', class = 'Crime', id = 'P.C. 9003', months = 10, fine = 800, color = 'orange', description = 'Desconsiderar imprudentemente a segurança e esconder-se ou fugir de uma detenção legal' },
        [4] = { title = 'Não Dar Passagem para Veículo de Emergência', class = 'Infração', id = 'P.C. 9004', months = 0, fine = 600, color = 'green', description = 'Não dar passagem para veículos de emergência' },
        [5] = { title = 'Não Obedecer a Sinalização de Trânsito', class = 'Infração', id = 'P.C. 9005', months = 0, fine = 150, color = 'green', description = 'Não seguir os dispositivos de segurança da via' },
        [6] = { title = 'Veículo Não Funcional', class = 'Infração', id = 'P.C. 9006', months = 0, fine = 75, color = 'green', description = 'Ter um veículo que não é mais funcional na via' },
        [7] = { title = 'Condução Negligente', class = 'Infração', id = 'P.C. 9007', months = 0, fine = 300, color = 'green', description = 'Dirigir de forma a desconsiderar a segurança sem perceber' },
        [8] = { title = 'Condução Imprudente', class = 'Contravenção', id = 'P.C. 9008', months = 10, fine = 750, color = 'orange', description = 'Dirigir de forma a desconsiderar intencionalmente a segurança' },
        [9] = { title = 'Excesso de Velocidade de Terceiro Grau', class = 'Infração', id = 'P.C. 9009', months = 0, fine = 225, color = 'green', description = 'Excesso de velocidade 15 acima do limite' },
        [10] = { title = 'Excesso de Velocidade de Segundo Grau', class = 'Infração', id = 'P.C. 9010', months = 0, fine = 450, color = 'green', description = 'Excesso de velocidade 35 acima do limite' },
        [11] = { title = 'Excesso de Velocidade de Primeiro Grau', class = 'Infração', id = 'P.C. 9011', months = 0, fine = 750, color = 'green', description = 'Excesso de velocidade 50 acima do limite' },
        [12] = { title = 'Operação de Veículo sem Licença', class = 'Infração', id = 'P.C. 9012', months = 0, fine = 500, color = 'green', description = 'Operar um veículo motorizado sem a devida licença' },
        [13] = { title = 'Conversão Ilegal', class = 'Infração', id = 'P.C. 9013', months = 0, fine = 75, color = 'green', description = 'Realizar uma conversão onde é proibido' },
        [14] = { title = 'Ultrapassagem Ilegal', class = 'Infração', id = 'P.C. 9014', months = 0, fine = 300, color = 'green', description = 'Ultrapassar outros veículos motorizados de forma proibida' },
        [15] = { title = 'Não Manter a Faixa', class = 'Infração', id = 'P.C. 9015', months = 0, fine = 300, color = 'green', description = 'Não permanecer na faixa correta com um veículo motorizado' },
        [16] = { title = 'Conversão Ilegal', class = 'Infração', id = 'P.C. 9016', months = 0, fine = 150, color = 'green', description = 'Realizar uma conversão onde é proibido' },
        [17] = { title = 'Não Parar', class = 'Infração', id = 'P.C. 9017', months = 0, fine = 600, color = 'green', description = 'Não parar em uma parada legal ou sinal de trânsito' },
        [18] = { title = 'Estacionamento Não Autorizado', class = 'Infração', id = 'P.C. 9018', months = 0, fine = 300, color = 'green', description = 'Estacionar um veículo em um local que requer aprovação' },
        [19] = { title = 'Fuga Após Acidente', class = 'Contravenção', id = 'P.C. 9019', months = 10, fine = 500, color = 'green', description = 'Colidir com outra pessoa ou veículo e fugir do local' },
        [20] = { title = 'Dirigir Sem Faróis ou Sinais', class = 'Infração', id = 'P.C. 9020', months = 0, fine = 300, color = 'green', description = 'Operar um veículo sem luzes funcionais' },
        [21] = { title = 'Corrida de Rua', class = 'Crime', id = 'P.C. 9021', months = 15, fine = 1500, color = 'green', description = 'Operar veículos motorizados em uma competição' },
        [22] = { title = 'Pilotagem Sem Licença Apropriada', class = 'Crime', id = 'P.C. 9022', months = 20, fine = 1500, color = 'orange', description = 'Não possuir a licença válida ao operar uma aeronave' },
        [23] = { title = 'Uso Ilegal de Veículo Motorizado', class = 'Contravenção', id = 'P.C. 9023', months = 10, fine = 750, color = 'green', description = 'Uso de um veículo motorizado sem uma razão legal' },
    },
    [10] = {
        [1] = { title = 'Caça em Áreas Restritas', class = 'Infração', id = 'P.C. 10001', months = 0, fine = 450, color = 'verde', description = 'Captura de animais em áreas onde é proibido fazê-lo' },
        [2] = { title = 'Caça sem Licença', class = 'Infração', id = 'P.C. 10002', months = 0, fine = 450, color = 'verde', description = 'Captura de animais sem a devida licença' },
        [3] = { title = 'Crueldade com Animais', class = 'Contravenção', id = 'P.C. 10003', months = 10, fine = 450, color = 'verde', description = 'O ato de abusar de um animal, conscientemente ou não' },
        [4] = { title = 'Caça com uma Arma Não Permitida', class = 'Contravenção', id = 'P.C. 10004', months = 10, fine = 750, color = 'verde', description = 'Usar uma arma que não é legalmente especificada ou fabricada para a captura de animais selvagens' },
        [5] = { title = 'Caça fora do Horário de Caça', class = 'Infração', id = 'P.C. 10005', months = 0, fine = 750, color = 'verde', description = 'Captura de animais fora do horário especificado para tal' },
        [6] = { title = 'Supercaça', class = 'Contravenção', id = 'P.C. 10006', months = 10, fine = 1000, color = 'verde', description = 'Captura de mais do que a quantidade legalmente especificada de animais' },
        [7] = { title = 'Caça Ilegal', class = 'Crime', id = 'P.C. 10007', months = 20, fine = 1250, color = 'vermelho', description = 'Captura de um animal que é listado como legalmente não capturável' },
    }    
}

Config.AllowedJobs = {}
for index, value in pairs(Config.PoliceJobs) do
    Config.AllowedJobs[index] = value
end
for index, value in pairs(Config.AmbulanceJobs) do
    Config.AllowedJobs[index] = value
end
for index, value in pairs(Config.DojJobs) do
    Config.AllowedJobs[index] = value
end

Config.ColorNames = {
    [0] = "Metallic Black",
    [1] = "Metallic Graphite Black",
    [2] = "Metallic Black Steel",
    [3] = "Metallic Dark Silver",
    [4] = "Metallic Silver",
    [5] = "Metallic Blue Silver",
    [6] = "Metallic Steel Gray",
    [7] = "Metallic Shadow Silver",
    [8] = "Metallic Stone Silver",
    [9] = "Metallic Midnight Silver",
    [10] = "Metallic Gun Metal",
    [11] = "Metallic Anthracite Grey",
    [12] = "Matte Black",
    [13] = "Matte Gray",
    [14] = "Matte Light Grey",
    [15] = "Util Black",
    [16] = "Util Black Poly",
    [17] = "Util Dark silver",
    [18] = "Util Silver",
    [19] = "Util Gun Metal",
    [20] = "Util Shadow Silver",
    [21] = "Worn Black",
    [22] = "Worn Graphite",
    [23] = "Worn Silver Grey",
    [24] = "Worn Silver",
    [25] = "Worn Blue Silver",
    [26] = "Worn Shadow Silver",
    [27] = "Metallic Red",
    [28] = "Metallic Torino Red",
    [29] = "Metallic Formula Red",
    [30] = "Metallic Blaze Red",
    [31] = "Metallic Graceful Red",
    [32] = "Metallic Garnet Red",
    [33] = "Metallic Desert Red",
    [34] = "Metallic Cabernet Red",
    [35] = "Metallic Candy Red",
    [36] = "Metallic Sunrise Orange",
    [37] = "Metallic Classic Gold",
    [38] = "Metallic Orange",
    [39] = "Matte Red",
    [40] = "Matte Dark Red",
    [41] = "Matte Orange",
    [42] = "Matte Yellow",
    [43] = "Util Red",
    [44] = "Util Bright Red",
    [45] = "Util Garnet Red",
    [46] = "Worn Red",
    [47] = "Worn Golden Red",
    [48] = "Worn Dark Red",
    [49] = "Metallic Dark Green",
    [50] = "Metallic Racing Green",
    [51] = "Metallic Sea Green",
    [52] = "Metallic Olive Green",
    [53] = "Metallic Green",
    [54] = "Metallic Gasoline Blue Green",
    [55] = "Matte Lime Green",
    [56] = "Util Dark Green",
    [57] = "Util Green",
    [58] = "Worn Dark Green",
    [59] = "Worn Green",
    [60] = "Worn Sea Wash",
    [61] = "Metallic Midnight Blue",
    [62] = "Metallic Dark Blue",
    [63] = "Metallic Saxony Blue",
    [64] = "Metallic Blue",
    [65] = "Metallic Mariner Blue",
    [66] = "Metallic Harbor Blue",
    [67] = "Metallic Diamond Blue",
    [68] = "Metallic Surf Blue",
    [69] = "Metallic Nautical Blue",
    [70] = "Metallic Bright Blue",
    [71] = "Metallic Purple Blue",
    [72] = "Metallic Spinnaker Blue",
    [73] = "Metallic Ultra Blue",
    [74] = "Metallic Bright Blue",
    [75] = "Util Dark Blue",
    [76] = "Util Midnight Blue",
    [77] = "Util Blue",
    [78] = "Util Sea Foam Blue",
    [79] = "Uil Lightning blue",
    [80] = "Util Maui Blue Poly",
    [81] = "Util Bright Blue",
    [82] = "Matte Dark Blue",
    [83] = "Matte Blue",
    [84] = "Matte Midnight Blue",
    [85] = "Worn Dark blue",
    [86] = "Worn Blue",
    [87] = "Worn Light blue",
    [88] = "Metallic Taxi Yellow",
    [89] = "Metallic Race Yellow",
    [90] = "Metallic Bronze",
    [91] = "Metallic Yellow Bird",
    [92] = "Metallic Lime",
    [93] = "Metallic Champagne",
    [94] = "Metallic Pueblo Beige",
    [95] = "Metallic Dark Ivory",
    [96] = "Metallic Choco Brown",
    [97] = "Metallic Golden Brown",
    [98] = "Metallic Light Brown",
    [99] = "Metallic Straw Beige",
    [100] = "Metallic Moss Brown",
    [101] = "Metallic Biston Brown",
    [102] = "Metallic Beechwood",
    [103] = "Metallic Dark Beechwood",
    [104] = "Metallic Choco Orange",
    [105] = "Metallic Beach Sand",
    [106] = "Metallic Sun Bleeched Sand",
    [107] = "Metallic Cream",
    [108] = "Util Brown",
    [109] = "Util Medium Brown",
    [110] = "Util Light Brown",
    [111] = "Metallic White",
    [112] = "Metallic Frost White",
    [113] = "Worn Honey Beige",
    [114] = "Worn Brown",
    [115] = "Worn Dark Brown",
    [116] = "Worn straw beige",
    [117] = "Brushed Steel",
    [118] = "Brushed Black steel",
    [119] = "Brushed Aluminium",
    [120] = "Chrome",
    [121] = "Worn Off White",
    [122] = "Util Off White",
    [123] = "Worn Orange",
    [124] = "Worn Light Orange",
    [125] = "Metallic Securicor Green",
    [126] = "Worn Taxi Yellow",
    [127] = "police car blue",
    [128] = "Matte Green",
    [129] = "Matte Brown",
    [130] = "Worn Orange",
    [131] = "Matte White",
    [132] = "Worn White",
    [133] = "Worn Olive Army Green",
    [134] = "Pure White",
    [135] = "Hot Pink",
    [136] = "Salmon pink",
    [137] = "Metallic Vermillion Pink",
    [138] = "Orange",
    [139] = "Green",
    [140] = "Blue",
    [141] = "Mettalic Black Blue",
    [142] = "Metallic Black Purple",
    [143] = "Metallic Black Red",
    [144] = "Hunter Green",
    [145] = "Metallic Purple",
    [146] = "Metaillic V Dark Blue",
    [147] = "MODSHOP BLACK1",
    [148] = "Matte Purple",
    [149] = "Matte Dark Purple",
    [150] = "Metallic Lava Red",
    [151] = "Matte Forest Green",
    [152] = "Matte Olive Drab",
    [153] = "Matte Desert Brown",
    [154] = "Matte Desert Tan",
    [155] = "Matte Foilage Green",
    [156] = "DEFAULT ALLOY COLOR",
    [157] = "Epsilon Blue",
    [158] = "Unknown",
}

Config.ColorInformation = {
    [0] = "black",
    [1] = "black",
    [2] = "black",
    [3] = "darksilver",
    [4] = "silver",
    [5] = "bluesilver",
    [6] = "silver",
    [7] = "darksilver",
    [8] = "silver",
    [9] = "bluesilver",
    [10] = "darksilver",
    [11] = "darksilver",
    [12] = "matteblack",
    [13] = "gray",
    [14] = "lightgray",
    [15] = "black",
    [16] = "black",
    [17] = "darksilver",
    [18] = "silver",
    [19] = "utilgunmetal",
    [20] = "silver",
    [21] = "black",
    [22] = "black",
    [23] = "darksilver",
    [24] = "silver",
    [25] = "bluesilver",
    [26] = "darksilver",
    [27] = "red",
    [28] = "torinored",
    [29] = "formulared",
    [30] = "blazered",
    [31] = "gracefulred",
    [32] = "garnetred",
    [33] = "desertred",
    [34] = "cabernetred",
    [35] = "candyred",
    [36] = "orange",
    [37] = "gold",
    [38] = "orange",
    [39] = "red",
    [40] = "mattedarkred",
    [41] = "orange",
    [42] = "matteyellow",
    [43] = "red",
    [44] = "brightred",
    [45] = "garnetred",
    [46] = "red",
    [47] = "red",
    [48] = "darkred",
    [49] = "darkgreen",
    [50] = "racingreen",
    [51] = "seagreen",
    [52] = "olivegreen",
    [53] = "green",
    [54] = "gasolinebluegreen",
    [55] = "mattelimegreen",
    [56] = "darkgreen",
    [57] = "green",
    [58] = "darkgreen",
    [59] = "green",
    [60] = "seawash",
    [61] = "midnightblue",
    [62] = "darkblue",
    [63] = "saxonyblue",
    [64] = "blue",
    [65] = "blue",
    [66] = "blue",
    [67] = "diamondblue",
    [68] = "blue",
    [69] = "blue",
    [70] = "brightblue",
    [71] = "purpleblue",
    [72] = "blue",
    [73] = "ultrablue",
    [74] = "brightblue",
    [75] = "darkblue",
    [76] = "midnightblue",
    [77] = "blue",
    [78] = "blue",
    [79] = "lightningblue",
    [80] = "blue",
    [81] = "brightblue",
    [82] = "mattedarkblue",
    [83] = "matteblue",
    [84] = "matteblue",
    [85] = "darkblue",
    [86] = "blue",
    [87] = "lightningblue",
    [88] = "yellow",
    [89] = "yellow",
    [90] = "bronze",
    [91] = "yellow",
    [92] = "lime",
    [93] = "champagne",
    [94] = "beige",
    [95] = "darkivory",
    [96] = "brown",
    [97] = "brown",
    [98] = "lightbrown",
    [99] = "beige",
    [100] = "brown",
    [101] = "brown",
    [102] = "beechwood",
    [103] = "beechwood",
    [104] = "chocoorange",
    [105] = "yellow",
    [106] = "yellow",
    [107] = "cream",
    [108] = "brown",
    [109] = "brown",
    [110] = "brown",
    [111] = "white",
    [112] = "white",
    [113] = "beige",
    [114] = "brown",
    [115] = "brown",
    [116] = "beige",
    [117] = "steel",
    [118] = "blacksteel",
    [119] = "aluminium",
    [120] = "chrome",
    [121] = "wornwhite",
    [122] = "offwhite",
    [123] = "orange",
    [124] = "lightorange",
    [125] = "green",
    [126] = "yellow",
    [127] = "blue",
    [128] = "green",
    [129] = "brown",
    [130] = "orange",
    [131] = "white",
    [132] = "white",
    [133] = "darkgreen",
    [134] = "white",
    [135] = "pink",
    [136] = "pink",
    [137] = "pink",
    [138] = "orange",
    [139] = "green",
    [140] = "blue",
    [141] = "blackblue",
    [142] = "blackpurple",
    [143] = "blackred",
    [144] = "darkgreen",
    [145] = "purple",
    [146] = "darkblue",
    [147] = "black",
    [148] = "purple",
    [149] = "darkpurple",
    [150] = "red",
    [151] = "darkgreen",
    [152] = "olivedrab",
    [153] = "brown",
    [154] = "tan",
    [155] = "green",
    [156] = "silver",
    [157] = "blue",
    [158] = "black",
}

Config.ClassList = {
    [0] = "Compact",
    [1] = "Sedan",
    [2] = "SUV",
    [3] = "Coupe",
    [4] = "Muscle",
    [5] = "Sport Classic",
    [6] = "Sport",
    [7] = "Super",
    [8] = "Motorbike",
    [9] = "Off-Road",
    [10] = "Industrial",
    [11] = "Utility",
    [12] = "Van",
    [13] = "Bike",
    [14] = "Boat",
    [15] = "Helicopter",
    [16] = "Plane",
    [17] = "Service",
    [18] = "Emergency",
    [19] = "Military",
    [20] = "Commercial",
    [21] = "Train"
}

function GetJobType(job)
    if Config.PoliceJobs[job] then
        return 'police'
    elseif Config.AmbulanceJobs[job] then
        return 'ambulance'
    elseif Config.DojJobs[job] then
        return 'doj'
    else
        return nil
    end
end
