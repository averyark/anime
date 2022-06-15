-- instance.spec
-- Arkizen
-- 09/06/2022

local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function()
	local instance = require(ReplicatedStorage.utilities).instance

	describe("instance.makeInstance", function()
		it("should make a NumberValue with a value of 5 and name of \"_testEZ_NumberValue\"", function()
			local dummyInstance = instance.makeInstance("NumberValue", {
				Value = 5,
				Name = "_testEZ_NumberValue",
			})
			expect(dummyInstance).to.be.a("userdata")
			expect(dummyInstance.ClassName == "NumberValue").to.be.ok()
			expect(dummyInstance.Value).to.be.equal(5)
			expect(dummyInstance.Name == "_testEZ_NumberValue").to.be.ok()
		end)
		it(
			"should make a NumberValue with a value of 5 and name of \"_testEZ_NumberValue\" and a ObjectValue and a StringValue",
			function()
				local dummyInstance = instance.makeInstance("NumberValue", {
					Value = 5,
					Name = "_testEZ_NumberValue",
					instance.makeInstance("ObjectValue", {
						Value = script.Parent.instance,
						Name = "_testEZ_ObjectValue",
					}),
					instance.makeInstance("StringValue", {
						Value = "TestEZ",
						Name = "_testEZ_StringValue",
					}),
				})
				-- expects the dummy Instance is a NumberValue classType Instance, and has a value of 5 with a name of _testEZ_NumberValue
				expect(dummyInstance).to.be.a("userdata")
				expect(dummyInstance.ClassName).to.be.equal("NumberValue")
				expect(dummyInstance.Value).to.be.equal(5)
				expect(dummyInstance.Name).to.be.equal("_testEZ_NumberValue")

				-- expects a children with a name of _testEZ_ObjectValue with a ObjectValue classType and an object value of the instance module itself
				expect(dummyInstance._testEZ_ObjectValue).to.be.a("userdata")
				expect(dummyInstance._testEZ_ObjectValue.ClassName).to.be.equal("ObjectValue")
				expect(dummyInstance._testEZ_ObjectValue.Value).to.be.equal(script.Parent.instance)
				expect(dummyInstance._testEZ_ObjectValue.Name).to.be.equal("_testEZ_ObjectValue")

				-- expects a children with a name of _testEZ_StringValue with a StringValue classType and a string value "TestEZ"
				expect(dummyInstance._testEZ_StringValue).to.be.a("userdata")
				expect(dummyInstance._testEZ_StringValue.ClassName).to.be.equal("StringValue")
				expect(dummyInstance._testEZ_StringValue.Value).to.be.equal("TestEZ")
				expect(dummyInstance._testEZ_StringValue.Name).to.be.equal("_testEZ_StringValue")
			end
		)
	end)

	local _dummyInstance = instance.makeInstance("NumberValue", {
		instance.makeInstance("StringValue", { Name = "Test1" }),
		instance.makeInstance("NumberValue", {
			Name = "Test2",
			[1] = instance.makeInstance("ObjectValue", { Name = "Test2a" }),
			[2] = instance.makeInstance("ObjectValue", { Name = "Test2a2" }),
			[3] = instance.makeInstance("Vector3Value", { Name = "Test2b" }),
		}),
		instance.makeInstance("NumberValue", {
			Name = "Test3",
			{
				[1] = instance.makeInstance("ObjectValue", {
					Name = "Test3a",
					instance.makeInstance("BoolValue"),
					instance.makeInstance("ObjectValue"),
				}),
				[2] = instance.makeInstance("NumberValue", { Name = "Test3a2" }),
				[3] = instance.makeInstance("BoolValue"),
			},
		}),
		instance.makeInstance("ObjectValue"),
	})

	_dummyInstance:Clone().Parent = ReplicatedStorage

	describe("instance.firstChildrenThatIsA", function()
		it("should return the first children that matches the class type", function()
			local result = instance.firstChildrenThatIsA(_dummyInstance, "NumberValue")

			expect(result).to.be.a("userdata")
			expect(result.ClassName).to.be.equal("NumberValue")
			expect(result.Name).to.be.equal("Test2")
		end)
	end)

	describe("instance.firstDescendantThatIsA", function()
		it("should return the first descendant that matches the class type", function()
			local result = instance.firstDescendantThatIsA(_dummyInstance, "BoolValue")

			expect(result).to.be.a("userdata")
			expect(result.ClassName).to.be.equal("BoolValue")
			expect(result.Name).to.be.equal("Value")
		end)
	end)

	describe("instance.childrenThatIsA", function()
		it("should return a table of children that matches the class type", function()
			local result = instance.childrenThatIsA(_dummyInstance, "NumberValue")

			for _, child in result do
				expect(child).to.be.a("userdata")
				expect(child.ClassName).to.be.equal("NumberValue")
			end
			expect(#result).to.be.equal(2)
		end)
	end)

	describe("instance.descendantThatIsA", function()
		it("should return a table of descendants that matches the class type", function()
			local result = instance.descendantThatIsA(_dummyInstance, "ObjectValue")

			for _, descendant in result do
				expect(descendant).to.be.a("userdata")
				expect(descendant.ClassName).to.be.equal("ObjectValue")
			end
			expect(#result).to.be.equal(5)
		end)
	end)

	local _dummyInstanceClone = _dummyInstance:Clone()
	local _dummyInstanceClone2 = _dummyInstance:Clone()

	describe("instance.destroyChildrenThatIsA", function()
		it("should destory all children that matches a class type", function()
			instance.destroyChildrenThatIsA(_dummyInstanceClone.Test3, "NumberValue")

			for _, child in _dummyInstanceClone.Test3:GetChildren() do
				expect(child).to.be.a("userdata")
				expect(child.ClassName).to.be.never.equal("NumberValue")
			end

			expect(#_dummyInstanceClone.Test3:GetChildren()).to.be.equal(2)
		end)
	end)

	describe("instance.destroyDescendantThatIsA", function()
		it("should destory all descendants that matches a class type", function()
			instance.destroyDescendantThatIsA(_dummyInstanceClone2.Test3, "BoolValue")

			for _, child in _dummyInstanceClone2.Test3:GetDescendants() do
				expect(child).to.be.a("userdata")
				expect(child.ClassName).to.be.never.equal("BoolValue")
			end

			expect(#_dummyInstanceClone2.Test3:GetDescendants()).to.be.equal(3)
		end)
	end)
end
