--[[
    FileName	> tester.lua
    Author  	> AveryArk
    Contact 	> Twitter: https://twitter.com/averyark_
    Created 	> 02/07/2022
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
local LocalizationService = game:GetService('LocalizationService')

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local t = require(ReplicatedStorage.Packages.t)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local utilities = require(ReplicatedStorage.utilities)
local matter = require(ReplicatedStorage.Packages.matter)

local tester = Knit.CreateController {
    Name = "tester";
}

function tester:KnitStart()
    local rock = require(ReplicatedStorage.shared.Rock)
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.KeyCode == Enum.KeyCode.R then
            print(gameProcessedEvent)
            rock.Debris(Players.LocalPlayer.Character.HumanoidRootPart, 2, 5, 30)
        end
        if input.KeyCode == Enum.KeyCode.Q then
            print(gameProcessedEvent)
            rock.Crater(Players.LocalPlayer.Character.HumanoidRootPart, 8, 2, 30)
        end
    end)
end

return tester;