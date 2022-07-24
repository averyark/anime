--[[
    FileName	> test.lua
    Author  	> AveryArk
    Contact 	> Twitter: https://twitter.com/averyark_
    Created 	> 16/07/2022
--]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local MessagingService = game:GetService("MessagingService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local t = require(ReplicatedStorage.Packages.t)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local utilities = require(ReplicatedStorage.utilities)
local matter = require(ReplicatedStorage.Packages.matter)

local test = Knit.CreateService({
	Name = "test",
	Client = {},
})

function test:KnitStart()
	utilities.player.observe(function(player) end)
	--[[utilities.data.observe(function(playerObject, playerData)
		warn(playerObject, playerData)
		playerData:set(function(store)
			store.Money += 50
			store.Test = true
			store.TestTable = {
				Test = 1,
				Test2 = 2
			}
		end)
	end)]]
	utilities.data.observe(function(playerObject, playerData)
		print(playerObject, playerObject.data == playerData)
	end)
	task.wait(5)
	for _, player in Players:GetPlayers() do
		utilities.player.some({ player }):edit("test", 100):edit("some", 50)
		utilities.player.all():iterate(function(playerObject)
			print(playerObject)
			utilities.data.capture(playerObject.object, function(storage)
				storage.Settings[1] = not storage.Settings[1]
			end)
		end)
		--[[utilities.data.capture(player, function(storage)
			storage.Money += 50
			print(storage.Money)
		end)]]
	end
end

return test
