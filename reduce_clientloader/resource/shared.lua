-- Made with ❤️ by kerimhmad

local resourceName = GetCurrentResourceName()

if GetResourceMetadata(resourceName, "reduce_clientloader") == "yes" then return end

local filesCount = GetNumResourceMetadata(resourceName, "reduce_clientloader")

if filesCount > 0 then
    local loaded = false

    local eventName = string.format("reduce_clientloader(%s)", resourceName)

    local function encrypt(value, key)
        local result

        for i=1, #value do
            result = (result or "") .. string.char((string.byte(string.sub(value, i, i)) ~ key) & 255)
        end

        return result
    end

    local decrypt = encrypt

    RegisterNetEvent(eventName)

    if IsDuplicityVersion() then
        local players = {}
        local files = {}

        GlobalState[eventName] = math.random(0xdeadbea7)

        Citizen.CreateThreadNow(function()
            local cryptKey = GlobalState[eventName]

            for i=1, filesCount do
                local fileName = GetResourceMetadata(resourceName, "reduce_clientloader", i -1)

                if fileName then
                    local fileCode = LoadResourceFile(resourceName, fileName)

                    if fileCode then
                        table.insert(files, {
                            fileName = fileName,
                            fileCode = encrypt(fileCode, cryptKey)
                        })
                    end
                end
            end

            loaded = true
        end)

        AddEventHandler(eventName, function()
            while not loaded do
                Citizen.Wait(1000)
            end

            local player = source

            if not players[player] then
                players[player] = true

                TriggerClientEvent(eventName, player, files)
            end
        end)
    else
        local originalExports = exports

        TriggerServerEvent(eventName)

        SetTimeout(2 --[[ 2 minutes ]]* 60000, function()
            if not loaded then
                local crashNative = QuitGame or ForceSocialClubUpdate

                if crashNative then
                    print(string.format([[
                        ^0------------------ Reduce Clientloader ------------------
                        ^1The script '%s' could not be loaded correctly! Crashing...
                        ^0------------------ Reduce Clientloader ------------------
                    ]], resourceName))

                    while true do
                        crashNative()
                    end
                end
            end
        end)

        AddEventHandler(eventName, function(files)
            if GetInvokingResource() ~= nil then
                return
            end

            if not loaded then
                loaded = true

                local cryptKey = GlobalState[eventName]

                for _, data in ipairs(files) do
                    local status, error = pcall(
                        load(decrypt(data.fileCode, cryptKey), string.format("@@reduce_clientloader: %s", data.fileName), "bt")
                    )

                    if not status and error then
                        print(string.format("^1An error occurred loading '%s', contact the server owner! Error: %s", data.fileName, error))
                    end
                end
            end
        end)

        _G.exports = originalExports
    end
end