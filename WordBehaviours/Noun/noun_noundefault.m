classdef noun_noundefault < WordBehaviourNoun
    methods
        function units = Evaluate(this, room)
            nounQuery = UnitQuery().WithNounReferences(QueryMode.WithAll, this.word.wordDef.word);

            units = nounQuery.QueryAll(room.unitGrid.GetAllUnits());
        end
    end
end

