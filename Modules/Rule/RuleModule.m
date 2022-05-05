classdef RuleModule
    % Handles when to parse and interpret rules in a room

    properties
        ruleParser
        ruleInterpreter
    end

    properties (Constant)
        % Which stages cause units to be moved
        MovementStages = [BehaviourOperationOrder.MoveUnits1, BehaviourOperationOrder.MoveUnits2, BehaviourOperationOrder.MoveUnits3, BehaviourOperationOrder.MoveUnits4]
        
        % Which stages cause the room to be parsed again
        ParsingStages = [BehaviourOperationOrder.Parsing1, BehaviourOperationOrder.Parsing3];
    end
    
    methods
        function this = RuleModule()
            % Class initialiser

            this.ruleParser = RuleParser();
            this.ruleInterpreter = RuleInterpreter();
        end

        function DoParsing(this, room)
            % Parse, then interpret the room

            rules = this.ruleParser.ParseRules(room);

            this.ruleInterpreter.InterpretRules(rules, room);
        end

        function EvaluateRuleActions(this, room)
            % Carry out all the actions on units in a room

            actions = this.GetAllRuleActions(room);

            operations = enumeration("BehaviourOperationOrder");

            % Go through each stage of the order of operations
            for stage=1:length(operations) - 1
                if ismember(stage, RuleModule.ParsingStages)
                    % Parse the room again
                    this.DoParsing(room);
                    actions = this.GetAllRuleActions(room);
                    continue;
                end
                if ismember(stage, RuleModule.MovementStages)
                    % Move units in the room.
                    room.DoMoveUnits();
                    continue;
                end

                % Evaluate the actions in this stage
                for pair=actions{stage}
                    pair{1}{2}.Evaluate(pair{1}{1}, room);
                end
            end
        end

        function actions = GetAllRuleActions(this, room)
            % Get all rule actions on units in the room

            operations = enumeration("BehaviourOperationOrder");

            actions = cell(length(operations), 1);

            % For each unit, get it's actions
            for unit = room.unitGrid.GetAllUnits()
                for action = unit.actions
                    if (action.behaviourOrder)
                        actions{action.behaviourOrder}{end+1} = {unit, action};
                    end
                end
            end
        end
    end
end

