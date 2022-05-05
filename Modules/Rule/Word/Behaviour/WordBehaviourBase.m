classdef (Abstract) WordBehaviourBase < handle & matlab.mixin.Heterogeneous
    % Base class of all WordBehaviours

    properties
        % The parsed word representing this behaviour
        word
    end
end

