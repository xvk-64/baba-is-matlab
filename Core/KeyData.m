classdef KeyData < event.EventData
    % Container for the data involved in a keypress or keyrelease event

    properties
        Key
    end
    
    methods
        function obj = KeyData(key)
            obj.Key = key;
        end
    end
end

