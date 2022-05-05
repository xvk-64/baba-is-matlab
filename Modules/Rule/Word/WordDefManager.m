classdef WordDefManager < handle
    % Handles loading WordDefs from words.json

    properties
        wordDefAtlas
    end
    
    methods
        function obj = WordDefManager()
            % Class initialiser

            % Load words.json
            fID = fopen("assets/words.json");
            raw = fread(fID,inf); 
            str = char(raw');
            fclose(fID); 
            atlas = jsondecode(str);

            % For each word loaded from words.json
            fields = string(fieldnames(atlas));
            for wordIndex = 1:length(fields)
                % Get the word name
                wordName = fields(wordIndex);

                word = atlas.(wordName);

                rhs = [];

                % Get the word type
                wordType = WordType.FromString(word.wordType);

                % Get the allowed rhs types, if it exists
                if isfield(word, "rhs")
                    wordRhs = string(word.rhs);

                    for i=1:length(wordRhs)
                        rhs(end+1) = WordType.FromString(wordRhs(i));
                    end
                end

                % Add the word to the atlas
                obj.wordDefAtlas.(wordName) = WordDef(wordName, wordType, rhs, word.wordBehaviour);
            end
        end

        function wordDef = GetWordDef(obj, word)
            % Get a WordDef from the atlas

            firstLetter = extract(word, 1);
            if (~isletter(firstLetter))
                % If the first character is a number we need to add "x" since
                % matlab only allows alphabetic first characters
                word = "x" + word;
            end

            % Get the WordDef
            wordDef = obj.wordDefAtlas.(word);
        end
    end
end

