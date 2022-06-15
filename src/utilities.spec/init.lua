local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)

-- this will be the hardest code to read in your life

return function ()
    local utilities = require(script.Parent.utilities)

    beforeAll(function(context)
        context._maid = Janitor.new()
    end)

    describe("Testing compatibality of um object with built in utilities modules", function()
       
    end)

    afterAll(function(context)
        context._maid:Destroy()
    end)

end