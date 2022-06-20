--[[
    FileName	> test.lua
    Author  	> AveryArk
    Contact 	> Twitter: https://twitter.com/averyark_
    Created 	> 17/06/2022
--]]

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

utilities.ui.get("Test"):observe(function(ui)
        
end)

function test:KnitStart()

end

return test;