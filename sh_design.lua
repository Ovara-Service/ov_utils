--[[
# Version 1.1.0
]]--

DefaultDesignConfiguration = {
    ["themeDesign"] = {
        client = true,
        description = "Design theme.",
        value = {
            ["color-primary"] = "rgb(178, 55, 55)",
            ["color-secondary"] = "#ffffff",
            ["color-accent"] = "rgba(255, 255, 255, 0.2)",
            ["primary-background"] = "rgba(24, 4, 0, 0.8)",
            ["secondary-background"] = "rgba(215, 127, 69, 0)",
            ["background-card"] = "#181210",
            ["primary-hover-color"] = "rgb(178, 73, 55)",
            ["primary-hover-color-2"] = "rgba(223, 53, 1, 0)",
            ["primary-hover-color-3"] = "#181310",
            ["primary-hover-border-color"] = "rgba(149, 53, 36, 0.85)",
            ["secondary-hover-color"] = "#FFFFFF",
            ["box-premium-color"] = "#ffb000"
        }
    },
    ["serverName"] = {
        client = true,
        description = "Server name.",
        value = "Ovara.gg"
    },
    ["serverLogo"] = {
        client = true,
        description = "Server logo url.",
        value = "https://www.floba-media.de/wp-content/uploads/2023/08/cropped-FloBa-Media-01.png"
    }
}

DESIGN_CONFIG_NAME = "ov_design"

Citizen.CreateThread(function()
    while GetResourceState("ov_configs") ~= "started" do
        Citizen.Wait(1000);
    end

    if not IsDuplicityVersion() then -- Client
        OV_DESIGN_DATA = exports["ov_configs"]:getConfig(DESIGN_CONFIG_NAME, DefaultDesignConfiguration)
        
        -- Da sh_config.lua auch den reloadConfig event hat, müssen wir hier aufpassen.
        -- Aber wenn diese Datei separat genutzt werden soll, braucht sie ihren eigenen Handler.
    else -- Server
        OV_DESIGN = exports["ov_configs"]:getConfig(DESIGN_CONFIG_NAME, DefaultDesignConfiguration)

        -- Initialisierung falls nicht vorhanden
        if OV_DESIGN == nil then
            exports["ov_configs"]:saveConfig(DESIGN_CONFIG_NAME, DefaultDesignConfiguration, 1)
            print("Successfully set default global design config!")
        end

        OV_DESIGN_DATA = OV_DESIGN.getData()

        if OV_DESIGN.getVersion() < 2 then
            -- Add Servername and logo

            OV_DESIGN_DATA["serverName"] = {
                client = true,
                description = "Server name.",
                value = "Ovara.gg"
            }
            OV_DESIGN_DATA["serverLogo"] = {
                client = true,
                description = "Server logo url.",
                value = "https://www.floba-media.de/wp-content/uploads/2023/08/cropped-FloBa-Media-01.png"
            }

            exports["ov_configs"]:saveConfig(DESIGN_CONFIG_NAME, OV_DESIGN_DATA, 2)
        end
    end
end)

-- Event Handler für Reload
RegisterNetEvent("ov_configs:reloadConfig")
AddEventHandler("ov_configs:reloadConfig", function(configName)
    if DESIGN_CONFIG_NAME == configName then
        OV_DESIGN_DATA = exports["ov_configs"]:getConfig(DESIGN_CONFIG_NAME, DefaultDesignConfiguration)
        if not IsDuplicityVersion() then
            print("Successfully reloaded design configuration.")
            if setDesignConfig then
                setDesignConfig(getDesignConfig())
            end
        else
            print("Successfully reloaded design configuration.")
        end
    end
end)
