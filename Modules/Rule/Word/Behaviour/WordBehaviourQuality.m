classdef (Abstract) WordBehaviourQuality < WordBehaviourBase
    % Represents a quality
    
    properties
        wordType = WordType.Quality;
    end
    methods
        function Evaluate(this, unit, room)

        end
        function order = behaviourOrder(this)
            order = BehaviourOperationOrder.DoNotEvaluate;
        end
        function qualityTags = qualityTags(this)
            qualityTags = [];
        end
    end
end

