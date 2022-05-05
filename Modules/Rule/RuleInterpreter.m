classdef RuleInterpreter
    % Manages finding the meaning of rules parsed by RuleParser

    methods
        function InterpretRules(this, rules, room)
            % Interpret all rules in a room

            % Clear actions on each unit in the room
            for unit=room.unitGrid.GetAllUnits()
                unit.actions = noun_noundefault.empty;
            end

            % Convert rules to have a single subject and action.
            ruleSingles = Rule.empty;
            for rule=rules
                % Colour text
                for word=rule.sentence.words
                    if (~isempty(word.wordUnit))
                        word.wordUnit.colour = word.wordUnit.unitDef.activeColour;
                    end
                end

                ruleSingles = [ruleSingles, rule.ToRuleSingles()];
            end

            % Find negated rules
            unNegatedRules = Rule.empty;
            negatedRules = Rule.empty;
            for rule=ruleSingles
                negated = false;
                for negator=ruleSingles
                    if (this.IsRuleNegatedBy(rule, negator))
                        negated = true;
                        break;
                    end
                end

                if negated
                    negatedRules(end+1) = rule;
                else
                    unNegatedRules(end+1) = rule;
                end
            end

            % Remove negated rules from other rules
            ruleSingles = unNegatedRules;

            % Evaluate the rules, add actions to units in the room.
            for rule = ruleSingles
                this.InterpretRule(rule, room);
            end
               
            % Remove other negating rules that were missed earlier
            % (conditional)

        end

        function InterpretRule(this, rule, room)
            % Interpret a single rule

            % Get the units that this rule affects
            units = this.GetRuleSubjects(rule, room);

            % Add the actions to each unit
            this.AddRuleAction(rule.actions, units);
        end

        function units = GetRuleSubjects(this, rule, room)
            % Get the subjects of a rule in a room

            units = Unit.empty;

            % Get the wordbehaviour of the noun
            [gotNounBehaviour, nounBehaviour] = WordBehaviourManager.GetWordBehaviour(rule.subjects);
            if (gotNounBehaviour)
                % Evaluate the noun wordbehaviour to find the subjects
                units = nounBehaviour.Evaluate(room);

                % TODO Check prefixes

                % TODO Check conditions
            end
        end

        function AddRuleAction(this, action, subjects)
            % Add a rule action to units in a room

            % Get the wordbehaviour of the verb in the rule
            [gotOperatorBehaviour, operatorBehaviour] = WordBehaviourManager.GetWordBehaviour(action.operator);
            if (gotOperatorBehaviour)
                % Get the parameter wordbehaviour
                [gotParameterBehaviour, parameterBehaviour] = WordBehaviourManager.GetWordBehaviour(action.parameters);
                if gotParameterBehaviour
                    operatorBehaviour.parameter = parameterBehaviour;

                    % Add the actions to the subjects
                    for unit=subjects
                        unit.actions(end+1) = operatorBehaviour;
                    end
                end
            end
        end

        function isNegated = IsRuleNegatedBy(this, rule, negator)
            % Determines if a rule negates another's effect
            
            isNegated = false;

            % If the negator involves a condition, we cannot check it here.
            if ~(isempty(negator.prefixes) || isempty(negator.conditions))
                return;
            end

            % A rule is negated by negator if:
            % - Subjects match
            % - Operators match
            % - Parameters match
            % - Rule's parameter is not negated
            % - Negator's parameter is negated
            isNegated = rule.subjects.wordDef == negator.subjects.wordDef &&...
                rule.actions.operator.wordDef == negator.actions.operator.wordDef &&...
                rule.actions.parameters.wordDef == negator.actions.parameters.wordDef &&...
                ~rule.actions.parameters.negated && negator.actions.parameters.negated;
        end
    end
end

