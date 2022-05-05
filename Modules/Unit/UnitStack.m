classdef UnitStack < handle
    % Class to represent a "stack" of Units - a group of Units that occupy
    % the same position

    properties (GetAccess='public', SetAccess='private')
        % The position of this UnitStack
        position
        
        % The list of units in this stack
        units
    end

    methods
        function isEmpty = isEmpty(this)
            % Is this UnitStack empty?
            isEmpty = isempty(this.units);
        end
    end
    
    methods
        function this = UnitStack(position, units)
            % Class Initialiser

            this.position = position;
            this.units = units;
        end

        function Add(this, units)
            % Add units to this UnitStack

            for i=1:length(units)
                this.units(end+1)=units(i);
            end
        end

        function Remove(this, units)
            % Remove units from this UnitStack
            this.units = setdiff(this.units, units);
        end
    end
end

