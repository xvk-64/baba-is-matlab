classdef Game
    % Class to manage each of the game's modules and start the gameplay.
    
    properties (Constant)
        % The default window size of the game
        windowSize = [840, 480];

        % Which levels to play, in which order
        levels = ["1level", "2level", "4level", "5level", "6level", "8level", "9level", "11level", "10level"];
    end

    % These methods are "static properties"
    methods (Static, Access='private')
        function out = SetGetGraphics(data)
            persistent graphics;

            if (nargin)
                graphics = data;
            end

            out = graphics;
        end

        function out = SetGetInput(data)
            persistent input;

            if (nargin)
                input = data;
            end

            out = input;
        end

        function out = SetGetUnitDefManager(data)
            persistent unitDefManager;

            if (nargin)
                unitDefManager = data;
            end

            out = unitDefManager;
        end

        function out = SetGetLevelModule(data)
            persistent levelModule;

            if (nargin)
                levelModule = data;
            end

            out = levelModule;
        end

        function out = SetGetWordDefManager(data)
            persistent wordDefManager;

            if (nargin)
                wordDefManager = data;
            end

            out = wordDefManager;
        end

        function out = SetGetIsPlaying(data)
            persistent isPlaying;

            if (nargin)
                isPlaying = data;
            end

            out = isPlaying;
        end
    end

    methods (Static)
        function Init()
            % Start the game

            % Initialise the graphics with the current window size
            Game.SetGetGraphics(Graphics(Game.windowSize(1), Game.windowSize(2)));

            % Initialise GameInput, give a reference to the graphics
            % so it can listen to figure key press events
            Game.SetGetInput(GameInput(Game.graphics));

            % Initialise the WordDef manager, so it can load the data from
            % words.json
            Game.SetGetWordDefManager(WordDefManager());

            % Initialise the UnitDef manager, so it can load the data from
            % units.json
            Game.SetGetUnitDefManager(UnitDefManager(Game.wordDefManager));

            % Initialise the level module
            Game.SetGetLevelModule(LevelModule());

            % Set Game.isPlaying to true
            Game.SetGetIsPlaying(true);

            % Play the levels
            Game.levelModule().PlayLevels(Game.levels);
        end

        function graphics = graphics()
            graphics = Game.SetGetGraphics();
        end

        function input = input()
            input = Game.SetGetInput();
        end

        function unitDefManager = unitDefManager()
            unitDefManager = Game.SetGetUnitDefManager();
        end

        function levelModule = levelModule()
            levelModule = Game.SetGetLevelModule();
        end

        function wordDefManager = wordDefManager()
            wordDefManager = Game.SetGetWordDefManager();
        end

        function Update(deltaTime)
            % Called every frame

            if (~Game.isPlaying)
                return;
            end

            % Update the levelmodule
            Game.levelModule.Update(deltaTime);
            
            % Draw the new frame
            Game.graphics.Clear();
            Game.graphics.DrawRoom(Game.levelModule.roomModule.room);
            Game.graphics.Flush();
        end

        function isPlaying = isPlaying()
            isPlaying = Game.SetGetIsPlaying();
        end

        function Close()
            % Close the game

            % Set Game.isPlaying to false
            Game.SetGetIsPlaying(false);

            % Close the window
            Game.graphics.Close();
        end
    end
end

