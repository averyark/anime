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
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local isClient = RunService:IsClient()

local registry = {
	clients = {},
    callbacks = {},
    allCache = {},
} -- cache
local mt : mt = {}

function mt:__changed(index, value, cache)
    self.changed:Fire(index, value, cache)
end

function mt:editLocal(index, value)
    local valueCache
    if isClient then
        local rawValueCache = self._properties.client[index]
        valueCache = typeof(rawValueCache) == "table" and TableUtil.DeepCopyTable(rawValueCache) or rawValueCache
        self._properties.client[index] = value
        self._clientChanged:Fire(index, value, valueCache)
    else
        local rawValueCache = self._properties.server[index]
        valueCache = typeof(rawValueCache) == "table" and TableUtil.DeepCopyTable(rawValueCache) or rawValueCache
        self._properties.server[index] = value
        self._serverChanged:Fire(index, value, valueCache)
    end
    self.localChanged:Fire(index, value, valueCache)
    self:__changed(index, value, valueCache)
end

function mt:edit(editServer, index, value)
    if editServer then
        if isClient then
            remote.__playerUtil__modifyProperty:Fire(index, value) -- cross editing
        elseif not isClient then
            self._properties.server[index] = value
        end
    else
        if not isClient then
            remote.__playerUtil__modifyProperty:Fire(self.object, index, value)
        elseif isClient then
            self._properties.client[index] = value
        end
    end
end

function mt:__onCrossEdited(index, value)
    local valueCache
    if isClient then
        local rawValueCache = self._properties.client[index]
        valueCache = typeof(rawValueCache) == "table" and TableUtil.DeepCopyTable(rawValueCache) or rawValueCache
        self.server[index] = value
        self._serverChanged:Fire(index, value, valueCache)
    else
        local rawValueCache = self._properties.client[index]
        valueCache = typeof(rawValueCache) == "table" and TableUtil.DeepCopyTable(rawValueCache) or rawValueCache
        self.client[index] = value
        self._clientChanged:Fire(index, value, valueCache)
    end
    self:__changed(index, value, valueCache)
end

function mt:getLocal(index) : any?
    if isClient then
        return self._properties.client[index]
    else
        return self._properties.server[index]
    end
end

function mt:getCross(index) : any?
    if isClient then
        return self._properties.server[index]
    else
        return self._properties.client[index]
    end
end

local initPlayer = function(player: Player, serverPacket: { [any]: any }?)
	assert(t.instanceIsA("Player")(player), "player expected")
	local self
	self = setmetatable({
            _serverChanged = Signal.new(),
            _clientChanged = Signal.new(),
            localChanged = Signal.new(),
            _properties = {
                server = {},
                client = isClient and registry.allCache or {},
            },
            maid = Janitor.new(),
            changed = Signal.new(),
            object = player
        }, {
		__newindex = function(_, index, value)
            self:editLocal(index, value)
		end,
		__index = function(_, index)
			local response = mt.getLocal(self, index)
            if response ~= nil then
                return response;
            end
            return mt[index];
		end,
	})

	--rawset(self, "player", player)
	
	rawset(self, "server", setmetatable({}, {
		__newindex = function(_self, index, value)
			self:edit(true, index, value)
		end,
		__index = function(_self, index)
            if index == "changed" then
                return self._serverChanged;
            end
            return self._properties.server[index];
        end,
	}))
	rawset(self, "client", setmetatable({}, {
		__newindex = function(_, index, value)
			self:edit(false, index, value)
		end,
		__index = function(_self, index)
            if index == "changed" then
                return self._clientChanged;
            end
            return self._properties.client[index];
        end,
	}))

    for _, sig in pairs(self) do
        if Signal.Is(sig) then
            self.maid:Add(sig)
        end
    end

    self.maid:Add(self.object.AncestryChanged:Connect(function()
        if not self.object:IsDescendantOf(Players) then
            if not isClient then
                registry.clients[player] = nil
            end
            self.maid:Destroy()
        end
    end))

	if not isClient then
		registry.clients[player] = self
	else
		if serverPacket then
			self._properties.client = serverPacket
		end

		registry.client = self
        print(registry.client)
	end

    for _, f in pairs(registry.callbacks) do
        Promise.try(function()
            f(self)
        end)
    end

	return self :: typeof(self) & {
        client: typeof(self.client) & {changed: typeof(Signal.new())},
        server: typeof(self.server) & {changed: typeof(Signal.new())},
    } & mt
end

type mt = typeof(mt) & typeof(initPlayer(Instance.new("Player")))

playerUtil.observe = function(callback)
    table.insert(registry.callbacks, callback)
end

playerUtil.me = function() : mt
    repeat
        task.wait()
    until registry.client
    return registry.client :: mt;
end

playerUtil.all = function(index, value) --: {[any]: any}--typeof(playerUtil.all())
    for _, self in pairs(registry.clients) do
        self.client[index] = value
    end
    registry.allCache[index] = value
end

playerUtil.single = function(player : Player) : mt
    assert(t.instanceIsA("Player")(player), "Player expected")
    return registry.clients[player :: Player] :: mt;
end

playerUtil.some = function(players : {Player?}, index, value)
    for _, self in pairs(registry.clients) do
        if table.find(players, self.object) then
            self.client[index] = value
        end
    end
end

playerUtil.except = function(players : {Player?}, index, value)
    for _, self in pairs(registry.clients) do
        if not table.find(players, self.object) then
            self.client[index] = value
        end
    end
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
        remote.new("__playerUtil__propertyModified"):Connect(function(player, index, value)
            playerUtil.single(player):__onCrossEdited(index, value)
        end)
		remote.new("__playerUtil__retrieveClientModel", "get"):Connect(function(player)
			return registry.clients[player]._properties.client;
		end)
		remote.new("__playerUtil__modifyProperty"):Connect(function(player, index, value)
            local self = registry.clients[player] :: mt
            self:editLocal(index, value)
		end)
	else
        remote.get("__playerUtil__propertyModified"):Connect(function(index, value)
            registry.client:__onCrossEdited(index, value)
        end)
		remote.get("__playerUtil__modifyProperty"):Connect(function(index, value)
            local self = registry.client :: mt
            self:editLocal(index, value)
		end)
		initPlayer(Players.LocalPlayer, remote.get("__playerUtil__retrieveClientModel"):Retrieve()) -- yield
	end
end
--type p = typeof(initPlayer(Instance.new("Player")))

task.spawn(init)

return playerUtil --[[:: {
    me: () -> (mt),
    observe: ((mt) -> ()) -> (),
    all: () -> (typeof(playerUtil.all())),
    single: (Player) -> (typeof(playerUtil.single(Instance.new("Player")))),
    some: ({Player}) -> (typeof(playerUtil.some({}))),
    except: ({Player}) -> (typeof(playerUtil.some({})))
}; --[[:: mt & {
    client: mt,
    observe: ((mt) -> ()) -> (),
    all: () -> (typeof(playerUtil.all())),
    single: (Player) -> (typeof(playerUtil.single(Instance.new("Player")))),
    some: ({Player}) -> (typeof(playerUtil.some({}))),
    except: ({Player}) -> (typeof(playerUtil.some({})))
};]]
