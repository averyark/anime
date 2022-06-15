local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "setUtilEnv";
	Aliases = {"sue"};
	Description = "Modifies a variable in the utilities environment.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "string $ interger";
			Name = "key";
			Description = "variable key";
		},
		{
			Type = "string # boolean & color3 $ interger @ player ! vector3";
			Name = "value";
			Description = "variable value to modify to"
		},
		{
			Type = "number";
			Name = "state";
			Description = "0 to apply to server and client, 1 to apply to server only, and 2 to apply to client only"
		}
	};
	ClientRun = function (context, key, value, state)
		local utilities = require(ReplicatedStorage.utilities)
    
		if state == 0 or state == 2 then
			utilities[key] = value
		end
		if state == 2 then
			return ("client: Util variable %s changed to %s."):format(key, tostring(value));
		elseif state == 0 then
			context:Reply(("client: Util variable %s changed to %s."):format(key, tostring(value)))
		end
	end
}