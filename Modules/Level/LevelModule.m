classdef LevelModule < handle
    % Manages the currently played level and handles loading new levels

    properties
        roomModule

        % List of the current levels to be played
        levels
        % The index of the currently playing level
        levelIndex
    end
    
    methods
        function this = LevelModule()
            % Class initialiser
            
            this.roomModule = RoomModule();
            
            % Listen to when the level is exited
            addlistener(this.roomModule, "ExitLevel", @this.OnExitLevel);
            
            this.levels = string.empty;
            this.levelIndex = 1;
        end

        function PlayLevels(this, levels)
            % Play all of the levels inside of the levels list

            this.levels = levels;
            this.levelIndex = 1;

            % Start with the first level
            this.PlayLevel(this.levelIndex);
        end

        function PlayLevel(this, levelIndex)
            % Play a level with an index in the levels list
            this.levelIndex = levelIndex;

            % Start playing
            this.roomModule.StartRoom(RoomDef(this.levels(levelIndex)));
        end

        function Update(this, deltaTime)
            % Called every frame

            this.roomModule.Update(deltaTime);
        end

        function OnExitLevel(this, ~, ~)
            % When the level is exited

            if (this.levelIndex < length(this.levels))
                % If there is another level to play, play it
                this.PlayLevel(this.levelIndex + 1);
            end
        end
    end
end

