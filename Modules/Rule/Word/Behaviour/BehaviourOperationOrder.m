classdef BehaviourOperationOrder < uint8
    % The different stages that happen when parsing and evaluating rules in
    % a room
    enumeration
        % This rule operator or quality should not be evaluated
        DoNotEvaluate   (0),
        
        % Move units with the quality "you"
        MovementYou     (1),
        % Carry out all moverequests
        MoveUnits1      (2),

        % Other qualities that do movement
        Movement        (3),
        % Carry out all moverequests
        MoveUnits2      (4),

        % The movement of the quality "shift"
        MovementShift   (5),
        % Carry out all moverequests
        MoveUnits3      (6),

        % Secondary movement qualities such as "fall"
        SecondaryMovement   (7),
        % Carry out all moverequests
        MoveUnits4      (8),

        % Parse the room
        Parsing1        (9),

        % Perform any conversion operations
        Conversion      (10),

        % Parse the room
        Parsing2        (11),

        % Qualities that change the colour, etc... of units
        Status          (12),

        % All other properties
        RegularProperty (13),

        % Parse the room again
        Parsing3        (14),
    end
end

