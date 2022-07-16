--[[
    FileName	> wind.lua
    Author  	> AveryArk
    Contact 	> Twitter: https://twitter.com/averyark_
    Created 	> 02/07/2022
--]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContentProvider = game:GetService("ContentProvider")
local ContextActionService = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local SocialService = game:GetService("SocialService")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local PolicyService = game:GetService("PolicyService")
local TextService = game:GetService("TextService")
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

local WindShake = require(ReplicatedStorage.shared.WindShake)

local wind = Knit.CreateController({
	Name = "wind",
})

function wind:KnitStart()
	WindShake:SetDefaultSettings({
		WindSpeed = 20,
		WindDirection = Vector3.new(1, 0, 0.3),
		WindPower = 0.4,
	})
	WindShake:Init()
end

return wind
