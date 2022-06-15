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

Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })

Knit.Start():andThen(function()
    print(("[CLIENT_%s] Knit Initialized; developed by @arkizen."):format(Players.LocalPlayer.UserId))

end):catch(warn);

print(utilities)

if RunService:IsStudio() then
    TestEZ.TestBootstrap:run({
        ReplicatedStorage["utilities.spec"]
    })
end

print(utilities.string.tostringTable({
    ["TestString"] = "Test",
    ["TestNumber"] = 1,
    ["TestObject"] = script,
    ["TestVector3"] = Vector3.new(),
    ["TestVector2"] = Vector2.new(),
    ["TestUDim2"] = UDim2.new(),
    ["TestUDim"] = UDim.new(),
    ["TestTable"] = {
        ["TestTableString"] = "Test",
        ["TestTableNumber"] = 1,
        ["TestTableObject"] = script,
        ["TestSubTable"] = {
            ["TestSubTableString"] = "Test",
            ["TestSubTableNumber"] = 1,
            ["TestSubTableObject"] = script,
        }
    },
    [1] = "First",
    [2] = "Second",
    [3] = "Third",
    ["TestDecimal"] = {
        [1] = math.random(1,9)^-math.random(1,9),
        [2] = Vector3.new(math.random(1,9)^-math.random(1,9), math.random(1,9)^-math.random(1,9), math.random(1,9)^-math.random(1,9)),
        [3] = Vector2.new(math.random(1,9)^-math.random(1,9), math.random(1,9)^-math.random(1,9))
    },
}))

utilities.string.iterateString("testiNG", function(_currentString, index, next, lastStringIsLowerCase)
    print(_currentString, lastStringIsLowerCase)

    next(_currentString:lower() == _currentString)
end)

print(utilities.string.tostringTable(utilities.string.search("testing something", {
    ["test"] = 1,
    ["Test"] = 2,
    ["Testin"] = 3,
    ["Testing"] = 4,
    ["testing"] = 5,
    ["t"] = 6,
    ["testing somethin"] = 7,
    ["testing smthn"] = 8,
    ["TESTING SOMETHING"] = 9,
}, 1).fromMostRelevant()))

print("resumed")

local ui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

local sf = ui.Frame.ScrollingFrame
local tb = ui.Frame.TextBox

local key = {}

for _, object in utilities.instance.childrenThatIsA(sf, "TextLabel") do
    key[object.Text] = object
end

print(utilities.string.shiftMatched("test test", " "))

local update = function(input)
    local searchResults = utilities.string.search(input, key, 2)
    for order, tble in searchResults.fromMostRelevant() do
        tble.value.Visible = true
        tble.value.LayoutOrder = order
        tble.value.Text = tble.key  .. " " .. tble.relavance
        tble.value.BackgroundColor3 = Color3.fromRGB(255, 148, 213)
    end
    for _, tble in searchResults.fromIrrelevants() do
        tble.value.Visible = false
       -- tble.value.Text = tble.key .. " " .. tble.relavance
        --tble.value.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end

tb:GetPropertyChangedSignal("Text"):Connect(function()
    update(tb.Text)
end)

update("")