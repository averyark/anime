-- finobinos
-- init.lua
-- 16 October 2021

--[[
    TableUtil.DeepCopyTable(tabl : table) --> table
    TableUtil.ShallowCopyTable(tabl : table) --> table
    TableUtil.ReconcileTable(tabl : table, templateTable : table) --> table
    TableUtil.ShuffleTable(tabl : table, randomObject : Random | nil) --> table
    TableUtil.SyncTable(tabl : table, templateSyncTable  : table) --> table 
    TableUtil.IsTableEmpty(tabl : table) --> boolean 
    TableUtil.Map(tabl : table, callback : function) --> table 
	TableUtil.DeepFreezeTable(tabl : table) --> ()
	TableUtil.ConvertTableIndicesToStartFrom(tabl : table, index : number) --> table 
	TableUtil.CombineTables(... : table) --> table 
	TableUtil.ReverseTable(tabl : table) --> table 
	TableUtil.GetCount(tabl : table) --> number []
	TableUtil.AreTablesSame(tabl : table, otherTabl : table) --> boolean 
	TableUtil.EmptyTable(tabl : table) --> ()
]]

--[=[
	@class TableUtil
	A utility designed to provide a layer of abstraction along with useful methods when working with tables.

	A common use case would be to compare 2 tables via their elements, for e.g:

	```lua
	local t1 = {1, 2, 3}
	local t2 = {1, 2, 3}
	local t3 = {1, 2}

	print(TableUtil.IsTableEqualTo(t1, t2)) --> true
	print(TableUtil.IsTableEqualTo(t1, t3)) --> false
	```
]=]

local TableUtil = {}

local LocalConstants = {
	ErrorMessages = {
		InvalidArgument = "Invalid argument#%d to %s: expected %s, got %s",
	},
}

--[=[
	@param tabl table
	@return table

	Freezes `tabl` via `table.freeze`, and all other nested tables in `tabl`.

	:::tip
	This method accounts for cyclic tables.
	:::
]=]

function TableUtil.DeepFreezeTable(tabl)
	assert(
		typeof(tabl) == "table",
		LocalConstants.ErrorMessages.InvalidArgument:format(1, "TableUtil.DeepFreezeTable()", "table", typeof(tabl))
	)

	table.freeze(tabl)

	for key, value in pairs(tabl) do
		if typeof(value) == "table" and not table.isfrozen(value) then
			TableUtil.DeepFreezeTable(value)
		end

		if typeof(key) == "table" and not table.isfrozen(key) then
			TableUtil.DeepFreezeTable(key)
		end
	end
end

--[=[
	@param tabl table
	@return table

	Unfreezes `tabl` via `table.unfreeze`, and all other nested tables in `tabl`.

	:::tip
	This method accounts for cyclic tables.
	:::
]=]

function TableUtil.DeepCopyTable(tabl, _cache)
	assert(
		typeof(tabl) == "table",
		LocalConstants.ErrorMessages.InvalidArgument:format(1, "TableUtil.DeepCopyTable()", "table", typeof(tabl))
	)

	-- Keep a internal cache so we can account for cyclic tables by checking if they were already processed:
	_cache = _cache or {}
	if _cache[tabl] then
		return
	end
	_cache[tabl] = true

	local deepCopiedTable = {}

	for key, value in pairs(tabl) do
		if typeof(value) == "table" then
			deepCopiedTable[key] = TableUtil.DeepCopyTable(value, _cache)
			continue
		end

		deepCopiedTable[key] = value
	end

	return deepCopiedTable
end

--[=[
	@param tabl table
	@return table

	Shallow copies all elements in `tabl` to a new table, i.e only the "children" of `tabl` are considered
	and not their descendants.

	```lua
	local t1 = {
		1,
		2,
		3,
		{
			a = {}
		}
	}

	print(TableUtil.ShallowCopyTable(t1))
	```
]=]

function TableUtil.ShallowCopyTable(tabl)
	assert(
		typeof(tabl) == "table",
		LocalConstants.ErrorMessages.InvalidArgument:format(1, "TableUtil.ShallowCopyTable()", "table", typeof(tabl))
	)

	local copiedTable = {}

	for key, value in pairs(tabl) do
		copiedTable[key] = value
	end

	return copiedTable
end

--[=[
	@param tabl table
	@param templateTable table
	@return table

	Adds all missing elements from `templateTable` to `tabl`, and also sets the metatable of `tabl` to `templateTable`. Returns `tabl`.

	```lua
	local t1 = {}
	local templateTable = {1, 2, 3}

	TableUtil.ReconcileTable(t1, templateTable)
	print(t1) --> {1, 2, 3}
	```
]=]

function TableUtil.ReconcileTable(tabl, templateTable, _cache)
	assert(
		typeof(tabl) == "table",
		LocalConstants.ErrorMessages.InvalidArgument:format(1, "TableUtil.ReconcileTable()", "table", typeof(tabl))
	)

	assert(
		typeof(templateTable) == "table",
		LocalConstants.ErrorMessages.InvalidArgument:format(
			2,
			"TableUtil.ReconcileTable()",
			"table",
			typeof(templateTable)
		)
	)

	-- Keep a internal cache so we can account for cyclic tables by checking if they were already processed:
	_cache = _cache or {}
	if _cache[tabl] then
		return
	end
	_cache[tabl] = true

	for key, value in pairs(templateTable) do
		if not tabl[key] then
			if typeof(value) == "table" then
				tabl[key] = TableUtil.DeepCopyTable(value, _cache)
			else
				tabl[key] = value
			end
		end
	end

	return tabl
end

--[=[
	@param tabl table
	@param randomObject Random | nil
	@return table

	Shuffles `tabl` such that the indices will have values of other indices in `tabl` in a random way. If `randomObject` is specified,
	it will be used instead to shuffle `tabl`. Returns `tabl`.

	:::note
	This method assumes that `tabl` is an array with no holes.
	:::

	```lua
	local t1 = {1, 2, 3, 4, 5}

	local shuffledTable = TableUtil.ShuffleTable(t1)
	print(shuffledTable) --> {3, 2, 4, 5, 1, 6}
	```
]=]

function TableUtil.ShuffleTable(tabl, randomObject)
	assert(
		typeof(tabl) == "table",
		LocalConstants.ErrorMessages.InvalidArgument:format(1, "TableUtil.ShuffleTable()", "table", typeof(tabl))
	)

	if randomObject then
		assert(
			typeof(randomObject) == "Random",
			LocalConstants.ErrorMessages.InvalidArgument:format(
				2,
				"TableUtil.ShuffleTable()",
				"Random or nil",
				typeof(randomObject)
			)
		)
	end

	local random = randomObject or Random.new()

	for index = #tabl, 2, -1 do
		local randomIndex = random:NextInteger(1, index)
		-- Set the value of the current index to a value of a random index in the table, and set the value of the
		-- random index to the current value:
		tabl[index], tabl[randomIndex] = tabl[randomIndex], tabl[index]
	end

	return tabl
end

--[=[
	@param tabl table
	@return boolean
	@return table

	Returns a boolean indicating if `tabl` is empty i.e it is basically `{}`. For arrays with no holes, the `#` operator should be 
	used instead.
]=]

function TableUtil.IsTableEmpty(tabl)
	assert(
		typeof(tabl) == "table",
		LocalConstants.ErrorMessages.InvalidArgument:format(1, "TableUtil.IsTableEmpty()", "table", typeof(tabl))
	)

	return not next(tabl)
end

--[=[
	@param tabl table
	@param templateSyncTable table
	@return table

	Syncs `tabl` to `templateSyncTable` such that `tabl` will have exactly the same keys and values that are in
	`templateSyncTable`. Returns `tabl`.

	```lua
		local t = {a = 5, b = {}}
		local templateT = {a = {}, b = 5}

		TableUtil.SyncTable(t, templateT)
		print(t) --> {a = {}, b = 5}
	```

	:::tip
	This method accounts for cyclic tables.
	:::
]=]

function TableUtil.SyncTable(tabl, templateSyncTable, _cache)
	assert(
		typeof(tabl) == "table",
		LocalConstants.ErrorMessages.InvalidArgument:format(1, "TableUtil.SyncTable()", "table", typeof(tabl))
	)

	assert(
		typeof(templateSyncTable) == "table",
		LocalConstants.ErrorMessages.InvalidArgument:format(
			2,
			"TableUtil.SyncTable()",
			"table",
			typeof(templateSyncTable)
		)
	)

	-- Keep a internal cache so we can account for cyclic tables by checking if they were already processed:
	_cache = _cache or {}
	if _cache[tabl] then
		return
	end
	_cache[tabl] = true

	for key, value in pairs(tabl) do
		local templateValue = templateSyncTable[key]

		if not templateValue then
			tabl[key] = nil
		elseif typeof(value) ~= typeof(templateValue) or value ~= templateValue then
			if typeof(templateValue) == "table" then
				tabl[key] = TableUtil.DeepCopyTable(templateValue)
			else
				tabl[key] = templateValue
			end
		elseif typeof(value) == "table" then
			tabl[key] = TableUtil.SyncTable(value, templateValue, _cache)
		end
	end

	for key, templateValue in pairs(templateSyncTable) do
		local value = tabl[key]

		if not value then
			if typeof(templateValue) == "table" then
				tabl[key] = TableUtil.DeepCopyTable(templateValue)
			else
				tabl[key] = templateValue
			end
		end
	end

	return tabl
end

--[=[
	@param tabl table
	@param callback function
	@return table

	Performs a map against `tabl`, which can be used to map new values based on the old values at given indices. Returns `tabl`.

	```lua
	local t = {1, 2, 3, 4, 5}
	local t2 = TableUtil.Map(t, function(key, value)
		return value * 2
	end)
	print(t2) --> {2, 4, 6, 8, 10}
	```
]=]

function TableUtil.Map(tabl, callback)
	assert(
		typeof(tabl) == "table",
		LocalConstants.ErrorMessages.InvalidArgument:format(1, "TableUtil.Map()", "table", typeof(tabl))
	)

	assert(
		typeof(callback) == "function",
		LocalConstants.ErrorMessages.InvalidArgument:format(2, "TableUtil.Map()", "function", typeof(callback))
	)

	for key, value in pairs(tabl) do
		tabl[key] = callback(key, value, tabl)
	end

	return tabl
end

--[=[
	@param tabl table
	@param index number
	@return table

	A method which maps all numerical indices of the values in `tabl` to start from `index`. This method also accounts
	for nested tables. Returns `tabl`.

	```lua
	local t = {1, 2, 3, 4, 5}
	TableUtil.ConvertTableIndicesToStartFrom(t, 0)
	print(t[0], t[1], t[2], t[3]) --> 1, 2, 3, 4
	```

	:::tip
	This method accounts for cyclic tables.
	:::
]=]

function TableUtil.ConvertTableIndicesToStartFrom(tabl, index, _cache)
	local newTable = {}
	local currentIndex = index - 1

	-- Keep a internal cache so we can account for cyclic tables by checking if they were already processed:
	_cache = _cache or {}
	if _cache[tabl] then
		return
	end

	_cache[tabl] = true

	for key, value in pairs(tabl) do
		if typeof(key) == "table" then
			key = TableUtil.ConvertTableIndicesToStartFrom(key, index, _cache)
			tabl[key] = value
		end

		if typeof(value) == "table" then
			tabl[key] = TableUtil.ConvertTableIndicesToStartFrom(value, index, _cache)
		end

		if typeof(key) ~= "number" then
			newTable[key] = tabl[key]
			continue
		end

		currentIndex += 1
		newTable[currentIndex] = value
	end

	-- Clear out all the keys:
	for key, _ in pairs(tabl) do
		tabl[key] = nil
	end

	-- Now rearrange them:
	for key, value in pairs(newTable) do
		tabl[key] = value
	end

	return tabl
end

--[=[
	@param ... table
	@return table

	A method which combines all tables `...` into 1 single mega table.

	```lua
	local t = {1, 2, 3, 4, 5}
	local t1 = {7, 8, 9}
	local t2 = {10, 11, 12}

	local combinedTable = TableUtil.CombineTables(t, t1, t2)
	print(combinedTable) --> {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
	```
]=]

function TableUtil.CombineTables(...)
	local combinedTable = {}

	for _, tabl in pairs({ ... }) do
		for key, value in pairs(tabl) do
			if typeof(key) == "number" then
				table.insert(combinedTable, value)
			else
				combinedTable[key] = value
			end
		end
	end

	return combinedTable
end

--[=[
	@param tabl table

	Clears out all keys in `tabl`.

	```lua
	local t = {1, 2, 3, 4, 5}
	TableUtil.EmptyTable(t)
	print(t) --> {}
	```
]=]

function TableUtil.EmptyTable(tabl)
	assert(
		typeof(tabl) == "table",
		LocalConstants.ErrorMessages.InvalidArgument:format(1, "TableUtil.EmptyTable()", "table", typeof(tabl))
	)

	for key, _ in pairs(tabl) do
		tabl[key] = nil
	end
end

--[=[
	@param tabl table
	@return table

	A method which reverses `tabl`. Returns `tabl`.

	:::note
	This method assumes that `tabl` is an array with no holes.
	:::

	```lua
	local t = {1, 2, 3, 4, 5}
	TableUtil.ReverseTable(t)
	print(t) --> {5, 4, 3, 2, 2, 1}
	```
]=]

function TableUtil.ReverseTable(tabl)
	assert(
		typeof(tabl) == "table",
		LocalConstants.ErrorMessages.InvalidArgument:format(1, "TableUtil.ReverseTable()", "table", typeof(tabl))
	)

	for index = 1, #tabl / 2 do
		tabl[#tabl - index + 1], tabl[index] = tabl[index], tabl[#tabl - index + 1]
	end
end

--[=[
	@param tabl table
	@return number

	A method which returns a number of all the elements in `tabl`.

	```lua
	local t = {1, 2, 3, 4, 5, a = 5, b = 6}
	print(TableUtil.GetCount(t)) --> 7
	```
]=]

function TableUtil.GetCount(tabl)
	assert(
		typeof(tabl) == "table",
		LocalConstants.ErrorMessages.InvalidArgument:format(1, "TableUtil.GetCount()", "table", typeof(tabl))
	)

	local count = 0

	for _, _ in pairs(tabl) do
		count += 1
	end

	return count
end

--[=[
	@param tabl table
	@param value any
	@return any 

	A method which returns the key in which `value` is stored at in `tabl`.

	```lua
	local t = {a = 5, b = 10}
	print(TableUtil.GetKeyFromValue(t, 5)) --> "a"
	```

	:::note
	This method will not work well for different keys which have the same value, and doesn't account for nested values.
	:::
]=]

function TableUtil.GetKeyFromValue(tabl, value)
	assert(
		typeof(tabl) == "table",
		LocalConstants.ErrorMessages.InvalidArgument:format(1, "TableUtil.GetKeyFromValue()", "table", typeof(tabl))
	)

	for key, tableValue in pairs(tabl) do
		if value == tableValue then
			return key
		end
	end

	return nil
end

--[=[
	@param tabl table
	@param otherTable table
	@return boolean

	A method which checks if both `tabl` and `otherTable` are exactly equal. Also accounts for nested values.

	```lua
	local t1 = {1, 2, 3, 4, 5, {a = 4}}
	local t2 = {1, 2, 3, 4, 5, {a = 3}}

	print(TableUtil.AreTablesSame(t1, t2)) --> false
	```

	```lua
	local t1 = {1, 2, 3, 4, 5, {a = 4}}
	local t2 = {1, 2, 3, 4, 5, {a = 4}}

	print(TableUtil.AreTablesSame(t1, t2)) --> true
	```

	:::tip
	This method accounts for cyclic tables, and is handles a lot of edge cases.
	:::
]=]

function TableUtil.AreTablesSame(tabl, otherTable, _cache)
	assert(
		typeof(tabl) == "table",
		LocalConstants.ErrorMessages.InvalidArgument:format(1, "TableUtil.AreTablesSame()", "table", typeof(tabl))
	)
	assert(
		typeof(otherTable) == "table",
		LocalConstants.ErrorMessages.InvalidArgument:format(2, "TableUtil.AreTablesSame()", "table", typeof(otherTable))
	)

	-- Handle edge case of both tables being empty, in that case, we'll return true because there would be
	-- nothing to check for or if the tables are same:
	if TableUtil.IsTableEmpty(tabl) and TableUtil.IsTableEmpty(otherTable) or tabl == otherTable then
		return true
	end

	-- Keep a internal cache so we can account for cyclic tables by checking if they were already processed:
	_cache = _cache or {}

	if _cache[tabl] then
		return false
	end

	_cache[tabl] = true

	for key, value in pairs(tabl) do
		local otherValue = otherTable[key]

		if typeof(value) == "table" and typeof(otherValue) == "table" then
			if not TableUtil.AreTablesSame(value, otherValue, _cache) then
				return false
			end

			continue
		end

		if otherValue ~= value then
			return false
		end
	end

	return true
end

return TableUtil
