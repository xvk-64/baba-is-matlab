classdef GameInput < handle
    % Manages input from the figure window's keypress events
    
    events
        KeyPress
        KeyRelease
    end

    methods
        function this = GameInput(graphics)
            % Class initialiser

            % Attach to the keypress and keyrelease events
            graphics.fig.KeyPressFcn = @this.OnKeyPress;
            graphics.fig.KeyReleaseFcn = @this.OnKeyRelease; 
        end
    end
    
    methods (Access='private')
        function OnKeyPress(this,~,event)
            notify(this, "KeyPress", KeyData(event.Key))
        end

        function OnKeyRelease(this,~,event)
            notify(this, "KeyRelease", KeyData(event.Key));
        end
    end
end

