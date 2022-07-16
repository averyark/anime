--[[
    FileName	> grassRender.lua
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

local WindShake = require(script.windshakegrass)

local grassRender = Knit.CreateController {
    Name = "grassRender";
}

local _settings = {
    MaximumRenderDistance = 200,
    VisibilityFade_OutOfDistance = true,

    MaximumWindShakeDistance = 100,
    WindShakeFrequencyFade_OutOfDistance = true,

    ComputeHZ = 1/45,
}

local grass = ReplicatedStorage.assets.grass

local rand = Random.new()

local rayP = RaycastParams.new()
rayP.IgnoreWater = true
rayP.FilterDescendantsInstances = {workspace.Terrain}
rayP.FilterType = Enum.RaycastFilterType.Whitelist


local getGrasses = function()
    return workspace.Effects:GetChildren();
end

local populate = function(
        position : Vector3, -- The position to spawn the grass objects at
        area : number, -- The area the grass objects should cover
        density : number -- The high the density, the more grass objects that will spawn
    ) : {Part}

    local grasses = {}
    local nG = math.round(area^2*density)

    local h, s, v =  grass.Color:ToHSV()

    for i = 1, nG do
        local _g = grass:Clone()
        local offX, offZ = rand:NextNumber(-1, 1), rand:NextNumber(-1, 1)  --rand:NextUnitVector()
        local roX, roY, roZ = rand:NextInteger(-20, 20), rand:NextInteger(0, 180), rand:NextInteger(-20, 20)
        local pos = position + (Vector3.new(offX, 0, offZ)*area/2)
        local tint = h + 0.05*math.clamp(math.noise(pos.X, pos.Y, pos.Z), -1, 1)
        local offSize = Vector3.new(0, rand:NextNumber(-2, 1), 0)
        _g.Size = _g.Size + offSize
        _g.Color = Color3.fromHSV(tint, s, v)
        _g.CFrame =  CFrame.new(pos + offSize/2) * CFrame.Angles(math.rad(roX), math.rad(roY), math.rad(roZ))
        _g.Parent = workspace.Effects
        table.insert(grasses, _g)
    end

    return grasses;
end

local render = function(camera)
    local rD = _settings.MaximumRenderDistance
    local wsD = _settings.MaximumWindShakeDistance
    local sc = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
    RunService.RenderStepped:Connect(function(deltaTime)
       
    end)
end

local expand = function(v3)
    return v3.X, v3.Y, v3.Z;
end

local registry : {r} = {}
local hashMap : {[MeshPart]: r} = {}

local _windDirection =  Vector3.new(5, 0, 0.3)
local _noiseOffset = Vector3.new(0, 0, 0)
local _windSpeed = 20
local _windPower = 0.5
local _MaximumRenderDistance = _settings.MaximumRenderDistance
local _VisibilityFade_OutOfDistance = _settings.VisibilityFade_OutOfDistance
local _MaximumWindShakeDistance = _settings.MaximumWindShakeDistance
local _WindShakeFrequencyFade_OutOfDistance = _settings.WindShakeFrequencyFade_OutOfDistance
local _ComputeHZ = _settings.ComputeHZ

local _varp5 = _MaximumRenderDistance/2

local highestScale = 0

local stem = ReplicatedStorage.assets.stem

local new = function(object)
    local tb = {
        object = object,
        origin = object.CFrame,
        seed = math.random(1000) * 0.1,
        --priority = 0,
        new = 0,
        scale = 0
    }
    local x1, x2, x3 = expand(object.Size/grass.Size)
    tb.scale = (x1 + x2 + x3)/3
    if tb.scale > highestScale then
        highestScale = tb.scale
    end
    local _stem = stem:Clone()
    local cfCache = object.CFrame
    utilities.instance.new("Weld", {
        Parent = object,
        Part0 = object,
        Part1 = _stem,
        C0 = CFrame.new(0, -object.Size.Y/2, 0)
    })
    object.Anchored = false
    _stem.CFrame = cfCache
    _stem.Position -= Vector3.new(0, object.Size.Y/2 + 0.1, 0)
    _stem.Parent = object
    table.insert(registry, tb)
    WindShake:AddObjectShake(_stem)
    return tb;
end
type r = typeof(new(Instance.new("Part")))


function grassRender:KnitStart()
    local sc = utilities.ui.get("Interface").uiObject.Frame
    sc.t1.Text = "Grass Count: " .. #getGrasses()
    local camera = workspace.CurrentCamera
    local began = false
    -- color
    local h, s, v = grass.Color:ToHSV()
    WindShake:SetDefaultSettings {
        WindSpeed = 20,
        WindDirection = Vector3.new(1, 0, 0.3),
        WindPower = 0.4
    }
    WindShake:Init()
    for _, object : MeshPart in getGrasses() do
        if registry[object] then return; end
        local pos = object.Position
        local tint = h + 0.05*math.clamp(math.noise(pos.X, pos.Y, pos.Z), -1, 1)
        object.Color = Color3.fromHSV(tint, s, v)
        object.Position = object.Position - -object.CFrame.LookVector * 0.2
        new(object)
    end
    began = true
    -- wind shake
    local hz = _settings.ComputeHZ
    local last = 0

    -- step
    local rayParam = RaycastParams.new()
    rayParam.IgnoreWater = true

    RunService.Heartbeat:Connect(function(dt)
        if not began then return; end
        local now = os.clock()
        if now - last < hz then
            return;
        end
       -- debug.profilebegin("ambience_grass_active_search")
        --updateObjectPriority()
        --debug.profileend()

        debug.profilebegin("ambience_grass_calculation")
        local outOfRender = 0
        
		for i, p in registry do
            --local p = grassHashMap[object]
            local object = p.object
            local distance = (p.origin.Position - camera.CFrame.Position).Magnitude
            
            if distance < _MaximumRenderDistance then
                if p.scale < highestScale*(distance/_MaximumRenderDistance) then
                    object.Parent = nil
                    outOfRender += 1
                else
                    if object.Parent == nil then
                        object.Parent = workspace.Effects
                    end
                end
            else
                object.Parent = nil
                outOfRender += 1
            end
            last = now
		end
        debug.profileend()
       -- debug.profilebegin("ambience_grass_apply")
        --workspace:BulkMoveTo(objectTable, cfTable, Enum.BulkMoveMode.FireCFrameChanged)
        --debug.profileend()
        local n = #registry
        sc.t1.Text = "Sample: " .. n
        sc.t2.Text = "Active: " .. WindShake.Active
        sc.t3.Text = "InRender: " .. n - outOfRender
        
	end)
    render(workspace.CurrentCamera)
end

return grassRender;