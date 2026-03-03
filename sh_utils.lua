--[[
# Utils Version 1.2.2

# Add Sub module to your project
git submodule add https://github.com/Ovara-Service/ov_utils.git ov_shared

]] --

-- [Shared] Reads a value from the global OV_CONFIG_DATA (context-dependent fallback).
function getConfig(...)
	return getConfigValue(OV_CONFIG_DATA, ...)
end

-- [Shared] Reads a value from the global OV_DESIGN_DATA.
function getDesignConfig(...)
	return getConfigValue(OV_DESIGN_DATA, "themeDesign", ...)
end

-- [Shared] Retrieves a nested config value using a path (key chain).
function getConfigValue(configObject, ...)
	local path = {...}
	local value = configObject

	if(value == nil) then
		print("Could not load config value from nil object")
		return nil, "Invalid config object"
	end

	for _, key in ipairs(path) do
		if value[key] then
			if value[key].value ~= nil then
				value = value[key].value
			else
				print("Could not find value for key (" .. dump(key) .. ") on path (" .. dump(path) .. ")!")
				return nil, "Value for key not found: " .. dump(key)
			end
		else
			print("Could not find key (" .. dump(key) .. ") on path (" .. dump(path) .. ")!")
			return nil, "Key not found: " .. dump(key)
		end
	end

	return value
end


_LOCALE = _LOCALE or {}

-- [Shared] Replaces default placeholders like {serverName}, {discordUrl}, etc. in a message.
function replaceDefaultKeys(message)
	if message ~= nil then
		message = message:gsub("{serverName}", tostring(GetConvar("serverName", "ServerName")), 1)
		message = message:gsub("{serverLogo}", tostring(GetConvar("serverLogo", "https://www.floba-media.de/wp-content/uploads/2025/02/ovara_logo.png")), 1)
		message = message:gsub("{discordUrl}", tostring(GetConvar("discordUrl", "discordUrl")), 1)
		message = message:gsub("{website}", tostring(GetConvar("website", "website")), 1)
	end

	return message
end

-- [Shared] Determines the active language (locale) from Config/OV_CONFIG_DATA, fallback "de".
function getLocale()
	local locale = Config.locale
	if OV_CONFIG_DATA ~= nil then
		locale = getConfig("locale")
	end

	if locale == nil then
		locale = "de"
		print("Could not find locale, so fallback to default de locale!")
	end

	return locale
end

-- [Shared] Gets a localized message by key and replaces %s placeholders sequentially.
function getMsg(key, ...)
	local locale = getLocale()

	if (_LOCALE[locale] == nil) then
		return 'Language ' .. tostring(locale) .. ' not found!'
	end
	if (_LOCALE[locale][key] == nil) then
		return 'Message ' .. tostring(key) .. ' not found!'
	end

	local message = _LOCALE[locale][key]
	local replacements = {...}

	for i, replacement in ipairs(replacements) do
		if type(replacement) == "string" or type(replacement) == "number" then
			message = message:gsub("%%s", replacement, 1)
		else
			message = message:gsub("%%s", tostring(replacement), 1)
			print("Error: replacement for key " .. tostring(key) .. " is not a string (" .. type(replacement) .. "). Value: ", tostring(replacement))
		end
	end

	return replaceDefaultKeys(message)
end

-- [Shared] Gets a localized message and replaces named placeholders provided as key/value pairs.
function getMsgR(key, replacements)
	local locale = getLocale()

	if (_LOCALE[locale] == nil) then
		return 'Language ' .. tostring(locale) .. ' not found!'
	end
	if (_LOCALE[locale][key] == nil) then
		return 'Message ' .. tostring(key) .. ' not found!'
	end

	local message = _LOCALE[locale][key]

	local replacementKey = nil

	for _, replacement in ipairs(replacements) do
		if replacementKey == nil then
			replacementKey = tostring(replacement)
		else
			if type(replacement) == "string" or type(replacement) == "number" then
				message = message:gsub(replacementKey, replacement, 1)
			else
				message = message:gsub(replacementKey, tostring(replacement), 1)
				print("Error: replacement for key " .. tostring(key) .. " is not a string (" .. type(replacement) .. "). Value: ", tostring(replacement))
			end

			replacementKey = nil
		end
	end

	return replaceDefaultKeys(message)
end

-- [Shared] Checks whether debug mode is active (via Config/Convar).
function isDebug()
	if OV_CONFIG_DATA ~= nil then
		return getConfig("debug")
	end

	return GetConvar("debug_" .. tostring(GetCurrentResourceName()), "false") == "true" and true or false
end

-- [Shared] Prints debug text only when debug is enabled.
function debugPrint(msg)
	if isDebug() then
		print('Debug: ' .. tostring(msg))
	end
end

-- [Server] Sends a notification to a specific source (player) via Config.notify.
function notify(src, type, message)
	Config.notify(src, type, getMsg('notify_title'), tostring(message))
end

-- [Server] Notification with title from locale (titleKey + "_title").
function notifyT(src, type, titleKey, message)
	Config.notify(src, type, getMsg(titleKey.. "_title"), tostring(message))
end

-- [Server] Notification: body text from a locale key.
function notifyKey(src, type, key, ...)
	Config.notify(src, type, getMsg('notify_title'), getMsg(key, ...))
end

-- [Server] Notification: title and body from locale keys.
function notifyKeyT(src, type, titleKey, key, ...)
	Config.notify(src, type, getMsg(titleKey.. "_title"), getMsg(key, ...))
end

-- [Server] Notification with a fixed title and body from a locale key.
function notifyKeyTitle(src, type, title, key, ...)
	Config.notify(src, type, title, getMsg(key, ...))
end

-- [Client] Local client notification (no src required).
function notifyC(type, message)
	Config.notify(nil, type, getMsg('notify_title'), tostring(message))
end

-- [Client] Local client notification with body from a locale key.
function notifyCKey(type, key, ...)
	Config.notify(nil, type, getMsg('notify_title'), getMsg(key, ...))
end

-- [Client] Local client notification with title and body from locale keys.
function notifyCKeyT(type, titleKey, key, ...)
	Config.notify(nil, type, getMsg(titleKey .. "_title"), getMsg(key, ...))
end

-- [Server] Shows a help/tooltip text to a player (via Config.HelpNotify).
function helpNotify(src, message)
	if Config.HelpNotify then
		Config.HelpNotify(src, message)
	else
		print("Error: Config.HelpNotify is not defined")
	end
end

-- [Client] Shows a local help/tooltip text on the client.
function helpNotifyC(message)
	if Config.HelpNotify then
		Config.HelpNotify(nil, message)
	else
		print("Error: Config.HelpNotify is not defined")
	end
end

-- [Server] Starts a progress bar for a player (triggered server-side).
function progressBar(src, time)
	if Config.ShowProgressBar then
		Config.ShowProgressBar(src, time)
	else
		print("Error: Config.ShowProgressBar is not defined")
	end
end

-- [Client] Starts a local progress bar.
function progressBarC(time)
	if Config.ShowProgressBar then
		Config.ShowProgressBar(nil, time)
	else
		print("Error: Config.ShowProgressBar is not defined")
	end
end

-- [Server] Broadcast/announce to everyone (depending on Config.announce implementation).
function announce(title, message, time)
	if time == nil then
		time = 20 * 1000
	end
	if Config.announce then
		Config.announce(title, message, time)
	else
		print("Error: Config.announce is not defined")
	end
end

-- [Shared] Serializes tables/values into a string representation (debug helper).
function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end

-- [Shared] Splits a string by a separator (default: whitespace).
function mysplit (inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

-- [Shared] Checks if a text contains potential XSS/JavaScript injection indicators.
-- Returns: boolean hasXss, string firstMatch (nil if none).
-- Note: This is a conservative surface check. It does not parse HTML; it looks for
-- common dangerous substrings and simple tag patterns (case-insensitive).
function containsXSS(text)
    if text == nil then
        return false, nil
    end

    local s = tostring(text)
    local lower = s:lower()

    -- Plain substring indicators (searched as plain strings)
    local indicators = {
        "<script", "</script", "javascript:", "vbscript:",
        "data:text/html", "data:text/javascript", "data:text/plain", "data:text/xml",
        "onerror=", "onload=", "onmouseover=", "onmouseenter=", "onmouseout=", "onfocus=", "onblur=", "onchange=", "onclick=", "onkeydown=", "onkeyup=", "onkeypress=",
        "<iframe", "<img", "<svg", "<object", "<embed", "<link", "<meta", "<video", "<audio"
    }

    for _, marker in ipairs(indicators) do
        if string.find(lower, marker, 1, true) then -- plain find
            return true, marker
        end
    end

    -- Very simple pattern for an HTML tag like <tag ...>
    if lower:find("<%s*%w+[^>]*>") then
        return true, "<tag>"
    end

    return false, nil
end

-- [Shared] Checks whether a text is considered safe (no JS scripts or disallowed symbols).
-- Rules:
--  - Length must be between 2 and 512 after trimming.
--  - Characters blacklist (strict vs. relaxed):
--      strict (default): blocks <, >, `, {, }, \
--      relaxed=true: blocks only < and > (allows `, {, }, \\)
--  - Always blocks common XSS/JS patterns: <script>, on*="", javascript:, data:text/html,
--    eval(, Function(, setTimeout(, setInterval(, ${...}
-- Params:
--  - text (string): input to validate
--  - relaxed (boolean|nil): when true, be less strict with special characters
function isSafeText(text, relaxed)
    if type(text) ~= 'string' then return false end
    if type(relaxed) ~= 'boolean' then relaxed = false end
    -- trim
    local trimmed = text:gsub('^%s+', ''):gsub('%s+$', '')
    if #trimmed < 2 or #trimmed > 512 then return false end

    -- character blacklist (minimizes XSS risk, still allows umlauts and standard letters)
    local forbiddenPattern = relaxed and "[<>]" or "[<>`{}\\]"
    if string.find(trimmed, forbiddenPattern) then
        return false
    end

    local lowered = string.lower(trimmed)

    -- forbidden patterns (Lua patterns)
    local forbidden = {
        '<%s*/?%s*script',    -- <script> or </script>
        'on%w+%s*=',          -- onload=, onclick=, onerror=, ...
        'javascript%s*:',     -- javascript:
        'data%s*:%s*text/html',
        'data%s*:%s*application/javascript',
        '%f[%w]eval%f[%W]%s*%(',
        '%f[%w]function%f[%W]%s*%(',
        '%f[%w]settimeout%f[%W]%s*%(',
        '%f[%w]setinterval%f[%W]%s*%(',
        '%$%s*%b{}',          -- ${...}
    }

    for _, pat in ipairs(forbidden) do
        if string.find(lowered, pat) then
            return false
        end
    end

    return true
end