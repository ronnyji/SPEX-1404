classdef Driver < handle
    properties (SetAccess = private)
        comPort
        baudRate
        currentPosition
        driver
    end

    properties (Access = private,Constant)
        startMarker = '<'
        endMarker = '>'
        CAN = char(24)
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

        function setCurrentPosition(obj,position)
            obj.currentPosition = position;
        end

        function createInterface(obj)
            obj.driver = serial(obj.comPort,'BaudRate',obj.baudRate,'Timeout',3600);
            fopen(obj.driver);
        end

        function closeInterface(obj)
            fclose(obj.driver);
        end

        function reply = sendCommand(obj,command)
            fprintf(obj.driver,command);
            reply = fscanf(obj.driver);
            reply = strip(reply);
        end

        function success = verifyReady(obj)
            reply = fscanf(obj.driver);
            reply = strip(reply);
            success = Driver.verifyMode(reply);
        end

        function success = setRemote(obj)
            command = Driver.getCommandSetRemote();
            reply = obj.sendCommand(command);
            success = Driver.verifyReply(reply);
        end

        function success = backlashAdjustment(obj)
            command = Driver.getCommandBacklashAdjustment();
            reply = obj.sendCommand(command);
            success = Driver.verifyReply(reply);
        end

        function success = moveTo(obj,position,constantSpeed,period)
            if nargin == 2
                constantSpeed = false;
            elseif nargin == 3
                period = 400;
            end
            if obj.currentPosition == position
                success = false;
            else
                num_steps = abs(position - obj.currentPosition) * 400;
                if obj.currentPosition < position
                    reverse = false;
                elseif obj.currentPosition > position
                    reverse = true;
                end
                if constantSpeed
                    command = Driver.getCommandConstantSpeed(reverse,num_steps,period);
                else
                    command = Driver.getCommandVariableSpeed(reverse,num_steps);
                end
                reply = obj.sendCommand(command);
                success = Driver.verifyReply(reply);
                obj.currentPosition = position;
            end
        end
    end

    methods (Static)
        function command = getCommandSetRemote()
            command = strcat(Driver.startMarker,Driver.CAN);
            command = strcat(command,',r');
            command = strcat(command,Driver.endMarker);
        end

        function command = getCommandBacklashAdjustment()
            command = strcat(Driver.startMarker,Driver.CAN);
            command = strcat(command,',b');
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

        function valid = verifyMode(reply)
            % switch reply(12:22)
            %     case 'Normal Mode'
            %         valid = true;
            %     case 'Debug Mode '
            %         error('Unsupported Driver Mode: Debug');
            %     otherwise
            %         error('Unknown Driver Mode');
            % end
            valid = strcmp(reply(12:22),'Normal Mode');
        end

        function valid = verifyReply(reply)
            expected = strcat(Driver.startMarker,Driver.ACK,Driver.endMarker);
            valid = strcmp(reply,expected);
        end
    end
end
