classdef (Abstract) WordBehaviourVerb < WordBehaviourBase
    % Represents a verb
    
    properties
        parameter
        wordType = WordType.Verb;
    end
    methods
        function Evaluate(this, unit, room)
        end

        function order = behaviourOrder(this)
            order = BehaviourOperationOrder.DoNotEvaluate;
        end
    end
end

