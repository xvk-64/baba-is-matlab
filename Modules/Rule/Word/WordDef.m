classdef WordDef < handle
    % Defines the properties of a Word

    properties
        % The string representation of this word
        word

        % What type is this word
        wordType

        % What word types are allowed on the right hand side of this word
        rhs

        % The wordbehaviour string name belonging to this word
        wordBehaviour
    end
    
    methods
        function this = WordDef(word, wordType, rhs, wordBehaviour)
            this.word = word;
            this.wordType = wordType;
            this.rhs = rhs;
            this.wordBehaviour = wordBehaviour;
        end
    end
end

