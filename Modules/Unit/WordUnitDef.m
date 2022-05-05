classdef WordUnitDef < UnitDef
    % Defines a WordUnitDef, same as a UnitDef but with specific attributes
    % for words

    properties
        % The colour when this unit is part of a valid rule
        activeColour
        wordDef
    end
    
    methods
        function this = WordUnitDef(name, tileStartIndex, tilingType, colour, activeColour, wordDef)
            % Class initialiser
            
            % Call parent initialiser
            this@UnitDef(name, tileStartIndex, tilingType, colour);

            this.activeColour = activeColour;
            this.wordDef = wordDef;
        end

        function isText = isText(this)
            % Is this Unit text? (yes)
            isText = true;
        end
    end
end

