classdef quality_win < WordBehaviourQuality
    methods
        function Evaluate(this, unit, room)
            youQuery = UnitQuery().WithQualityTags(QueryMode.WithAny, QualityTag.You);
            stack = room.unitGrid.GetStack(unit.position);

            if (length(stack.units) > 1)
                if (youQuery.QueryAny(stack.units))
                    notify(room, "ExitLevel");
                end
            end
        end
        
        function order = behaviourOrder(this)
            order = BehaviourOperationOrder.RegularProperty;
        end
    end
end
