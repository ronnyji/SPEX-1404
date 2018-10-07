classdef Counter
    properties
        boardIndex
        primaryAddress
        integrationTime
        counter
    end

    methods
        function obj = Counter(boardIndex, primaryAddress)
            if nargin > 0
                % Need to check type
                obj.boardIndex = boardIndex;
                obj.primaryAddress = primaryAddress;
                % Initialize default value
                obj.integrationTime = 0;
                % Create interface
                obj.createInterface();
            end
        end

        function createInterface(obj)
            obj.counter = gpib('ni',obj.boardIndex,obj.primaryAddress);
            obj.counter.EOSCharCode = 10;
            obj.counter.EOSMode = 'write';
            fopen(obj.counter);
        end
    end
end
