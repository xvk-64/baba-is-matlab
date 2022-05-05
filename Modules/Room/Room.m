classdef Room < handle
    % Represents a room in the current level being played

    properties (GetAccess='public', SetAccess='private')
        % The grit of all units in the room
        unitGrid

        % The latest input direction
        latestInput

        % How many turns have passed
        currentTurn

    end

    methods
        function size = size(this)
            % Get the size of the unitGrid
            size = this.unitGrid.size;
        end
    end

    properties (Constant)
        % How fast do units smoothly move between squares
        UnitMoveSpeed = 20
        % What is the maximum fraction the units can move each frame?
        UnitMaxMoveFraction = 0.5
    end

    events
        % Triggered when exiting a level
        ExitLevel
    end
    
    methods
        function this = Room(size)
            % Class Initialiser

            this.unitGrid = UnitGrid(size);
            this.latestInput = Direction.Unset;
            this.currentTurn = 0;
        end

        function Update(this, deltaTime)
            % Called every frame

            % Update each unit individually
            for unit = this.unitGrid.GetAllUnits()                
                % Smooth move units to new position
                unit.screenPos = unit.screenPos + (unit.position * 24 - unit.screenPos)...
                    * max(0, min(Room.UnitMoveSpeed * deltaTime, Room.UnitMaxMoveFraction));
            end
        end

        function NextTurn(this, direction)
            % Called whenever the game advances a turn (Player gave new
            % input)

            this.latestInput = direction;
            this.currentTurn = this.currentTurn + 1;

            % Reset all unit colours
            for unit=this.unitGrid.GetAllUnits()
                unit.colour = unit.unitState.unitDef.colour;
            end
        end

        function UpdateUnitAnimations(this)
            % Update the animations of all units in the room

            for unit = this.unitGrid.GetAllUnits()
                unit.baseTileIndex = UnitAnimator.GetBaseIndex(unit, this);
            end
        end

        function unit = CreateUnitFromName(this, unitName, unitPos, unitDir)
            % Create a new unit from its name

            % Get the unitDef and create a unitState
            unitDef = Game.unitDefManager.GetUnitDef(unitName);
            unitState = UnitState(unitDef, unitPos, unitDir);

            % Create the unit
            unit = this.CreateUnit(unitState);
        end

        function unit = CreateUnit(this, unitState)
            % Create a Unit from a UnitState

            unit = Unit(unitState);

            this.AddUnit(unit);
        end

        function AddUnit(this, unit)
            % Add an existing unit to the right UnitStack

            this.unitGrid.GetStack(unit.position).Add(unit);
        end

        function DestroyUnit(this, unit)
            % Destroy a unit

            this.unitGrid.GetStack(unit.position).Remove(unit);
        end
        
        function MoveUnitTo(this, unit, destination)
            % Moves a Unit to a destination

            % Remove from stack
            this.unitGrid.GetStack(unit.position).Remove(unit);

            % Update position
            unit.SetPosition(destination);
            unit.turnsMoved = unit.turnsMoved + 1;

            % Re-add unit
            this.AddUnit(unit);
        end

        function MoveUnitStack(this, unitStack, direction)
            % Moves a UnitStack, all units in the stack should have the
            % same position

            if (direction == Direction.Unset || isempty(unitStack) || isempty(unitStack.units))
                % Don't need to do anything
                return;
            end

            destination = unitStack.position + direction.GetVector();

            % Get the UnitStack at the destination
            destinationStack = this.unitGrid.GetStack(destination);

            % Push all pushable units in the destination
            pushQuery = UnitQuery().WithActions(QueryMode.WithAll, ["is", "push"]);
            pushUnits = pushQuery.QueryAll(destinationStack.units);
            pushStack = UnitStack(destination, pushUnits);
            this.MoveUnitStack(pushStack, direction);

            % Move the units
            units = unitStack.units;
            for unit=units
                unit.SetDirection(direction);
                this.MoveUnitTo(unit, destination);
            end
        end

        function canMove = CanMoveUnit(this, unit, direction)
            % Checks whether the unit can move in the direction

            canMove = true;

            if (direction == Direction.Unset)
                return;
            end

            destination = unit.position + direction.GetVector();

            if (this.unitGrid.IsOutsideGrid(destination))
                % Units cannot move outside the level
                canMove = false;
                return;
            end

            destinationStack = this.unitGrid.GetStack(destination);

            % Check if there are any solid objects that are not pushable in
            % the way
            pushQuery = UnitQuery().WithActions(QueryMode.WithAll, ["is", "push"]);
            solidWithoutPushQuery = UnitQuery()...
                .WithActions(QueryMode.WithNone, ["is", "push"])...
                .WithQualityTags(QueryMode.WithAll, QualityTag.Solid);

            solidWithoutPush = solidWithoutPushQuery.QueryAll(destinationStack.units);

            % There is an unpushable solid object blocking the way!
            if (~isempty(solidWithoutPush))
                canMove = false;
                return;
            end

            % Check that pushable objects ahead can move
            withPush = pushQuery.QueryAll(destinationStack.units);
            pushable = arrayfun(@(unit) this.CanMoveUnit(unit, direction), withPush);
            if (~all(pushable))
                % There is a pushable object ahead that cannot move.
                canMove = false;
                return;
            end
        end

        function DoMoveUnits(this)
            % Move all units in the room that have a pending moveRequest

            unMovedUnits = this.unitGrid.GetAllUnits();

            % Remove all units that don't need to be moved
            for i = length(unMovedUnits):-1:1
                unit = unMovedUnits(i);
        
                if (unit.moveRequest == Direction.Unset)
                    % Don't need to do anything
                    unMovedUnits(i)=[];
                    continue;
                end
            end
            
            % Try 10 times to move all the units
            for iterations=1:10
                if (isempty(unMovedUnits))
                    % All move requests have been completed
                    break;
                end
                
                % Create a UnitGrid for each direction of movement
                movingUnits = [UnitGrid(this.unitGrid.size), UnitGrid(this.unitGrid.size), UnitGrid(this.unitGrid.size), UnitGrid(this.unitGrid.size)];

                % Find which units have a valid movement
                % Iterate backwards because we are removing entries
                for i = length(unMovedUnits):-1:1
                    unit = unMovedUnits(i);

                    if (unit.moveRequest == Direction.Unset)
                        % Don't need to do anything
                        unMovedUnits(i)=[];
                        continue;
                    end

                    if (this.CanMoveUnit(unit, unit.moveRequest))
                        % If the unit can be moved, do so
                        movingUnits(unit.moveRequest + 1).GetStack(unit.position).Add(unit);
                        unMovedUnits(i)=[];
                    end
                end

                % Move the units that can be moved
                for direction = 0:3
                    movingGrid = movingUnits(direction + 1);

                    for unitStack=movingGrid.allStacks
                        this.MoveUnitStack(unitStack, Direction(direction));

                        % Clear the units' moverequests
                        for unit=unitStack.units
                            unit.moveRequest = Direction.Unset;
                        end
                    end
                end
            end

            % Clear the remaining moverequests that weren't completed
            for unit=unMovedUnits
                unit.moveRequest = Direction.Unset;
            end
        end
    end
end

