CreateThread(function()
    if OV_GIT_NAME == nil then
        print("^1Could not find OV_GIT_NAME to check version.")
        return
    end

    local url = "https://raw.githubusercontent.com/Ovara-Service/checkVersions/master/" .. OV_GIT_NAME .. ".txt"

    local function getVersion()
        local versionName = GetResourceMetadata(GetCurrentResourceName(), "version", 0)

        return versionName
    end

    local local_version = getVersion()

    if local_version then
        PerformHttpRequest(url, function(statusCode, responseText, headers)
            if statusCode == 200 then
                responseText = responseText:match("^%s*(.-)%s*$")

                if responseText == local_version then
                    print(string.format("^4Version %s\n^2You are running on the latest version", local_version))
                else
                    print(string.format("^4Version %s\n^1You are currently running an outdated version, please update to version %s", local_version, responseText))
                end
            else
                print("^1Failed to retrieve version from URL.")
            end
        end, 'GET')
    else
        print("1Could not find version in fxmanifest.lua file. Is everything up to date?")
    end
end)