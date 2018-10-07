classdef Driver
    properties (SetAccess = private)
        comPort
        baudRate
        currentPosition
        driver
    end

    properties (Constant)
        startMarker = '<'
        endMarker = '>'
        CAN = char(30)
        ACK = char(6)
    end

    methods
        function obj = Driver(comPort,baudRate)
            if nargin > 0
                % Need to check type
                obj.comPort = comPort;
                obj.baudRate = baudRate;
                % Initialize default value
                obj.currentPosition = 0;
                % Create interface
                obj.createInterface();
            end
        end

        function createInterface(obj)
            obj.driver = serial(obj.comPort,'BaudRate',obj.baudRate);
            fopen(obj.driver);
        end
    end

    methods (Static)
        function command = getCommandSetRemote()
            command = strcat(Driver.startMarker,Driver.CAN);
            command = strcat(command,',r');
            command = strcat(command,Driver.endMarker);
        end

        function command = getCommandVariableSpeed(reverse,numStep)
            command = strcat(Driver.startMarker,Driver.CAN);
            command = strcat(command,',a,');
            if reverse
                command = strcat(command,'1,');
            else
                command = strcat(command,'0,');
            end
            command = strcat(command,num2str(numStep));
            command = strcat(command,Driver.endMarker);
        end

        function command = getCommandConstantSpeed(reverse,numStep,period)
            command = strcat(Driver.startMarker,Driver.CAN);
            command = strcat(command,',c,');
            if reverse
                command = strcat(command,'1,');
            else
                command = strcat(command,'0,');
            end
            command = strcat(command,num2str(numStep),',');
            command = strcat(command,num2str(period));
            command = strcat(command,Driver.endMarker);
        end
    end
end
