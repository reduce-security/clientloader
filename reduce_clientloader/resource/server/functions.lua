-- Made with ❤️ by kerimhmad

Kerimhmad = {}

Kerimhmad.Prefix = "reduce-clientloader"
Kerimhmad.Version = "1.1.0"
Kerimhmad.ResourceName = GetCurrentResourceName()

function Kerimhmad:LogError(message)
    print(string.format("^0(^1%s^0): %s^0", Kerimhmad.Prefix, message))
end

function Kerimhmad:LogSuccess(message)
    print(string.format("^0(^2%s^0): %s^0", Kerimhmad.Prefix, message))
end

function Kerimhmad:LogInfo(message)
    print(string.format("^0(^5%s^0): %s^0", Kerimhmad.Prefix, message))
end

function Kerimhmad:CheckVersion()
    local checked = false

    PerformHttpRequest("https://raw.githubusercontent.com/reduce-security/reduce-security/main/clientloader.json", function(status, response)
        if status == 200 then
            if not checked then
                checked = true
            end

            local data = json.decode(response)

            Kerimhmad:LogSuccess(data.messages.start)

            if Kerimhmad.Version ~= data.version then
                Kerimhmad:LogInfo(string.gsub(data.messages.update, "{version.new}", data.version))
            end
        else
            Kerimhmad:LogError(string.format("Connection to Github failed, invalid status: ^1%s^0", status))
        end
    end, "GET")

    SetTimeout(10 * 1000, function()
        if not checked then
            Kerimhmad:LogError("Connection to Github failed, version could not be checked!")
        end
    end)
end