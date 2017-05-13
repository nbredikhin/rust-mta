local function handleResponse(response, errno)
    if Config.showErrors and errno ~= 0 then
        outputDebugString("[DISCORD] Failed to send message. Error code: " .. tostring(errno))
    end
end

local function getServerId()
    -- TODO
    return "BETA"
end

function outputDiscordMessage(message)
    -- Имя пользователя-отправителя, которое отобразится в Discord
    local username = string.format(Config.usernameFormat, tostring(getServerId()))
    -- JSON-объект сообщения
    local messageJSON = '{"text": "'
        .. tostring(message)
        ..'", "username": "'
        .. tostring(username) ..'"}'
    -- Добавление "/slack", чтобы работал данный формат сообщения
    local url = Config.webhookUrl .. "/slack"
    fetchRemote(url, handleResponse, messageJSON)
end
