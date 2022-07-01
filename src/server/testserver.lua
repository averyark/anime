--[[
    FileName    > testserver.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 01/07/2022
--]]

local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local StarterPlayer = game:GetService('StarterPlayer')
local ReplicatedFirst = game:GetService('ReplicatedFirst')
local Lighting = game:GetService('Lighting')
local CollectionService = game:GetService('CollectionService')
local MarketplaceService = game:GetService('MarketplaceService')
local ServerScriptService = game:GetService('ServerScriptService')
local ServerStorage = game:GetService('ServerStorage')
local MessagingService = game:GetService('MessagingService')
local MemoryStoreService = game:GetService('MemoryStoreService')
local BadgeService = game:GetService('BadgeService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local t = require(ReplicatedStorage.Packages.t)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local utilities = require(ReplicatedStorage.utilities)

local testserver = Knit.CreateService {
    Name = "test";
}

utilities.remote.new("testing_get", "get"):Connect(function(player, s)
    task.wait(math.random(0.1, 1.2))
    return s/2 == math.round(s/2) and "even" or "odd";
end)
utilities.remote.new("testing_set", "set"):Connect(function(player, clientMsg)
    print("client says:", clientMsg)
end)
utilities.remote.new("testing")

task.wait(5)

utilities.remote.testing:FireAll("hi client")

function testserver:KnitStart()

end

return testserver;