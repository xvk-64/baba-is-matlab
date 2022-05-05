classdef Unit < handle
    % Represents a Unit, an object in the game

    properties (GetAccess='public', SetAccess='private')
        % The current position and directoin of the unit
        unitState

        % For debugging
        EDITOR_name
    end

    methods
        function pos = position(obj)
            pos = obj.unitState.position;
        end

        function unitDef = unitDef(obj)
            unitDef = obj.unitState.unitDef;
        end

        function dir = direction(obj)
            dir = obj.unitState.direction;
        end
    end

    properties
        screenPos
        actions
        moveRequest
        colour
        turnsMoved
        baseTileIndex
    end
    
    methods
        function this = Unit(unitState)
            % Class initialiser

            this.unitState = unitState;
            % Screen position is 24 times position, since each tile is 24
            % pixels
            this.screenPos = unitState.position * 24;
            this.actions = noun_noundefault.empty;
            this.moveRequest = Direction.Unset;
            this.colour = unitState.unitDef.colour;
            this.turnsMoved = 0;
            this.baseTileIndex = unitState.unitDef.tileStartIndex;

            this.EDITOR_name = unitState.unitDef.name;
        end

        function SetPosition(this, position)
            % Set the position of this unit
            this.unitState.position = position;
        end

        function SetDirection(this, direction)
            % Set the direction of this unit
            this.unitState.direction = direction;
        end

        function Transform(this, newUnitDef)
            % Transform this unit into a different one
            if (this.unitState.unitDef ~= newUnitDef)
                this.unitState.unitDef = newUnitDef;
                this.EDITOR_name = newUnitDef.name;
                this.colour = newUnitDef.colour;
                this.baseTileIndex = newUnitDef.tileStartIndex;
            end
        end
    end
end

