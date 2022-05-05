classdef QueryMode < uint8
    % Represents a mode of querying units

    enumeration
        % The unit must have all of the criteria
        WithAll (1)

        % The unit must have at least one of the criteria
        WithAny (2)

        % The unit must have none of the criteria
        WithNone (3)
    end
end

