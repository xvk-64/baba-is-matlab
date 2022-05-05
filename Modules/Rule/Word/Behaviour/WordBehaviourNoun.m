classdef (Abstract) WordBehaviourNoun < WordBehaviourBase
    % Represents a noun 
    
    properties
        wordType = WordType.Noun;
    end
    methods (Abstract)
        Evaluate(this, room);
    end
end

