local UseGlobalScore = GetConvar("DriftC_useGlobalScore", "true") -- Allow user to have the same score as the one they had on another server
local usePayout = GetConvar("DriftC_usePayout", "false") -- wether or not to pay out drifts.
local useFramework = GetConvar("DriftC_useFramework", "Native") -- either 'ES' or 'Native', anyone who reads this, please add VRP support since i cannot be bothered working with that sad excuse of an API.

local SaveAtEndOfDrift = GetConvar("DriftC_SaveAtEndOfDrift", "true") -- Set to false if you only want to save every `x` ms
local SaveTime = GetConvar("DriftC_SaveTime", 60000) -- How often you want to save if SaveAtEndOfDrift is false (In ms!)

if UseGlobalScore == "true" then UseGlobalScore = true else UseGlobalScore = false end
if usePayout == "true" then usePayout = true else usePayout = false end
if SaveAtEndOfDrift == "true" then SaveAtEndOfDrift = true else SaveAtEndOfDrift = false end

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

Citizen.CreateThread(function()	
	RegisterNetEvent("RequestConfig")
	AddEventHandler("RequestConfig", function()
		TriggerClientEvent("RecieveConfig", source, SaveAtEndOfDrift, SaveTime)
	end)
	
	if UseGlobalScore then
		
		local ServersOnline = true
		
		PerformHttpRequest('https://services.illusivetea.me/driftcounter-storage', function(statusCode, text, headers)
			if text ~= nil and statusCode == 200 then
				print(GetCurrentResourceName()..": Services are online! Global database is available!")
				ServersOnline = true
			else
				ServersOnline = false
				print("\n"..GetCurrentResourceName().." Error: Could not reach the service. Code: "..statusCode.."\nMake sure https://services.illusivetea.me/driftcounter-storage is accessable by your server.\nTo prevent errors, global database will not be available.")
			end
		end, 'GET', json.encode({}), { ["Content-Type"] = 'application/json' })
		
		if ServersOnline then
			
			RegisterNetEvent("SaveScore")
			AddEventHandler("SaveScore", function(client, data)
				UpdatePlayerInDB(client, data)
			end)
			
			RegisterNetEvent("LoadScoreData")
			AddEventHandler("LoadScoreData", function()
				GetPlayerInfo(source)
			end)
			
			
			function GetPlayerInfo(client)
				PerformHttpRequest('https://services.illusivetea.me/driftcounter-storage', function(statusCode, text, headers)
					if text ~= nil and statusCode == 200 then
						local data = json.decode(text)
						local foundUser = false
						for _,info in pairs(data["data"]) do
							if GetPlayerIdentifier(client,0) == info["identifier"] then
								foundUser = true
								TriggerClientEvent("LoadScore", client, info.score)
							end
						end
						
						if not foundUser then
							CreatePlayerInDB(client)
						end
					else
						print("Error occued. statusCode: "..statusCode)
					end
				end, 'GET', json.encode({}), { ["Content-Type"] = 'application/json' })
			end


			function UpdatePlayerInDB(client, data)
				PerformHttpRequest('https://services.illusivetea.me/driftcounter-storage?identifier='..GetPlayerIdentifier(client,0), function(statusCode, text, headers)
					
				end, 'PATCH', '{"score":'..data.score..',"username":"'..GetPlayerName(client)..'"}', { ["Content-Type"] = 'application/json' })
			end

			function CreatePlayerInDB(client)
				PerformHttpRequest('https://services.illusivetea.me/driftcounter-storage', function(statusCode, text, headers)
					
				end, 'POST', '{"identifier":"'..GetPlayerIdentifier(client,0)..'","score":0,"username" : "'..GetPlayerName(client)..'"}', { ["Content-Type"] = 'application/json' })
			end
		end
	end
end)

-- version check code, don't change this thanks

updatePath = "/Bluethefurry/FiveM-DriftCounter"
resourceName = "Drift Counter ("..GetCurrentResourceName()..")"
function checkVersion(err,responseText, headers)
	curVersion = LoadResourceFile(GetCurrentResourceName(), "version")

	if curVersion ~= responseText and tonumber(curVersion) < tonumber(responseText) then
		print("\n###############################")
		print("\n"..resourceName.." is outdated, should be:\n"..responseText.."\nis:\n"..curVersion.."\nplease update it from https://github.com"..updatePath.."")
		print("\n###############################")end
	SetTimeout(3600000, checkVersionHTTPRequest)	
end

function checkVersionHTTPRequest()
	PerformHttpRequest("https://raw.githubusercontent.com"..updatePath.."/master/version", checkVersion, "GET")
end
checkVersionHTTPRequest()
