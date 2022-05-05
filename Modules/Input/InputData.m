classdef InputData < event.EventData
    % Class to represent user input

    properties
        % The direction to move
        direction = Direction.Unset

        % Whether a restart was triggered
        restart = false

        skip = false
    end
    
    methods
        function this = InputData(direction)
            % Class initialiser
            
            this.direction = direction;
        end
    end
end

