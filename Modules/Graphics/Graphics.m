classdef Graphics < handle
% Handles all graphical operations, including creating the window drawing
% and drawing tiles

    properties (GetAccess='public', SetAccess='private')
        % The figure window
        fig
        windowWidth
        windowHeight

        % The array containing pixels to be drawn to
        canvas
        canvasIm

        % Time the last frame was drawn
        lastFrameTime
        lastTitleUpdate

        % Palette and tile managers
        paletteManager
        tileManager
    end

    properties (Constant)
        % The index of the background colour of levels
        BackgroundColour = 28;

        % The index of the edge colour of levels
        EdgeColour = 1;

        % How quickly sprites "wobble"
        WobbleRate = 5;
    end
    
    methods
        function this = Graphics(windowWidth, windowHeight)
            % Class initialiser

            % Size in pixels of the window
            this.windowWidth = int32(windowWidth);
            this.windowHeight = int32(windowHeight);
    
            % Reset last frame time
            this.lastFrameTime = tic;
            this.lastTitleUpdate = tic;

            % Set up figure window
            fig = figure;
            fig.Name = "Baba Is You";   % Set window title
            fig.NumberTitle = "Off";    % Disable axes
            fig.MenuBar = "none";       % Disable the toolbar
            fig.Position = [500, 200, windowWidth, windowHeight]; % Set window size
            set(gca,'units','normalized','position',[0 0 1 1]); % Make game fill window
            fig.CloseRequestFcn = @this.OnClose; % Handle the window being closed
            this.fig = fig;
            
            % Set up palette and tiles
            this.paletteManager = PaletteManager();
            this.tileManager = TileManager();

            % Initialise the canvas, the matrix of pixels that are
            % displayed. Fill with the background colour
            this.canvas = repmat(this.paletteManager.GetColour(Graphics.BackgroundColour), [this.windowHeight, this.windowWidth, 1]);
            
            % Convert canvas to an image and display it in the figure
            % window
            this.canvasIm = imshow(this.canvas, [0,255]);
            this.fig.CurrentObject = this.canvasIm;

            % Clear the canvas
            this.Clear();
            this.Flush();
        end

        function OnClose(this, src, data)
            % When the figure window is closed, stop the game.
            Game.Close();
        end

        function Close(this)
            % Close the window
            delete(this.fig);
        end

        function DrawRoom(this, room)
            % Draw all the units in a room.

            % Get room height and width
            roomSize = room.size;
            roomHeight = roomSize(2) * 24;
            roomWidth = roomSize(1) * 24;

            % Get the offset required to centre the room in the window
            posOffset = int32([this.windowWidth - roomWidth, this.windowHeight - roomHeight] / 2);
            
            % Clamp the offset, so it isn't less than zero.
            xc = max(0, posOffset(1));
            yc = max(0, posOffset(2));

            % Make sure the drawn part of the room isn't larger than the
            % figure window
            rhc = min(this.windowHeight, roomHeight);
            rwc = min(this.windowWidth, roomWidth);

            % Draw level background
            colour = this.paletteManager.GetColour(Graphics.BackgroundColour) * 4;
            this.canvas(yc+1:yc+rhc, xc+1:xc+rwc,1) = colour(1);
            this.canvas(yc+1:yc+rhc, xc+1:xc+rwc,2) = colour(2);
            this.canvas(yc+1:yc+rhc, xc+1:xc+rwc,3) = colour(3);

            % Get all units in the room
            units = room.unitGrid.GetAllUnits();

            % Draw each units
            for i = 1:length(units)
                unit = units(i);

                % Get the position on the screen
                screenPos = int32(unit.screenPos);
                
                % Get the tile index
                tileIndex = int32(unit.baseTileIndex) + int32(mod(floor(tic * Graphics.WobbleRate / 10000000), 3));

                % Draw the corresponding tile at the right position
                this.DrawTile(tileIndex, screenPos + posOffset, unit.colour);
            end
        end

        function DrawTile(this, tileIndex, pos, colourNum)
            % Draw a single tile to the screen

            % Flip the vertical position so that (0,0) is in the bottom
            % left corner
            pos(2) = this.windowHeight - pos(2);

            % Correction because the tiles are 24x24 but sprites are 32x32
            pos = pos + int32([-4, -28]);

            % Get the distance to the left, top, right, bottom of the
            % window
            left = pos(1);
            top = pos(2);
            right = this.windowWidth - 32 - left;
            bottom = this.windowHeight - 32 - top;
        
            % Clip the left, top, right, bottom distances so that they
            % aren't outside the window
            leftClip = min(max(0, left), this.windowWidth);
            bottomClip = min(max(0, bottom), this.windowHeight);
            rightClip = min(max(0, right), this.windowWidth);
            topClip = min(max(0, top), this.windowHeight);
    
            % Clip the width and height of the tile so it isn't outside the
            % window
            widthClip = this.windowWidth - leftClip - rightClip;
            heightClip = this.windowHeight - bottomClip - topClip;

            % If the tile is not visible, don't display it
            if (widthClip == 0 || heightClip == 0)
                return
            end

            % Get reference to the canvas
            c = this.canvas;

            % Get the offset of the first pixel inside the tile
            tileLeft = leftClip - left;
            tileTop = topClip - top;

            % Get colour, tile and mask
            colour = this.paletteManager.GetColour(colourNum);
            tile = this.tileManager.GetTile(tileIndex);
            mask = tile(:,:,1) | tile(:,:,2) | tile(:,:,3);

            % Draw each pixel
            for row = 1:heightClip
                for col = 1:widthClip
                    % Check if the pixel is in the tile mask
                    if (~mask(tileTop + row, tileLeft + col))
                        % If it isn't it doesn't need to be drawn.
                        continue
                    end

                    % Draw the red, green and blue parts of the pixel
                    c(topClip + row, leftClip + col,1) = tile(tileTop + row, tileLeft + col, 1) * colour(1,1,1);
                    c(topClip + row, leftClip + col,2) = tile(tileTop + row, tileLeft + col, 2) * colour(1,1,2);
                    c(topClip + row, leftClip + col,3) = tile(tileTop + row, tileLeft + col, 3) * colour(1,1,3);
                end
            end

            % Assign the changes to the canvas
            this.canvas = c;
        end

        function Clear(this)
            % Clear the window

            % Fill with edge colour, will be overwritten with background
            % colour later
            colour = this.paletteManager.GetColour(Graphics.EdgeColour) * 4;

            % Set the red, green and blue pixels
            this.canvas(:,:,1) = colour(1);
            this.canvas(:,:,2) = colour(2);
            this.canvas(:,:,3) = colour(3);
        end

        function Flush(this)
            % Push the latest changes to the figure

            % Get the time since the last frame
            deltaTime = toc(this.lastFrameTime);
            this.lastFrameTime = tic;
            
            % Set the figures image data
            this.canvasIm.CData = this.canvas;

            % Update the title with the latest fps
            if (this.lastFrameTime - this.lastTitleUpdate > 5000000)
                this.lastTitleUpdate = this.lastFrameTime;
                this.fig.Name = "Baba Is You (" + string(1/deltaTime) + " FPS)";
            end

            % Force matlab to draw the frame
            drawnow limitrate
        end
    end
end

