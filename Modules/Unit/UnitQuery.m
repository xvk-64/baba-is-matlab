classdef UnitQuery
    % Class to find units that match certain criteria

    properties (GetAccess='public', SetAccess='private')
        % Get Units with a specific nounReference
        nounReferences

        % Get Units that have specific actions
        actions

        % Get text units
        isText

        % Get units that have specific qualitytags
        qualityTags
    end
    
    methods
        function this = UnitQuery()
            % Class initialiser
            
            this.nounReferences = cell(3,1);
            this.actions = cell(3,1);
            this.isText = logical.empty;
            this.qualityTags = cell(3,1);
        end
        
        function this = WithNounReferences(this, queryMode, nounReferences)
            this.nounReferences{queryMode} = [this.nounReferences{queryMode}, nounReferences];
        end

        function this = WithActions(this, queryMode, actions)
            this.actions{queryMode} = [this.actions{queryMode}; actions];
        end

        function this = IsText(this, isText)
            this.isText = isText;
        end

        function this = WithQualityTags(this, queryMode, qualityTags)
            this.qualityTags{queryMode} = [this.qualityTags{queryMode}, qualityTags];
        end

        function queryMatch = Query(this, unit)
            % Does the unit match this query?

            queryMatch = false;

            % nounReference
            nr = this.nounReferences;
            if (~isempty(nr{QueryMode.WithAll}) && nr{QueryMode.WithAll} ~= unit.unitDef.name)
                return
            end
            if (~isempty(nr{QueryMode.WithAny}) && ~any(nr{QueryMode.WithAny} == unit.unitDef.name))
                return
            end
            if (~isempty(nr{QueryMode.WithNone}) && nr{QueryMode.WithNone} == unit.unitDef.name)
                return
            end

            % Actions and quality tags
            act = this.actions;
            anyMatch = false;
            allMatch = false;

            qt = this.qualityTags;
            foundTags = QualityTag.empty;

            for action = unit.actions
                actionStrings = [action.word.wordDef.word, action.parameter.word.wordDef.word];
                
                allMatch = false;
                for row=1:size(act{QueryMode.WithAll}, 1)
                    if all(actionStrings == act{QueryMode.WithAll}(row,:))
                        allMatch = true;
                    end
                end
                if (~isempty(act{QueryMode.WithAll}) && ~allMatch)
                    return;
                end

                for row=1:size(act{QueryMode.WithAny}, 2)
                    if all(actionStrings == act{QueryMode.WithAny}(row,:))
                        anyMatch = true;
                    end
                end

                noneMatch = false;
                for row=1:size(act{QueryMode.WithNone}, 1)
                    if all(actionStrings == act{QueryMode.WithNone}(row,:))
                        noneMatch = true;
                        break;
                    end
                end
                if (noneMatch)
                    return;
                end

                if (action.parameter.wordType == WordType.Quality)
                    foundTags = [foundTags, action.parameter.qualityTags];
                end
            end
            if (~isempty(act{QueryMode.WithAll}) && ~allMatch)
                return;
            end
            if (~isempty(act{QueryMode.WithAny}) && ~anyMatch)
                return;
            end

            % Quality tags
            if (~isempty(qt{QueryMode.WithAll}) && ~all(ismember(qt{QueryMode.WithAll}, foundTags)))
                return;
            end
            if (~isempty(qt{QueryMode.WithAny}) && ~any(ismember(qt{QueryMode.WithAny}, foundTags)))
                return;
            end
            if (~isempty(qt{QueryMode.WithNone}) && ~any(ismember(qt{QueryMode.WithNone}, foundTags)))
                return;
            end

            % Is text
            txt = this.isText;
            if (~isempty(txt) && txt ~= unit.unitDef.isText)
                return;
            end

            queryMatch = true;
        end

        function matchedUnits = QueryAll(this, units)
            % Find all units that match the query

            matchedUnits = Unit.empty;

            for unit=units
                if (this.Query(unit))
                    matchedUnits(end+1) = unit;
                end
            end
        end

        function match = QueryAny(this, units)
            % Find whether there was at least one match to the query
            
            match = false;

            for unit=units
                if (this.Query(unit))
                    match = true;
                    return;
                end
            end
        end
    end
end 