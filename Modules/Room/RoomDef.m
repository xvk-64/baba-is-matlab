classdef RoomDef
    % Contains information defining a room and the units within it

    properties
        size
        % The unitStates of Units to be created in the room
        unitStates
    end

    methods
        function this = RoomDef(levelName)
            % Class initialiser, load a level json file

            this.size = [0,0];
            this.unitStates = UnitState.empty;

            % Load the appropriate json file
            fID = fopen("assets/levels/"+levelName+".json");
            raw = fread(fID,inf); 
            str = char(raw'); 
            fclose(fID); 
            room = jsondecode(str);

            this.size = [room.width, room.height];

            % Get the UnitState of each entry in the file
            for i=1:length(room.units)
                unitStruct = room.units(i);

                unitDef = Game.unitDefManager.GetUnitDef(unitStruct.name);
                unitState = UnitState(unitDef, [unitStruct.x, unitStruct.y], Direction(unitStruct.dir));
                
                this.unitStates(end+1) = unitState;
            end
        end
    end
end

