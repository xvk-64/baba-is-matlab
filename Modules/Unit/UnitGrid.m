classdef UnitGrid < handle
    % Handles storing many Units in a grid format

    properties (GetAccess='public', SetAccess='private')
        % Grid of UnitStacks each containing a list of units
        unitStacks

        % Cached array for fast linear access to all UnitStacks
        allStacks

        % The size of the grid
        size
    end
    
    methods
        function this = UnitGrid(size)
            % Class initialiser

            this.size = size;

            this.allStacks = UnitStack.empty;

            % Cell array instead of matrix because somehow a cell array is
            % faster. yes that's right. I don't even know why, I spent several hours trying to
            % optimise this class and I changed this to a cell array and
            % the turn time went from 2 seconds to like half a second I
            % don't even know why I chose to do something this hard in
            % matlab I'm really regretting it right now
            this.unitStacks = cell(size);
        end

        function unitStack = GetStack(this, position)
            % Get a UnitStack at a position

            if (this.IsOutsideGrid(position))
                % If the position is outside the grid, create an empty
                % UnitStack
                unitStack = UnitStack(position, Unit.empty);
                return;
            end

            if (isempty(this.unitStacks{position(1) + 1, position(2) + 1}))
                % If the UnitStack at this position doesn't exist yet,
                % create one

                unitStack = UnitStack(position, Unit.empty);
                this.unitStacks{position(1) + 1, position(2) + 1} = unitStack;

                this.allStacks(end + 1) = unitStack;

                return
            end

            % Return the UnitStack
            unitStack = this.unitStacks{position(1) + 1, position(2) + 1};
        end

        function unitStack = GetStackRelative(this, unitStack, direction)
            % Get the UnitStack in a direction relative to another stack
            unitStack = this.GetStack(unitStack.position + direction.GetVector());
        end

        function isOutside = IsOutsideGrid(this, position)
            % Is the position outside this UnitGrid?
            isOutside = any(position < [0, 0]) || any(position >= this.size);
        end

        function units = GetAllUnits(this)
            % Get all units in the room

            units = Unit.empty;

            % For each UnitStack, add its units to the list
            for stack = this.allStacks
                units(end+1:end+length(stack.units))=stack.units;
            end
        end
    end
end

