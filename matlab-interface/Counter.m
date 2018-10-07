classdef Counter
    properties (SetAccess = private)
        boardIndex
        primaryAddress
        integrationTime
        counter
    end

    methods
        function obj = Counter(boardIndex,primaryAddress)
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

    methods (Static)
        function checksum = calculateChecksum(command)
            checksum = sum(double(command));
            checksum = mod(checksum,256);
        end

        function command = appendChecksum(command)
            checksum = Counter.calculateChecksum(command);
            command = strcat(command,num2str(checksum,'%03d'));
        end

        function valid = verifyChecksum(command)
            checksum = Counter.calculateChecksum(command(1:end-3));
            if checksum == str2double(command(end-2:end))
                valid = true;
            else
                valid = false;
            end
        end
    end
end
