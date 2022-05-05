classdef quality_you < WordBehaviourQuality
    methods
        function Evaluate(this, unit, room)
            unit.SetDirection(room.latestInput);
            unit.moveRequest = room.latestInput;
        end
        
        function order = behaviourOrder(this)
            order = BehaviourOperationOrder.MovementYou;
        end

        function qualityTags = qualityTags(this)
            qualityTags = QualityTag.You;
        end
    end
end

