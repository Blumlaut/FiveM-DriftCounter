
local usePayout = true -- weither or not to pay out drifts.
local useFramework = "Native" -- either 'ES' or 'Native', anyone who reads this, please add VRP support since i cannot be bothered working with that sad excuse of an API.

Citizen.CreateThread(function()
	RegisterServerEvent("driftcounter:payDrift")
	AddEventHandler('driftcounter:payDrift', function(money)
		if usePayout and useFramework == "ES" then
			TriggerEvent('es:getPlayerFromId', source, function(ourUser) 
				if ourUser then
					ourUser.addMoney(money)
				end
			end)
		elseif usePayout and useFramework == "Native" then
			TriggerClientEvent("SetPlayerNativeMoney", source, money)
		end
		
	end)
end)

-- version check code, don't change this thanks


function checkVersion(err,responseText, headers)
	curVersion = LoadResourceFile(GetCurrentResourceName(), "version")

	updatePath = "/Bluethefurry/FiveM-DriftCounter"
	resourceName = "Drift Counter ("..GetCurrentResourceName()..")"

	if curVersion ~= responseText and tonumber(curVersion) < tonumber(responseText) then
		print("\n###############################")
		print("\n"..resourceName.." is outdated, should be:\n"..responseText.."is:\n"..curVersion.."\nplease update it from https://github.com"..updatePath.."")
		print("\n###############################")end
	SetTimeout(3600000, checkVersionHTTPRequest)	
end

function checkVersionHTTPRequest()
	PerformHttpRequest("https://raw.githubusercontent.com"..updatePath.."/master/version", checkVersion, "GET")
end
checkVersionHTTPRequest()