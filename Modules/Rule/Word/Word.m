classdef Word
    % Represents a word parsed in a sentence

    properties (GetAccess='public', SetAccess='private')
        % The word Unit in the room corresponding to this word
        wordUnit
        
        % The Word definition of this word
        wordDef
    end

    properties
        % Is this word negated (there is a "not" before it)
        negated = false;
    end

    methods (Static)
        function word = FromWordDef(wordDef)
            % Create a Word from a WordDef

            word = Word();

            word.wordDef = wordDef;
        end

        function word = FromWordUnit(wordUnit)
            % Create a Word from a WordUnit
            
            word = Word();
            
            word.wordUnit = wordUnit;
            % Get the WordDef from the WordUnit
            word.wordDef = wordUnit.unitState.unitDef.wordDef;
        end
    end
end

