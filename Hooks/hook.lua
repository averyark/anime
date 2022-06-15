return function (registry)
	registry:RegisterHook("BeforeRun", function(context)
		if context.Group == "DefaultAdmin" and (context.Executor.UserId ~= 540209459) then
			return "You don't have permission to run this command"
		end
	end)
end