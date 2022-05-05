classdef verb_is < WordBehaviourVerb
    methods
        function Evaluate(this, unit, room)
            if (this.parameter.word.wordDef.wordType == WordType.Quality)
                % IF parameter is a quality, evaluate it
                this.parameter.Evaluate(unit, room);
            else
                % Otherwise parameter is a noun, transform the unit
                newUnitDef = Game.unitDefManager.GetUnitDef(this.parameter.word.wordDef.word);
                unit.Transform(newUnitDef);
            end
        end

        function order = behaviourOrder(this)
            order = BehaviourOperationOrder.DoNotEvaluate;

            if (this.parameter.word.wordDef.wordType == WordType.Quality)
                if (this.parameter.word.negated)
                    % Don't evaluate negated property
                    return;
                end

                order = this.parameter.behaviourOrder;
            else
                % Parameter must be a noun.
                order = BehaviourOperationOrder.Conversion;
            end
        end
    end
end

