classdef RuleOperator
    % A verb or condition in a sentence
    
    properties
        operator
        parameters
    end
    
    methods
        function this = RuleOperator(operator, parameters)
            this.operator = operator;
            this.parameters = parameters;
        end
    end
end

