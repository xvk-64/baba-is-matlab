classdef Sentence
    % An ordered list of words that was parsed from word units in a room

    properties (GetAccess='public', SetAccess='private')
        % The start and end index of this sentence, used to find
        % sub-sentences contained inside each other
        startIndex
        endIndex

        % The list of words in this sentence
        words
    end
    
    methods
        function this = Sentence(startIndex, words)
            % Class initialiser

            this.startIndex = startIndex;
            this.endIndex = startIndex + length(words) - 1;
            this.words = words;
        end

        function isContained = IsContainedIn(this, other)
            % Is this sentence contained inside another?

            isContained = this.startIndex >= other.startIndex && this.endIndex <= other.endIndex;
        end
    end

    methods (Static)
        function sentence = FromStrings(strings)
            % Create a sentence from strings

            words = Word.empty;

            % For each string, get the corresponding Word
            for i=1:length(strings)
                words(end+1) = Word.FromWordDef(Game.wordDefManager.GetWordDef(strings(i)));
            end

            sentence = Sentence(1, words);
        end
    end
end

