classdef RuleParser
    % Parses word units in a room into rules

    methods
        % Parse all text units in a room into rules
        function rules = ParseRules(this, room)
            % Set up return variable
            rules = Rule.empty;

            % Get all text units in the room
            textUnitGrid = this.GetAllTextUnits(room.unitGrid);

            % Get all straight lines of text unit stacks going left to right or
            % up to down
            textUnitStackLines = this.GetUnitStackLines(textUnitGrid);

            % Get all permutations of each unit stack and find the
            % wordDefs.
            wordStrings = this.GetWordStrings(textUnitStackLines);

            % Go through each wordstring to find a valid rule
            for i=1:length(wordStrings)
                wordString = wordStrings{i};

                sentences = this.GetSentences(wordString);

                validRules = Rule.empty;

                % Find all valid rules in the sentences 
                for j=1:length(sentences)
                    [valid, rule] = this.ParseSentence(sentences(j));
                    
                    if valid
                        validRules(end+1) = rule;
                    end
                end
                % Remove duplicate rules
                for j=1:length(validRules)
                    isUnique = true;

                    for k=1:length(validRules)
                        % Don't compare rule to itself
                        if (j ~= k && validRules(j).sentence.IsContainedIn(validRules(k).sentence))
                            isUnique = false;
                            break;
                        end
                    end

                    % If the rule is unique, add it to the list
                    if isUnique
                        rules(end+1) = validRules(j);
                    end
                end
            end

            % Add base rules
            baseRules = [
                Sentence.FromStrings(split("text is push")),...
                Sentence.FromStrings(split("level is stop")),
            ];
            for baseRule=baseRules
                [valid, rule] = this.ParseSentence(baseRule);

                if valid
                    rules(end+1) = rule;
                end
            end
        end

        % Get all text units in the room's unit grid.
        function textUnitGrid = GetAllTextUnits(this, unitGrid)
            % Set up return variable
            textUnitGrid = UnitGrid(unitGrid.size);

            % Prepare the query to find text units
            textQuery = UnitQuery().IsText(true);

            % Get all text units
            textUnits = textQuery.QueryAll(unitGrid.GetAllUnits());

            % Add each text unit to the return unit grid.
            for i=1:length(textUnits)
                textUnit = textUnits(i);
                textUnitGrid.GetStack(textUnit.position).Add(textUnit);
            end
        end

        % Get all straight lines of units going vertically or horizontally.
        function unitStackLines = GetUnitStackLines(this, unitGrid)
            % Prepare return variable
            unitStackLines = cell(0);

            % For each unit stack in the grid, determine if it is the start of a line,
            % then follow the line along.
            for unitStack=unitGrid.allStacks

                if (unitGrid.GetStackRelative(unitStack, Direction.Up).isEmpty)
                    % Empty above, add all stacks below                
                    j = length(unitStackLines) + 1;
                    unitStackLines{j} = UnitStack.empty;
    
                    nextStack = unitStack;
                    while ~nextStack.isEmpty
                        unitStackLines{j}(end+1) = nextStack;
                        nextStack = unitGrid.GetStackRelative(nextStack, Direction.Down);
                    end
                end

                if (unitGrid.GetStackRelative(unitStack, Direction.Left).isEmpty)
                    % Empty to the left, add all stacks to the right
                    j = length(unitStackLines) + 1;
                    unitStackLines{j} = UnitStack.empty;
    
                    nextStack = unitStack;
                    while ~nextStack.isEmpty
                        unitStackLines{j}(end+1) = nextStack;
                        nextStack = unitGrid.GetStackRelative(nextStack, Direction.Right);
                    end
                end
            end
        end

        % Converts lines of UnitStacks into arrays of Words.
        function wordStrings = GetWordStrings(this, unitStackLines)
            % Prepare return variable
            wordStrings = cell(0);

            % For each line of UnitStacks
            for i=1:length(unitStackLines)
                unitStackLine = unitStackLines{i};

                if (isempty(unitStackLine))
                    continue
                end

                % Find all permutations of units in the stacks
                % eg, baba/keke is you -> baba is you, keke is you
                permutations = allcomb(unitStackLine.units);
                for j=1:size(permutations, 1)
                    unitString = permutations(j,:);

                    % Minimum rule length is three words.
                    if (length(unitString) >= 3)
                        % Convert Units to Words.
                        wordStrings{end+1}=arrayfun(@(unit) Word.FromWordUnit(unit), unitString);
                    end
                end
            end
        end

        % Convert an array of words to sentences. This creates many
        % sentences from the same array, each one starts one more word into
        % the array.
        function sentences = GetSentences(this, wordString)
            % Prepare return variables
            sentences = Sentence.empty;

            % For each word in the array, create a new sentence starting at
            % this word.
            for i=1:length(wordString)
                sentence = Sentence(i, wordString(i:end));
                sentences(i) = sentence;
            end
        end
    
        % Parses a sentence to see if it contains a valid rule.
        function [valid, rule] = ParseSentence(this, sentence)
            % Set up return variables
            valid = false;
            rule = Rule.empty;

            index = 1;

            % Get the optional prefixes at the beginning of the sentence 
            % (lonely, powered...)
            [gotPrefixes, index, prefixes] = GetWords(index, WordType.Prefix, true);
            if (~gotPrefixes)
                prefixes = Word.empty;
            end

            % Get the nouns that are the subjects of the sentence
            % (baba, rock, wall...)
            [valid, index, subjects] = GetWords(index, WordType.Noun, true);

            % If not valid so far, give up parsing.
            if (~valid)
                return;
            end

            % Get the optional conditions of the sentence
            % (on rock, feeling sad...)
            [gotConditions, index, conditions] = GetOperators(index, WordType.Condition);
            if (~gotConditions)
                conditions = Word.empty;
            end

            % Get the verbs and parameters that are the actions of the
            % sentence
            % (is you, has rock...)
            [valid, index, actions] = GetOperators(index, WordType.Verb);

            % If not valid, stop parsing
            if (~valid)
                return;
            end

            % If there are invalid words at the end of the sentence, remove
            % them.
            if (index <= length(sentence.words))
                sentence = Sentence(sentence.startIndex, sentence.words(1:index-1));
            end

            % Create the Rule
            rule = Rule(prefixes, subjects, conditions, actions, sentence);


            % Supporting functions for parsing rules:

            % Check if a word is of a specific type.
            function match = IsWordType(word, wordTypes)
                match = ismember(word.wordDef.wordType, wordTypes);
            end
            
            % Reads a number of consecutive "not" words, returning whether
            % the overall effect was to negate or not.
            function [newIndex, negated] = GetNots(startIndex)
                newIndex = startIndex;

                while newIndex <= length(sentence.words) && IsWordType(sentence.words(newIndex), WordType.Not)
                    newIndex = newIndex + 1;
                end

                % Determine negation
                negated = mod(newIndex - startIndex, 2) == 1;
            end

            % Reads in a single word of a specified type, optionally
            % capturing the "not"s before it.
            function [gotWord, newIndex, word] = GetWord(startIndex, wordTypes, getNots)
                % Set up return variables
                gotWord = false;
                newIndex = startIndex;
                word = Word.empty;

                nextIndex = startIndex;

                negated = false;

                % Capture "not"s
                if (getNots)
                    [nextIndex, negated] = GetNots(nextIndex);
                end

                % Make sure we don't exceed array length
                if (nextIndex > length(sentence.words))
                    return
                end

                % Get the word
                word = sentence.words(nextIndex);
                word.negated = negated;

                % Check if the word is of the right type
                if (IsWordType(word, wordTypes))
                    newIndex = nextIndex + 1;
                    gotWord = true;
                end
            end

            % Reads in several words of a specified type, optionally
            % capturing the "not"s before each one.
            function [gotWord, newIndex, words] = GetWords(startIndex, wordTypes, getNots)
                % Set up return variables
                gotWord = false;
                newIndex = startIndex;
                words = Word.empty;

                % Try and get the first word
                [gotWord, newIndex, words] = GetWord(startIndex, wordTypes, getNots);

                % Search for subsequent words
                gotNextWord = gotWord;
                while (gotNextWord)
                    % Make sure there is an "and" between subsequent words
                    [gotAnd, nextIndex] = GetWord(newIndex, WordType.And, false);
                    
                    if (~gotAnd)
                        break;
                    end

                    % Try and get the next word after the "and"
                    [gotNextWord, nextIndex, nextWord] = GetWord(nextIndex, wordTypes, getNots);

                    % If we found the right word, add it to the list
                    if (gotNextWord)
                        newIndex = nextIndex;
                        words(end+1) = nextWord;
                    end
                end
            end

            % Reads in a single "operator", which is a single word,
            % followed by multiple parameters
            function [gotOperator, newIndex, operator] = GetOperator(startIndex, operatorType)
                % Set up return variables
                gotOperator = false;
                newIndex = startIndex;
                operator = RuleOperator.empty;

                % Try and get the operator word. Only conditions can have
                % "not"s before them.
                [gotOperator, nextIndex, operatorWord] = GetWord(startIndex, operatorType, operatorType == WordType.Condition);
                
                % If we couldn't find an operator, stop parsing.
                if (~gotOperator)
                    return;
                end

                % Get the allowed parameter word types for this operator
                parameterTypes = operatorWord.wordDef.rhs;

                % Get the parameters to the operator.
                [gotOperator, nextIndex, parameters] = GetWords(nextIndex, parameterTypes, true);

                % If there are no parameters, stop parsing.
                if (~gotOperator)
                    return;
                end

                % Create the operator
                operator = RuleOperator(operatorWord, parameters);

                % Save the next index
                newIndex = nextIndex;
            end

            % Reads in several operators, seperated by "and"
            function [gotOperator, newIndex, operators] = GetOperators(startIndex, operatorType)
                % Set up return variables
                gotOperator = false;
                newIndex = startIndex;
                operators = RuleOperator.empty;

                % Get the first operator
                [gotOperator, newIndex, operators] = GetOperator(startIndex, operatorType);

                % Look for subsequent operators
                gotNextOperator = gotOperator;
                while (gotNextOperator)
                    % Get the "and" separating operators
                    [gotAnd, nextIndex] = GetWord(newIndex, WordType.And, false);
                    
                    % If there was no "and", stop parsing.
                    if (~gotAnd)
                        break;
                    end

                    % Get the next operator
                    [gotNextOperator, nextIndex, nextOperator] = GetOperator(nextIndex, operatorType);

                    % If we found a suitable operator, add it to the list.
                    if (gotNextOperator)
                        newIndex = nextIndex;
                        operators(end+1) = nextOperator;
                    end
                end
            end

        end
    end
end

