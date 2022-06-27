--[[
    FileName	> test.lua
    Author  	> AveryArk
    Contact 	> Twitter: https://twitter.com/averyark_
    Created 	> 17/06/2022
--]]

local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local StarterGui = game:GetService('StarterGui')
local StarterPlayer = game:GetService('StarterPlayer')
local ReplicatedFirst = game:GetService('ReplicatedFirst')
local ContentProvider = game:GetService('ContentProvider')
local ContextActionService = game:GetService('ContextActionService')
local Lighting = game:GetService('Lighting')
local SoundService = game:GetService('SoundService')
local SocialService = game:GetService('SocialService')
local CollectionService = game:GetService('CollectionService')
local MarketplaceService = game:GetService('MarketplaceService')
local PolicyService = game:GetService('PolicyService')
local TextService = game:GetService('TextService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local t = require(ReplicatedStorage.Packages.t)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local utilities = require(ReplicatedStorage.utilities)

local test = Knit.CreateController {
    Name = "test";
    Client = {};
}
utilities.ui.get("test"):observe(function(ui)

end)

function test:KnitStart()

end

return test;