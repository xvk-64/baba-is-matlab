classdef UnitDefManager < handle
    % Manages loading unit information from units.json

    properties
        unitDefAtlas
    end
    
    methods
        function obj = UnitDefManager(wordDefManager)
            % Class initialiser

            % Load units.json
            fID = fopen("assets/units.json");
            raw = fread(fID,inf); 
            str = char(raw'); 
            fclose(fID); 
            atlas = jsondecode(str);

            fields = string(fieldnames(atlas));
            % For each unit in units.json, load its attributes
            for i = 1:length(fields)
                unitName = fields(i);

                unit = atlas.(unitName);

                if (unit.text)
                    % If the unit is text, we also need to get the wordDef
                    word = erase(unitName, "text_");
                    wordDef = Game.wordDefManager.GetWordDef(word);
                    unitDef = WordUnitDef(unitName, unit.startIndex, unit.tiling, unit.colour, unit.activeColour, wordDef);
                else
                    % Create the UnitDef
                    unitDef = UnitDef(unitName, unit.startIndex, unit.tiling, unit.colour);
                end

                obj.unitDefAtlas.(unitName) = unitDef;
            end

            % Add special units

            % Level - represents the level edge
            obj.unitDefAtlas.level = copy(obj.unitDefAtlas.error);
            obj.unitDefAtlas.level.name = "level";
        end
        
        function unitDef = GetUnitDef(obj, unitName)
            % Gets a UnitDef by object name
            unitDef = obj.unitDefAtlas.(unitName);
        end
    end
end