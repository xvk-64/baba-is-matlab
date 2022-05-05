classdef noun_text < WordBehaviourNoun
    methods
        function units = Evaluate(this, room)
            nounQuery = UnitQuery().IsText(true);

            units = nounQuery.QueryAll(room.unitGrid.GetAllUnits());
        end
    end
end

