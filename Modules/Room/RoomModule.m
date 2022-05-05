classdef RoomModule < handle
    % Manages gameplay in a room

    properties (GetAccess='public', SetAccess='private')
        room
        roomDef
        inputManager
        ruleModule
    end

    events
        ExitLevel
    end
    
    methods
        function this = RoomModule()
            % Class initialiser
            
            this.inputManager = InputManager(); 
            this.ruleModule = RuleModule();

            addlistener(this.inputManager, "NewInput", @this.OnNewInput);

            this.room = Room([0,0]);
        end

        function StartRoom(this, roomDef)
            % Start playing a level from a RoomDef

            % Create the room and listen for when exiting the level
            this.room = Room(roomDef.size);
            addlistener(this.room, "ExitLevel", @this.OnExitLevel);
            this.roomDef = roomDef;

            % Create the units
            for unitState=roomDef.unitStates
                this.room.CreateUnit(unitState);
            end

            % Update the rule actions and animations so they are correct
            % when the player starts playing
            this.ruleModule.EvaluateRuleActions(this.room);
            this.room.UpdateUnitAnimations();
        end
        
        function OnNewInput(this, ~, data)
            % Called when there is a new input to pass to the room

            if (data.restart)
                % Reset the room
                this.StartRoom(this.roomDef)
                return;
            end

            if (data.skip)
                notify(this, "ExitLevel");
                return;
            end

            % Update the room with the new input
            this.room.NextTurn(data.direction);
            this.ruleModule.EvaluateRuleActions(this.room);
            this.room.UpdateUnitAnimations();
        end

        function OnExitLevel(this, ~, ~)
            % Handles the room's ExitLevel event.

            % Let the event bubble up
            notify(this, "ExitLevel");
        end

        function Update(this, deltaTime)
            % Called each frame

            % Update the input and the room
            this.inputManager.Update();
            this.room.Update(deltaTime);
        end
    end
end

