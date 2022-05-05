classdef UnitAnimator
    % Manages animating units in a room

    methods (Static)
        function baseIndex = GetBaseIndex(unit, room)
            % Get the base index of an animation of the unit. In the game,
            % animations have 3 frames, starting from a base index

            baseIndex = uint32(unit.unitState.unitDef.tileStartIndex);
            dir = uint32(unit.unitState.direction);

            switch unit.unitState.unitDef.tilingType
                case 0
                    % Tiles based on facing direction
                    baseIndex = baseIndex + 3 * dir;

                case 1
                    % Tiles based on surrounding units
                    right = room.unitGrid.GetStack(unit.position + [1, 0]);
                    up = room.unitGrid.GetStack(unit.position + [0, 1]);
                    left = room.unitGrid.GetStack(unit.position + [-1, 0]);
                    down = room.unitGrid.GetStack(unit.position + [0, -1]);

                    matchQuery = UnitQuery().WithNounReferences(QueryMode.WithAll, unit.unitState.unitDef.name);

                    rightContains = room.unitGrid.IsOutsideGrid(unit.position + [1, 0]) || matchQuery.QueryAny(right.units);
                    upContains = room.unitGrid.IsOutsideGrid(unit.position + [0, 1]) || matchQuery.QueryAny(up.units);
                    LeftContains = room.unitGrid.IsOutsideGrid(unit.position + [-1, 0]) || matchQuery.QueryAny(left.units);
                    DownContains = room.unitGrid.IsOutsideGrid(unit.position + [0, -1]) || matchQuery.QueryAny(down.units);
                
                    baseIndex = baseIndex + 3 * (rightContains + 2 * upContains + 4 * LeftContains + 8 * DownContains);

                case 2
                    % Tiles as a character
                    baseIndex = baseIndex + 3 * (5 * dir + mod(unit.turnsMoved, 4));

                case 3
                    % Tiles based on facing direction and current turn
                    baseIndex = baseIndex + 3 * (4 * dir + mod(room.currentTurn, 4));

                case 4
                    % Tiles based on current turn
                    baseIndex = baseIndex + 3 * mod(room.currentTurn, 4);
                    
            end
        end
    end
end

