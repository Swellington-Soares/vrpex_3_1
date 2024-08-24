local wb = lib.load('@vrp.webhook')

---@class _DiscordEmbed: OxClass
local _DiscordEmbed = lib.class('DiscordEmbed')

function _DiscordEmbed:constructor()
    self.private._ = true
    self.private.title = nil
    self.private.type = nil
    self.private.description = nil
    self.private.url = nil
    self.private.timestamp = nil
    self.private.color = nil
    self.private.footer = nil
    self.private.image = nil
    self.private.thumbnail = nil
    self.private.video = nil
    self.private.provider = nil
    self.private.author = nil
    self.private.fields = nil
end

function _DiscordEmbed:setThumbnail(url, width, height)
    if not url then error('Url Field is required.') end
    self.private.timestamp = {
        url = url,
        width = width,
        height = height
    }
    return self
end

function _DiscordEmbed:setVideo(url, width, height)
    if not url then error('Url Field is required.') end
    self.private.video = {
        url = url,
        width = width,
        height = height
    }
    return self
end

function _DiscordEmbed:setImage(url, width, height)
    if not url then error('Url Field is required.') end
    self.private.image = {
        url = url,
        width = width,
        height = height
    }
    return self
end

function _DiscordEmbed:setProvider(url, width, height)
    if not url then error('Url Field is required.') end
    self.private.provider = {
        url = url,
        width = width,
        height = height
    }
    return self
end

function _DiscordEmbed:setAuthor(name, url, icon_url)
    if not name then error('Name is required') end
    self.private.author = {
        name = name,
        url = url,
        icon_url = icon_url
    }
    return self
end

function _DiscordEmbed:setFooter(text, icon_url)
    if not text then error('Text is required') end
    if #text > 2048 then error('Text total chars need be 2048.') end
    self.private.footer = {
        text = text,
        icon_url = icon_url
    }
    return self
end

function _DiscordEmbed:addField(name, value, inline)
    inline = not not inline -- force to type true or false boolean
    if not name then error('Name is required') end
    if not value then error('Value is required') end
    if not self.private.fields then self.private.fields = {} end
    if #self.private.fields + 1 == 25 then error('Field max limit. Only 25 entries.') end   
    self.private.fields[#self.private.fields + 1] = {
        name = name,
        value = value,
        inline = inline
    }
    return self
end

function _DiscordEmbed:clearFields()
    self.private.fields = nil
    return self
end

function _DiscordEmbed:setFields(fields)
    if #fields > 25 then error('Field max limit. Only 25 entries.') end
    self.private.fields = fields
    --- validate
    for i = 1, #self.private.fields or {} do
        if #self.private.fields[i]?.name > 256 then
            error('Field name need be max 256 chars.')
        end

        if #self.private.fields[i]?.value > 1024 then
            error('Field value need be max 1024 chars.')
        end
    end
    return self
end

function _DiscordEmbed:setTitle(value)
    if #value > 256 then
        error('Title total character need be 256 chars.')
    end
    self.private.title = value
    return self
end

function _DiscordEmbed:setDescription(value)
    if #value > 4096 then
        error('Description total character need be 256 chars.')
    end
    self.private.description = value
    return self
end

function _DiscordEmbed:setUrl(value)
    self.private.url = value
    return self
end

function _DiscordEmbed:setTimestamp()
    self.private.timestamp = os.date('%Y-%m-%dT%X')
    return self
end

function _DiscordEmbed:setColor(value)
    self.private.color = value
end

function _DiscordEmbed.Builder()
    return _DiscordEmbed:new()
end

function _DiscordEmbed:build()
    return {
        title = self.private.title,
        type = self.private.type,
        description = self.private.description,
        url = self.private.url,
        timestamp = self.private.timestamp,
        color = self.private.color,
        footer = self.private.footer,
        image = self.private.image,
        thumbnail = self.private.thumbnail,
        video = self.private.video,
        provider = self.private.provider,
        author = self.private.author,
        fields = self.private.fields
    }
end

return _DiscordEmbed.Builder
