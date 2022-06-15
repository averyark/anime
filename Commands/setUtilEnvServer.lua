local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function (context, key, value, state)
    local utilities = require(ReplicatedStorage.utilities)
    
    if state == 0 or state == 1 then
        utilities[key] = value
        return ("server: Util variable %s changed to %s."):format(tostring(key), tostring(value))
    end
end
