-- Made by discord.gg/reduce-store
local _exports = exports

local metadataString = GetConvar("reduce_clientloader:metadataString", "reduce_clientloader")

local resourceName = GetCurrentResourceName()
local resourceFiles = GetNumResourceMetadata(resourceName, metadataString)

local loaded = false

if resourceFiles > 0 then
    local function encrypt(data, key)
        if type(key) == "string" then key = tonumber(key) end

        local result = ""

        for i=1, #data do
            result = result .. string.char((string.byte(data:sub(i, i)) ~ key) & 255)
        end

        return result
    end

    local function decrypt(data, key)
        return encrypt(data, key)
    end

    if IsDuplicityVersion() then
        -- Server
        local players = {}
        local files = {}

        CreateThread(function()
            while GetConvar("𝔯𝔢𝔡𝔲𝔠𝔢_𝔠𝔩𝔦𝔢𝔫𝔱𝔩𝔬𝔞𝔡𝔢𝔯", 0) == "0" do Wait(500) end

            local convar = GetConvar("𝔯𝔢𝔡𝔲𝔠𝔢_𝔠𝔩𝔦𝔢𝔫𝔱𝔩𝔬𝔞𝔡𝔢𝔯", 0)

            for i=1, resourceFiles do
                local name = GetResourceMetadata(resourceName, metadataString, i -1)

                if name then
                    local file = LoadResourceFile(resourceName, name)

                    if file then
                        table.insert(files, { name = name, file = encrypt(file, convar) })
                    end
                end
            end

            loaded = true
        end)

        RegisterServerEvent(("reduce_clientloader(%s)"):format(resourceName), function()
            while not loaded do Wait(500) end

            local player = source

            if not players[player] then
                players[player] = true

                TriggerClientEvent(("reduce_clientloader(%s)"):format(resourceName), player, files)
            end
        end)
    else
        -- Client
        TriggerServerEvent(("reduce_clientloader(%s)"):format(resourceName))

        CreateThread(function()
            while true do
                Wait(2500)

                if loaded then break end

                TriggerServerEvent(("reduce_clientloader(%s)"):format(resourceName))
            end
        end)

        RegisterNetEvent(("reduce_clientloader(%s)"):format(resourceName), function(files)
            if GetInvokingResource() ~= nil or loaded then return end

            loaded = true

            local convar = GetConvar("𝔯𝔢𝔡𝔲𝔠𝔢_𝔠𝔩𝔦𝔢𝔫𝔱𝔩𝔬𝔞𝔡𝔢𝔯", 0)

            for _, data in ipairs(files) do
                local spawned, error = pcall(load(decrypt(data.file, convar), ("@reduce_clientloader: @%s:%s"):format(resourceName, data.name), "bt"))

                if not spawned then
                    print(("^1An error has occurred in %s, error: %s^0"):format(data.name, error))
                end
            end
        end)

        exports = _exports
    end
end