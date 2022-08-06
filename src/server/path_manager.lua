--[[
    FileName    > path_manager.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 06/08/2022
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

local path_manager = Knit.CreateService({
	Name = "path_manager",
	Client = {},
})

function path_manager:makePath(paths : {[number]: Part}, lastPoint : Part)

    local pathWidth = 4
    local pathHeight = 0.1

    local padding = 2

    local waypoints = {}

    for _, path : Part in paths do
        local pOrientation = path.Orientation
        local pPosition = path.Position
        local pSize = path.Size
        local length = pSize.X
        assert(pSize.Z ~= pathWidth or pSize.Y ~= pathHeight, "[path_manager] Invalid path; Expected path size is (x, 0.1, 4).")

        local point = CFrame.new(pPosition.X + length - padding.X, pathHeight, pathWidth)
        local relativePoint = point:ToObjectSpace(path.CFrame)

        table.insert(waypoints, relativePoint)
    end

    table.insert(waypoints, lastPoint)
end

function path_manager:KnitStart()

end

return path_manager
