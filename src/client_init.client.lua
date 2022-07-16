-- Test comment.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local utilities = require(ReplicatedStorage.utilities)

local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))
local Knit = require(ReplicatedStorage.Packages.Knit)
local Loader = require(ReplicatedStorage.Packages.Loader)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local t = require(ReplicatedStorage.Packages.t)
local TestEZ = require(ReplicatedStorage.Packages.TestEZ)

Loader.LoadDescendants(script.Parent:FindFirstChild("client"))

print("done")

Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
Knit
	:Start()
	:andThen(function()
		print(("[CLIENT_%s] Knit Initialized; developed by @arkizen."):format(Players.LocalPlayer.UserId))
	end)
	:catch(warn)
