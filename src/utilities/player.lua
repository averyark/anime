--!strict
--[[
    FileName    > player.lua
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 16/07/2022
--]]

local playerUtil = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local remote = require(script.Parent.remote)

local isClient = RunService:IsClient()

local registry = {

	clients = {},
	template = {
		_properties = {
			server = {},
			client = {},
		},
	},
} -- cache
local mt = {}

function mt:__set(index, value)
	if not isClient then
		rawset(self._properties.client, index, value)
	elseif isClient then
		rawset(self._properties.server, index, value)
	end
end

local initPlayer = function(player: Player, serverPacket: { [any]: any }?)
	print(serverPacket)
	assert(t.instanceIsA("Player")(player), "player expected")
	local self
	self = setmetatable(registry.template, {
		__newindex = function(_, index, value)
			if isClient then
				self._properties.client[index] = value
			else
				self._properties.server[index] = value
			end
		end,
		__index = function(_, index)
			if isClient then
				if self._properties.client[index] then
					return self._properties.client[index]
				end
			else
				if self._properties.server[index] then
					return self._properties.server[index]
				end
			end
			return mt[index]
		end,
	})

	self.player = player
	self._maid = Janitor.new()
	self.server = setmetatable({}, {
		__newindex = function(_self, index, value)
			if self._properties.server[index] then -- attempting to edit server property
				if isClient then
					remote.__playerUtil__modifyProperty:Fire(index, value)
				elseif not isClient then
					self._properties.server[index] = value
				end
			end
		end,
		__index = self._properties.server,
	})
	self.client = setmetatable({}, {
		__newindex = function(_self, index, value)
			if self._properties.client[index] then -- attempting to edit client property
				if not isClient then
					remote.__playerUtil__modifyProperty:Fire(self.player, index, value)
				elseif isClient then
					self._properties.client[index] = value
				end
			end
		end,
		__index = self._properties.client,
	})

	if not isClient then
		registry.clients[player] = self
	else
		if serverPacket then
			self._properties.client = serverPacket
		end
		registry.client = self
	end
	return self
end

local init = function()
	if not isClient then
		Players.PlayerAdded:Connect(initPlayer)
		for _, player in Players:GetPlayers() do
			Promise.try(function()
				if not registry.clients[player] then
					initPlayer(player)
				end
			end)
		end
		remote.new("__playerUtil__retrieveClientModel", "get"):Connect(function(player)
			return registry.clients[player]._properties.client
		end)
		remote.new("__playerUtil__modifyProperty"):Connect(function(player, index, value)
			registry.clients[player]:__set(index, value)
		end)
	else
		remote.get("__playerUtil__modifyProperty"):Connect(function(index, value)
			registry.client:__set(index, value)
		end)
		initPlayer(Players.LocalPlayer, remote.get("__playerUtil__retrieveClientModel"):Retrieve())
	end
end

task.spawn(init)

return playerUtil;