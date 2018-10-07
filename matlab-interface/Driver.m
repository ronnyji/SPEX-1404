classdef Driver
    properties
        comPort
        baudRate
        currentPosition
        driver
    end

    methods
        function obj = Driver(comPort, baudRate)
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
end
