--[[
    FileName    > ui
    Author      > AveryArk
    Contact     > Twitter: https://twitter.com/averyark_
    Created     > 16/06/2022
--]]

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local t = require(ReplicatedStorage.Packages.t)
local Signal = require(ReplicatedStorage.Packages.Signal)

local isInstance = t.typeof("Instance")
local isAGuiObject = t.instanceIsA("GuiObject")
local isScreenGui = t.instanceIsA("ScreenGui")
local isAFrame = t.instanceIsA("Frame")
local isATextLabel = t.instanceIsA("TextLabel")
local isAImageLabel = t.instanceIsA("ImageLabel")
local isAButton = t.instanceIsA("GuiButton")
local isATextButton = t.instanceIsA("TextButton")
local isAImageButton = t.instanceIsA("ImageButton")
local isATextBox = t.instanceIsA("TextBox")

local ui = {}
local userInterfaces = {}
local listeners = {}

ui.__index = ui

ui.__initInterface = function(self : ui)
    self.uiObject.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

ui.__resetInterface = function(self : ui)
    self.onDeinit:Fire(self.uiObject)
    self.uiObject = self._realUiObject:Clone()
    self:__initInterface()
    self.onInit:Fire(self.uiObject)
end

ui.observe = function(self : ui, callback : (ui: ui) -> ())
    if self.uiObject and self.uiObject:IsDescendantOf(Players.LocalPlayer.PlayerGui) then
        return callback(self);
    end
    self.onInit:Wait()
    return callback(self);
end

ui.destroy = function(self : ui)
    self.onDeinit:Fire(self.uiObject)
    self._maid:Destroy()
    userInterfaces[self._realUiObject.Name] = nil
end

ui.Destroy = ui.destroy

ui.new = function(uiObject: ScreenGui | string)-- : ui
    t.strict(isInstance(uiObject))
    t.strict(isScreenGui(uiObject) or t.string(uiObject))

    local _realUiObject
    
    if not isScreenGui(uiObject) then
        _realUiObject = ReplicatedStorage.Interface:FindFirstChild(uiObject)
    else
        _realUiObject = uiObject
    end

    if not isScreenGui(_realUiObject) then
        error(("ui: Could not find UI object with name %s."):format(tostring(uiObject)))
    end

    local self = setmetatable({
        _realUiObject = _realUiObject,
        _maid = Janitor.new(),
        uiObject = _realUiObject:Clone(),
        onInit = Signal.new(),
        onDeinit = Signal.new(),
    }, ui)

    self._maid:Add(self._realUiObject.Destroying:Connect(function()
        self:destroy()
    end))
    self._maid:Add(Players.LocalPlayer.CharacterRemoving:Connect(function(character)
        if self._realUiObject.ResetOnSpawn then
            self:__resetInterface()
        end
    end))
    self._maid:Add(self.uiObject)
    
    userInterfaces[_realUiObject.Name] = self
    self.uiObject.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local _uiListeners = listeners[self._realUiObject.Name]
    
    warn(listeners)

    if _uiListeners then
        print(_uiListeners)
        for _, thread in _uiListeners do
            coroutine.resume(thread, self)
            table.remove(listeners[self._realUiObject.Name], table.find(listeners[self._realUiObject.Name], thread))
        end
        listeners[self._realUiObject.Name] = nil
    end
    return self;
end

ui.get = function(uiName : string) : ui
    if userInterfaces[uiName] then
        return userInterfaces[uiName];
    end
    if not listeners[uiName] then
        listeners[uiName] = {}
    end
    table.insert(listeners[uiName], coroutine.running())
    return coroutine.yield();
end

export type ui = typeof(ui.new(Instance.new("ScreenGui")))

task.spawn(function()
    if not RunService:IsClient() then
        return;
    end
    local pgui = Players.LocalPlayer:WaitForChild("PlayerGui")

    local test_hide = pgui:FindFirstChild("test-hide")
    local test_run = pgui:FindFirstChild("test-run")

    if test_hide then
       for _, child in test_hide:GetChildren() do
           child.Enabled = false
       end
    end
    if test_run then
        for _, child in test_run:GetChildren() do
            if isScreenGui(child) and not userInterfaces[child.Name] then
                ui.new(child)
            end
        end
    end

    for _, interface in ReplicatedStorage.Interface:GetChildren() do
        ui.new(interface)
    end

    ReplicatedStorage.Interface.ChildAdded:Connect(function(child)
        if isScreenGui(child) then
            ui.new(child)
        end
    end)

end)

return ui :: {
    new: typeof(ui.new),
    get: typeof(ui.get),
};