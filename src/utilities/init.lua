--!strict
-- utilities.init
-- Arkizen
-- 19/05/2022

-- Ignore the Um object, and don't use it for production pls ~ark

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local cacheUtilitiesModules = {}
local cacheUtilitiesMethods = {}
local cacheUtilitiesLib = {}

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local t = require(ReplicatedStorage.Packages.t)
local TestEZ = require(ReplicatedStorage.Packages.TestEZ)

-- types
local isFolder = t.instanceIsA("Folder")
local isModule = t.instanceIsA("ModuleScript")
local isFunction = t.typeof("function")

local utilWarn = function(...: string | number)
	warn("utilWarn:", ..., debug.traceback("\n\n", 2))
end

local isSpecFile = function(module: ModuleScript)
	assert(isModule(module), "utilError: expected module\n")
	return module.Name:match("(.+)%.spec$")
end

local isTypeFile = function(module: ModuleScript)
	assert(isModule(module), "utilError: expected module\n")
	return module.Name:match("(.+)%.type$")
end

local isSpecialFile = function(module: ModuleScript)
	assert(isModule(module), "utilError: expected module\n")
	return isTypeFile(module) or isSpecFile(module)
end

local run = function()
	for _, module in script:GetChildren() do
		if isModule(module) and not isSpecialFile(module) then
			cacheUtilitiesMethods[module.Name] = module
			local expand = require(module)
			cacheUtilitiesLib[module.Name] = expand
			for key, value in expand do
				if cacheUtilitiesMethods[key] then
					--utilWarn("Method shadowing;", key, module.Name)
					continue
				end
				if not isFunction(value) then
					continue
				end
				cacheUtilitiesMethods[key] = value
			end
		end
	end
end

run()

--[[
    WARNING: BELOW IS MESSING WITH METATABLES AND IS NOT RECOMMENDED TO USE IN PRODUCTION
        Please just use the classical method
        ```lua
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local utilities = require(ReplicatedStorage.utilities)

        utilities.libraryName.methodName(arguments)
        ```
    Or alternatively, you can use partial implicit parenthesis (this sacrifices performance if used on a mass scale)
        ```lua
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local utilities = require(ReplicatedStorage.utilities)

        utilities "libraryName" "methodName" (arguments)
        ```
--]]

--[[

utilities.tween.instance(
    utilities.instance.new("Part", {
        Parent = workspace,
        Anchored = true,
        Position = Vector3.new(0, 0, 0)
    }),
    {
        Position = Vector3.new(5, 5, 5)
    },
    2,
    "StandardExpressive"
)
utilities.um.new(utilities.instance.new, "Part", {
    Parent = workspace,
    Anchored = true,
    Position = Vector3.new(0, -1, 0)
}):andThen(function(context)
    utilities.tween.instance(context, {
        Position = Vector3.new(0, 10, 0)
    }, 3, "Sine")
end):printFirst()

]]

--[[
    @params inputTable : {any}, exclusionN : number
    @returns table

    Returns a the table only with indicies starting from the provided number.
    Excludes all indicies before the provided number
    ```lua

    ```
]]
local exclude = function(inputTable: { any }, exclusionN: number)
	for i = 1, exclusionN do
		table.remove(inputTable, 1)
	end
	return inputTable
end

--[[
    @params inputTable : {any}, exclusionN : number
    @returns table

    Returns a new table with indicies starting from the provided number.
    Excludes all indicies before the provided number
    ```lua

    ```
]]
local excluding = function(inputTable: { any }, exclusionN: number)
	inputTable = table.clone(inputTable)
	for i = 1, exclusionN do
		table.remove(inputTable, 1)
	end
	return inputTable
end

local um = {}

--[[
    @params method : (...any) -> (...any), ...: any
    @returns self
    @chainable true

    Creates a new um object and executes the passed method immediatelly.
    This object has some similarities with Roblox Promise by evaera, I recommend you use that instead.
    The object is designed exclusively and scoped for this utility module.
    ```lua
    um.new(function()
        -- do something
    end):delay(5):andThen(function(context)
        
    end)
    ```
    ```lua
    um:yield()
    um:returnNow()
    um:returnNowWithDelay(number)
    um:cancel()
    um:delay(number)
    um:andThen(callback)
    um:destroy()
    ```
]]
function um.new(method: (...any) -> (...any), ...: { __firstResults: { any } } | any) --: um
	local __params = { ... }
	local __isInitial = if typeof((__params)[1]) == "table" and (__params)[1]._firstResults then false else true
	local self = setmetatable({
		_params = not __isInitial and excluding(__params, 1) or __params,
		_returns = {}, -- awaiting for completion of thread execution, responses from the following thread are not passed
		_status = "none",

		_firstResults = not __isInitial and (__params)[1]._firstResults or nil,
	}, {
		__index = um, -- using um
		__call = function(__self, __method: string) -- implicit parentheses execution
			local useMethod = um[__method]
			assert(useMethod, "methodName error " .. tostring(__method)) -- method does not exist under the library?

			return function(...: any)
				return useMethod(__self, ...)
			end
		end,
	})
	task.spawn(function()
		self._thread = self:__run(method, unpack(self._params))
	end)
	return self
end

--[[
    @return ...any
    @chainable false

    Returns the thread response instantaneously, returns nil if the thread has not yet finished running.
    Use um:yield() to always expect a response.
    ```lua
    local u = um.new(method)
    local key, value = u:returnNow()

    print(key, value)
    ```
--]]
function um:returnNow(): ...any
	return unpack(self._returns)
end

--[[
    @return ...any
    @chainable false
    
    Yields the thread response when it finished running.
    Use um:returnNow() to yield response immediately (no waiting).
    ```lua
    local u = um.new(method)
    local key, value = u:yield()

    print(key, value)
    ```
--]]
function um:yield(): ...any
	if self._status == "completed" then
		return unpack(self._returns)
	end
	if not self._yield then
		self._yield = coroutine.running()
	end
	return coroutine.yield()
end

--[[
    @return ...any | nil
    @chainable false
    @aliases yieldInitial
    
    Yields the results returned by the initial thread.
    Results are not captured if a new um is wrapped prior to the completion of the initial thread's execution.
    This faulty behaviour will cause the ancestry tree to break.
    Make sure to use :wait() before using any methods that creates a new um thread.

    NOTE: This function will return nil if used on an initial thread that has is still running.
    ```lua
    local method = function()
        return "Key", "Value";
    end)
    local u = um.new(
        um.new(method) -- this is considered the initial thread
    ) -- using yieldFirst on this will yield the response from the initial thread instead of the current thread
    local key, value = u:yieldFirst()

    print(key, value) -- "Key", "Value"
    ```
--]]
function um:yieldFirst(n: number?): ...any | nil
	return if t.number(n) then self._firstResults[n] else unpack(self._firstResults)
end

um.yieldInitial = um.yieldFirst

--[[
    @return self
    @chainable true

    Prevents the thread from proceeding until the response is fetched from the method
    ```lua
    local u = um.new(method)
    u:wait():print()
    ```
]]
function um:wait(): um
	self:yield()
	return self
end

--[[
    @return self
    @chainable true

    Calls the provided callback function with the response as it's arguments when the thread has finished running.
    Returned data are passed as results.
    Returns itself for chaining.
    ```lua
    local u = um.new(method)
    u:andThen(function()
        print(key, value)
        return 1;
    end):andThen(function(n)
        print(n) -- prints 1
        return n + 1;
    end):andThen(function(n)
        print(n) -- prints 2
        return n + 1
    end)
    ```
--]]
function um:andThen(callback: (...any) -> ()) --: um
	print(self)
	return um.new(function()
		return callback(self:yield())
	end, self)
end

--[[
    @params n : number
    @return self
    @chainable true

    Yields the thread for n seconds.
    ```lua
    local u = um.new(method)
    u:delay(3):andThen(function(context)
        utilities.instance.new("Part", {Parent = workspace})
    end)
    ```
]]
function um:delay(n: number): um
	assert(t.number(n), "delay: expected number")
	task.wait(n)
	return self
end

--[[
    @params n : number
    @returns ...any
    @chainable false

    Immediately return the possible results after a defined delay.
    Warning: Returns nothing if the thread is still running after the scoped delay interval.
    Sugar for self:delay(n):returnNow()
    ```lua
    local u = um.new(method)
    local key, value = u:returnNowWithDelay(3)

    print(key, value)
    ```
]]
function um:returnNowWithDelay(n: number): ...any
	return self:delay(n):returnNow()
end

--[[
    @returns ...any
    @chainable true

    Print the response from the thread immediately when the function is called
    ```lua
    local u = um.new(method)
    u:print()
    ```
]]
function um:print(): um
	local arrayOfResponse = { self:returnNow() }
	print("--------------------UM-PRINT--------------------")
	print("Manifesting responses < " .. tostring(self) .. " >")
	for i, response in arrayOfResponse do
		print(i .. " | " .. "(" .. typeof(response) .. ")<", response, ">")
	end
	print("------------------------------------------------")
	return self
end

--[[
    @returns ...any
    @chainable true
    @aliases promisePrint waitPrint

    Print the response from the thread when it is completed, guaranteeing valid reponse from the thread.
    Sugar for um:wait():print()
    ```lua
    local u = um.new(method)
    u:yieldPrint()
    ```
]]
function um:yieldPrint(): um
	return self:wait():print()
end

function um:printFirst(): um
	local arrayOfResponse = { self:yieldFirst() }
	print("--------------------UM-PRINT--------------------")
	print("Manifesting responses < " .. tostring(self) .. " >")
	for i, response in arrayOfResponse do
		print(i .. " | " .. "(" .. typeof(response) .. ")<", response, ">")
	end
	print("------------------------------------------------")
	return self
end

um.waitPrint = um.yieldPrint
um.promisePrint = um.yieldPrint

--[[
    @returns
    @chainable false

    Cancels the thread and puts it in a dead state, prevents further resuming and return void.
    Cancellng does not remove references and stored value internally. Use um:destroy() to clean entirely.
    Note: You cannot resume a dead thread.
    ```lua
    local u = um.new(method)
    u:cancel()
    print(u._status) -- "cancelled" -- this demonstrates that you can still access the values after cancelling, otherwise with destroy
    ```
]]
function um:cancel()
	coroutine.close(self._thread)
	self._status = "cancelled"
end

--[[
    @returns nil
    @chainable false
    @aliases Destroy remove Remove

    Cancels running thread and removing references internally.
    ```lua
    local u = um.new(method)
    u:destroy()
    print(u._status) -- "cancelled" -- this demonstrates that you can still access the values after cancelling, otherwise with destroy
    ```
]]
function um:destroy(): nil
	self:cancel()
	for k in pairs(self) do
		self[k] = nil
	end
	return nil
end

um.Destroy = um.destroy
um.remove = um.destroy
um.Remove = um.destroy

function um:__run(f: (...any) -> (...any), ...: any)
	local contained = { ... }
	return task.spawn(function()
		self._status = "running"
		local results = { f(unpack(contained)) }
		self._returns = results
		self._status = "completed"
		if not self._firstResults then
			self._firstResults = results
		end
		if self._yield then
			task.spawn(self._yield, unpack(results))
		end
	end)
end

local captureReturnType = function<ret...>(f: (...any) -> ret...): ret...
	error("not callable")
end
local lf = function<a, b>(_cb: (a) -> b): a
	error("not callable")
end

export type um = typeof(um.new(function() end))
export type builtin_utils = "instance" | "tween" | "string"
type instanceTypes = typeof(require(script.instance))
type tweenTypes = typeof(require(script.tween))
type stringTypes = typeof(require(script.string))
type numberTypes = typeof(require(script.number))

type utilities =
	(({ any: any }, "instance") -> (instanceTypes))
	& (({ any: any }, "tween") -> (tweenTypes))
	& (({ any: any }, "string") -> (stringTypes))
	& (({ any: any }, "number") -> (numberTypes))

return setmetatable({
	__utilitiesMethods = cacheUtilitiesMethods,
	__utilitiesFolder = cacheUtilitiesModules,
	__utilitiesLib = cacheUtilitiesLib,
	__testModeEnabled = RunService:IsStudio() and true or false,
}, {
	__index = {
		instance = require(script.instance),
		tween = require(script.tween),
		string = require(script.string),
		number = require(script.number),
		getRaw = function(mt)
			return mt
		end,
		getProperty = function(mt, key)
			return mt[key]
		end,
		um = um,
	},
	__newindex = function(mt, key, value)
		if key == "test" then
			if value then
				utilWarn("TestMode is enabled")
				TestEZ.TestBootstrap:run({
					ReplicatedStorage.utilities,
				})
			elseif not value then
				utilWarn("TestMode is disabled")
			end
			rawset(mt, "__testModeEnabled", value)
		else
			rawset(mt, key, value)
		end
	end,
	__tostring = function(mt)
		return ("<utilities>(#%s)"):format(tostring(mt.__testModeEnabled))
	end,
	__call = function(mt, libraryName: builtin_utils | string) -- no longer supported
		local uLib = mt:getProperty("__utilitiesLib")
		local utility = uLib[libraryName]

		if not utility then
			return utilWarn(("Invalid utility name (%s)"):format(libraryName))
		end

		return function(methodName: string)
			local method = utility[methodName]
			if not method then
				return utilWarn(("Invalid method name (%s)"):format(methodName))
			end
			return function(...: any)
				return um.new(method, ...) --method(...);
			end
		end
	end,
})
