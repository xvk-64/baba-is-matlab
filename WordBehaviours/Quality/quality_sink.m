classdef quality_sink < WordBehaviourQuality
    methods
        function Evaluate(this, unit, room)
            stack = room.unitGrid.GetStack(unit.position);

            if (length(stack.units) > 1)
                for unit=stack.units
                    room.DestroyUnit(unit);
                end
            end
        end
        
        function order = behaviourOrder(this)
            order = BehaviourOperationOrder.RegularProperty;
        end
    end
end


