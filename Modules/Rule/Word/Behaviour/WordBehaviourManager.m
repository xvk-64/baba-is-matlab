classdef WordBehaviourManager
    % Handles creating new WordBehaviour instances

    methods (Static)
        function [success, wordBehaviour] = GetWordBehaviour(word)
            % Get a WordBehaviour instance from a parsed Word

            success = false;
            wordBehaviour = WordBehaviourBase.empty;

            try
                % We don't know the class name ahead of time, so we use
                % feval to instantiate the class from a string
                wordBehaviour = feval(word.wordDef.wordBehaviour);
                wordBehaviour.word = word;
            catch
                % There was an error getting the WordBehaviour
                return;
            end

            success = true;
        end
    end
end

