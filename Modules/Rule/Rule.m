classdef Rule < handle
    % Represent a rule that has been parsed from a sentence

    properties(GetAccess='public', SetAccess='private')
        prefixes
        subjects
        conditions
        actions

        sentence
    end
    
    methods
        function this = Rule(prefixes, subjects, conditions, actions, sentence)
            % Class initialiser

            this.prefixes = prefixes;
            this.subjects = subjects;
            this.conditions = conditions;
            this.actions = actions;
            this.sentence = sentence;
        end

        function ruleSingles = ToRuleSingles(this)
            % Divide this rule into several rules that each have a single
            % subject and action

            ruleSingles = Rule.empty;

            for subject = this.subjects
                for action = this.actions
                    for parameter = action.parameters
                        ruleSingles(end+1) = Rule(this.prefixes, subject, this.conditions, RuleOperator(action.operator, parameter), this.sentence);
                    end
                end
            end
        end
    end
end

