classdef Direction < int32
    % Class to represent a direction

    enumeration
        Unset(-1)
        
        Right (0)
        Up (1)
        Left(2)
        Down(3)
    end

    methods
        function vec = GetVector(this)
            % Convert the direction to a 2d vector
            
            vecs = [0,0;1,0;0,1;-1,0;0,-1];
            vec = vecs(this + 2,:);
        end
    end
end

