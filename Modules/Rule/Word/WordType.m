classdef WordType < uint8
    % Represents the type of a word
    
    enumeration
        Noun        (1)
        Quality     (2)
        Verb        (3)
        Condition   (4)
        Prefix      (5)
        And         (6)
        Not         (7)
        Letter      (8)
    end

    methods (Static)
        function stringName = ToString(wordType)
            stringName = "";
            switch wordType
                case WordType.Noun
                    stringName = "noun";
                case WordType.Quality
                    stringName = "quality";
                case WordType.Verb
                    stringName = "verb";
                case WordType.Condition
                    stringName = "condition";
                case WordType.Prefix
                    stringName = "prefix";
                case WordType.And
                    stringName = "and";
                case WordType.Not
                    stringName = "not";
                case WordType.Letter
                    stringName = "letter";                    
            end
        end

        function wordType = FromString(string)
            switch string
                case "noun"
                    wordType = WordType.Noun;
                case "quality"
                    wordType = WordType.Quality;
                case "condition"
                    wordType = WordType.Condition;
                case "prefix"
                    wordType = WordType.Prefix;
                case "verb"
                    wordType = WordType.Verb;
                case "and"
                    wordType = WordType.And;
                case "not"
                    wordType = WordType.Not;
                case "letter"
                    wordType = WordType.Letter;
            end
        end
    end
end

