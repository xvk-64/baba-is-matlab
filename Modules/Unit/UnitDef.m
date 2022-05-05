classdef UnitDef < handle & matlab.mixin.Copyable
    % Defines the properties of a Unit

    properties
        name
        tileStartIndex
        tilingType
        colour
    end
    
    methods
        function obj = UnitDef(name, tileStartIndex, tilingType, colour)
            % Class initialiser

            obj.name = name;
            obj.tileStartIndex = tileStartIndex;
            obj.tilingType = tilingType;
            obj.colour = colour;
        end

        function isText = isText(obj)
            % Is this unit text? (no)
            
            isText = false;
        end
    end
end

