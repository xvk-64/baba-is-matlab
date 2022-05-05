classdef UnitState
    % Defines the state of a Unit at any one time

    properties
        unitDef
        position
        direction
    end

    methods
        function obj = UnitState(unitDef, position, direction)
            % Class initialiser
            
            obj.unitDef = unitDef;
            obj.position = position;
            obj.direction = direction;
        end
    end
end

