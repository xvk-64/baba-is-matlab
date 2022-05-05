classdef PaletteManager < handle
    % Manages the different palettes of colours that can be shown
    
    properties (Access=private)
        % List of all loaded palettes
        palettes

        % Name of currently activated palette
        currentPalette
    end

    methods
        function this = PaletteManager()
            % Class initialiser

            % Initialise class members
            this.palettes = struct;
            this.currentPalette = "default";

            % Load palettes from palettes.json
            fID = fopen("assets/palettes.json");
            raw = fread(fID,inf); 
            str = char(raw'); 
            fclose(fID); 
            hexPalettes = jsondecode(str);
            
            % Put each palette into the palettes member
            fields = string(fieldnames(hexPalettes));
            for paletteIndex = 1:length(fields)
                paletteName = fields(paletteIndex);

                hexPalette = hexPalettes.(paletteName);
                
                this.palettes.(paletteName) = zeros(length(hexPalette), 1, 3, "uint8");
                
                % Convert each colour in the palette from hex to rgb
                for i = 1:length(hexPalette)
                    hexColour = char(hexPalette(i));
                    r = uint8(hex2dec(hexColour(1:2)));
                    g = uint8(hex2dec(hexColour(3:4)));
                    b = uint8(hex2dec(hexColour(5:6)));
                    this.palettes.(paletteName)(i,1,:) = reshape([r, g, b], [1,1,3])/4;
                end
            end
        end

        function colour = GetColour(this, colour)
            % Get a colour from the palette

            colour = this.palettes.(this.currentPalette)(colour + 1,1,1:3);
        end

        function SetPalette(this, palette)
            % Change the currently selected palette.
            
            this.currentPalette = palette;
        end

        function palette = GetPalette(this, paletteName)
            % Get a palette

            palette = this.palettes.(paletteName);
        end
    end
end