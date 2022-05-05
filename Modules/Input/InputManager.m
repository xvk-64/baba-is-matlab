classdef InputManager < handle
    % Class to manager user inputs to the room

    properties
        % Time the last input update was sent
        lastInputUpdate

        % Which keys are currently pressed
        currentInputs
    end

    properties (Constant)
        % How often can new input events be sent
        InputInterval = 0.175
    end

    events
        NewInput
    end
    
    methods
        function this = InputManager()
            % Class initialiser

            this.lastInputUpdate = tic;

            % Attach to GameInput's keypress and keyrelease events
            addlistener(Game.input, "KeyPress", @this.OnKeyPress);
            addlistener(Game.input, "KeyRelease", @this.OnKeyRelease);

            % Reset the current inputs
            this.currentInputs = false(1, 5);
        end
        
        function OnKeyPress(this, ~, data)
            % Called when a key is pressed
            
            if (data.Key == "r")
                % r is the restart key
                this.SendRestart();
                return;
            end


            if (data.Key == "equal")
                this.SendSkip();
                return;
            end

            % Convert the key press to a direction
            newInput = this.KeyToDir(data.Key);

            if (isempty(newInput))
                % The key doesn't correspond to a direction
                return;
            end

            if (~this.currentInputs(newInput + 2))
                % If the key isn't being pressed already, set it to pressed and
                % send a new input
                this.currentInputs(newInput + 2) = true;
                this.SendInput(newInput);
            end
        end
        
        function OnKeyRelease(this, ~, data)
            % Convert the key press to a direction
            newInput = this.KeyToDir(data.Key);

            if (isempty(newInput))
                % The key doesn't correspond to a direction
                return;
            end

            % Set the key to unpressed
            this.currentInputs(newInput + 2) = false;
        end

        function dir = KeyToDir(this, key)
            % Convert a key to a direction

            % Default value if no match
            dir = Direction.empty;

            switch (key)
                case {"d", "rightarrow"}
                    dir = Direction.Right;
                case {"s", "downarrow"}
                    dir = Direction.Down;
                case {"a", "leftarrow"}
                    dir = Direction.Left;
                case {"w", "uparrow"}
                    dir = Direction.Up;
                case {"space"}
                    dir = Direction.Unset;
            end
        end

        function Update(this)
            % Called every frame

            if ((toc(this.lastInputUpdate) > InputManager.InputInterval))
                % If it is time to send a new input event
                
                % Get the active input
                activeInput = find(this.currentInputs, 1);
    
                if (~isempty(activeInput))
                    % If there is an active input, send it
                    this.SendInput(Direction(activeInput-2))
                end
            end
        end

        function SendInput(this, direction)
            % Broadcast the event with the pressed direction
            notify(this, "NewInput", InputData(direction));

            this.lastInputUpdate = tic;
        end

        function SendRestart(this)
            % If restart key was pressed, send a restart event
            
            data = InputData(Direction.Unset);
            data.restart = true;

            notify(this, "NewInput", data);
        end

        function SendSkip(this)
            data = InputData(Direction.Unset);
            data.skip = true;

            notify(this, "NewInput", data);
        end
    end
end

