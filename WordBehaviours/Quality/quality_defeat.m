classdef quality_defeat < WordBehaviourQuality
    methods
        function Evaluate(this, unit, room)
            youQuery = UnitQuery().WithQualityTags(QueryMode.WithAny, QualityTag.You);
            stack = room.unitGrid.GetStack(unit.position);

            if (length(stack.units) > 1)
                youUnits = youQuery.QueryAll(stack.units);
                for unit=youUnits
                    room.DestroyUnit(unit);
                end
            end
        end
        
        function order = behaviourOrder(this)
            order = BehaviourOperationOrder.RegularProperty;
        end
    end
end


