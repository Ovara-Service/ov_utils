--[[ Utils Version 1.1.6 ]] --

function getConfig(...)
	return getConfigValue(OV_CONFIG_DATA, ...)
end

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

function replaceDefaultKeys(message)
	if message ~= nil then
		message = message:gsub("{serverName}", tostring(GetConvar("serverName", "ServerName")), 1)
		message = message:gsub("{serverLogo}", tostring(GetConvar("serverLogo", "https://www.floba-media.de/wp-content/uploads/2025/02/ovara_logo.png")), 1)
		message = message:gsub("{discordUrl}", tostring(GetConvar("discordUrl", "discordUrl")), 1)
		message = message:gsub("{website}", tostring(GetConvar("website", "website")), 1)
	end

	return message
end

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

function isDebug()
	if OV_CONFIG_DATA ~= nil then
		return getConfig("debug")
	end

	return Config.debug
end

function debugPrint(msg)
	if isDebug() then
		print('Debug: ' .. tostring(msg))
	end
end

function notify(src, type, message)
	Config.notify(src, type, getMsg('notify_title'), tostring(message))
end

function notifyT(src, type, titleKey, message)
	Config.notify(src, type, getMsg(titleKey.. "_title"), tostring(message))
end

function notifyKey(src, type, key, ...)
	Config.notify(src, type, getMsg('notify_title'), getMsg(key, ...))
end

function notifyKeyT(src, type, titleKey, key, ...)
	Config.notify(src, type, getMsg(titleKey.. "_title"), getMsg(key, ...))
end

function notifyKeyTitle(src, type, title, key, ...)
	Config.notify(src, type, title, getMsg(key, ...))
end

function notifyC(type, message)
	Config.notify(nil, type, getMsg('notify_title'), tostring(message))
end

function notifyCKey(type, key, ...)
	Config.notify(nil, type, getMsg('notify_title'), getMsg(key, ...))
end

function notifyCKeyT(type, titleKey, key, ...)
	Config.notify(nil, type, getMsg(titleKey .. "_title"), getMsg(key, ...))
end

function helpNotify(src, message)
	if Config.HelpNotify then
		Config.HelpNotify(src, message)
	else
		print("Error: Config.HelpNotify is not defined")
	end
end

function helpNotifyC(message)
	if Config.HelpNotify then
		Config.HelpNotify(nil, message)
	else
		print("Error: Config.HelpNotify is not defined")
	end
end

function progressBar(src, time)
	if Config.ShowProgressBar then
		Config.ShowProgressBar(src, time)
	else
		print("Error: Config.ShowProgressBar is not defined")
	end
end

function progressBarC(time)
	if Config.ShowProgressBar then
		Config.ShowProgressBar(nil, time)
	else
		print("Error: Config.ShowProgressBar is not defined")
	end
end

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