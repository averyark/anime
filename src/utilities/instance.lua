--!strict
-- instance
-- Arkizen
-- 09/06/2022


local instanceUtil = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)

local isInstance = t.typeof("Instance")

-- returns the first children that matches the instance class type
function instanceUtil.firstChildrenThatIsA(parent : Instance, className : string) : Instance?
    t.strict(isInstance(parent))
    for _, child in parent:GetChildren() do
        if child:IsA(className) then
            return child;
        end
    end
    return;
end

-- returns the first descendant that matches the instance class type
function instanceUtil.firstDescendantThatIsA(ancestor : Instance, className : string) : Instance?
    t.strict(isInstance(ancestor))
    for _, descendant in ancestor:GetDescendants() do
        if descendant:IsA(className) then
            return descendant;
        end
    end
    return;
end

-- returns all the childrens that matches the instance class type
function instanceUtil.childrenThatIsA(parent : Instance, className : string) : {Instance?}
    t.strict(isInstance(parent))
    local instances = {}
    for _, child in parent:GetChildren() do
        if child:IsA(className) then
            table.insert(instances, child)
        end
    end
    return instances;
end

-- returns all the descendants that matches the instance class type
function instanceUtil.descendantThatIsA(ancestor : Instance, className : string) : {Instance?}
    t.strict(isInstance(ancestor))
    local instances = {}
    for _, descendant in ancestor:GetDescendants() do
        if descendant:IsA(className) then
            table.insert(instances, descendant)
        end
    end
    return instances;
end

-- returns the first children that doesn't match the instance class type
function instanceUtil.firstChildrenThatIsNotA(parent : Instance, className : string) : Instance?
    t.strict(isInstance(parent))
    for _, child in parent:GetChildren() do
        if not child:IsA(className) then
            return child;
        end
    end
    return;
end

-- returns the first descendant that doesn't match the instance class type
function instanceUtil.firstDescendantThatIsNotA(ancestor : Instance, className : string) : Instance?
    t.strict(isInstance(ancestor))
    for _, descendant in ancestor:GetDescendants() do
        if not descendant:IsA(className) then
            return descendant;
        end
    end
    return;
end

-- returns all the childrens except instances that matches the class type
function instanceUtil.childrenThatIsNotA(parent : Instance, className : string) : {Instance?}
    t.strict(isInstance(parent))
    local instances = {}
    for _, child in parent:GetChildren() do
        if child:IsA(className) then
            table.insert(instances, child)
        end
    end
    return instances;
end

-- returns all the descendants except instances that matches the class type
function instanceUtil.descendantThatIsNotA(ancestor : Instance, className : string) : {Instance?}
    t.strict(isInstance(ancestor))
    local instances = {}
    for _, descendant in ancestor:GetDescendants() do
        if not descendant:IsA(className) then
            table.insert(instances, descendant)
        end
    end
    return instances;
end



-- creates a instance of a class with option to preset properties and childrens
function instanceUtil.makeInstance(instanceClass : string, instanceTree : {[string | number] : any | Instance}?)
    local _instance = Instance.new(instanceClass)

    local f; f = function(_t)
        for k, val in _t do
            if typeof(k) == "string" then
                _instance[k] = val
            elseif typeof(val) == "Instance" then
                val.Parent = _instance
            elseif typeof(val) == "table" then
                if val ~= _t then
                    f(val)
                end
            end
        end
    end

    if instanceTree then
        f(instanceTree)
    end

    return _instance;
end

-- aliases
instanceUtil.new = instanceUtil.makeInstance

-- destorys all childrens that matches the className
function instanceUtil.destroyChildrenThatIsA(parent : Instance, className : string)
    t.strict(isInstance(parent))
    for _, insc in instanceUtil.childrenThatIsA(parent, className) do
        insc:Destroy()
    end
end

-- destorys all descendants that matches the className
function instanceUtil.destroyDescendantThatIsA(ancestor : Instance, className : string)
    t.strict(isInstance(ancestor))
    for _, insc in instanceUtil.descendantThatIsA(ancestor, className) do
        insc:Destroy()
    end
end

-- destorys all childrens that doesnt match the className
function instanceUtil.destroyChildrenThatIsNotA(parent : Instance, className : string)
    t.strict(isInstance(parent))
    for _, insc in instanceUtil.childrenThatIsNotA(parent, className) do
        insc:Destroy()
    end
end

-- destorys all descendants that doesnt match the className
function instanceUtil.destroyDescendantThatIsNotA(ancestor : Instance, className : string)
    t.strict(isInstance(ancestor))
    for _, insc in instanceUtil.descendantThatIsNotA(ancestor, className) do
        insc:Destroy()
    end
end

return instanceUtil;