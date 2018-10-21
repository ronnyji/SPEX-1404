classdef Counter < handle
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

        function closeInterface(obj)
            fclose(obj.counter);
        end

        function status = sendCommand(obj,command)
            fprintf(obj.counter,command);
            status = fscanf(obj.counter);
            status = strip(status);
        end

        function [status,reply] = sendQuery(obj,command)
            fprintf(obj.counter,command);
            reply = fscanf(obj.counter);
            reply = strip(reply);
            status = fscanf(obj.counter);
            status = strip(status);
        end

        function success = setRemote(obj,enable)
            if enable
                command = 'ENABLE_REMOTE';
            else
                command = 'ENABLE_LOCAL';
            end
            status = obj.sendCommand(command);
            success = Counter.verifyChecksum(status) && Counter.verifyExecution(status);
        end

        function success = setAlarm(obj,enable)
            if enable
                command = 'ENABLE_ALARM';
            else
                command = 'DISABLE_ALARM';
            end
            status = obj.sendCommand(command);
            success = Counter.verifyChecksum(status) && Counter.verifyExecution(status);
        end

        function success = setIntegrationTime(obj,time)
            obj.integrationTime = time;
            [M,N] = Counter.getScientificNotation(time);
            command = strcat('SET_COUNT_PRESET',32,num2str(M),',',num2str(N));
            status = obj.sendCommand(command);
            if Counter.verifyChecksum(status) && Counter.verifyExecution(status)
                command = 'SET_MODE_SECONDS';
                status = obj.sendCommand(command);
                success = Counter.verifyChecksum(status) && Counter.verifyExecution(status);
            else
                success = false;
            end
        end

        function success = clearCounters(obj)
            command = 'CLEAR_COUNTERS';
            status = obj.sendCommand(command);
            success = Counter.verifyChecksum(status) && Counter.verifyExecution(status);
        end

        function success = clearCounter(obj,index)
            command = strcat('CLEAR_COUNTERS',32,Counter.getIndividualMask(index));
            status = obj.sendCommand(command);
            success = Counter.verifyChecksum(status) && Counter.verifyExecution(status);
        end

        function [success,count] = getCounters(obj)
            command = 'SHOW_COUNTS';
            [status,reply] = obj.sendQuery(command);
            if Counter.verifyChecksum(status) && Counter.verifyExecution(status)
                success = true;
                count = str2double(strsplit(reply,';'));
            else
                success = false;
                count = -1;
            end
        end

        function [success,count] = getCounter(obj,index)
            command = strcat('SHOW_COUNTS',32,Counter.getIndividualMask(index));
            [status,reply] = obj.sendQuery(command);
            if Counter.verifyChecksum(status) && Counter.verifyExecution(status)
                success = true;
                count = str2double(reply(1:8));
            else
                success = false;
                count = -1;
            end
        end

        function success = startCounting(obj)
            command = 'START';
            status = obj.sendCommand(command);
            success = Counter.verifyChecksum(status) && Counter.verifyExecution(status);
        end

        function success = stopCounting(obj)
            command = 'STOP';
            status = obj.sendCommand(command);
            success = Counter.verifyChecksum(status) && Counter.verifyExecution(status);
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
            valid = checksum == str2double(command(end-2:end));
        end

        function success = verifyExecution(reply)
            % switch reply(2:7)
            %     case '000000'
            %         success = true;
            %     case '001000'
            %         error('Power-up Just Occurred');
            %     case '004002'
            %         error('Power-up Self-Test Failure - ROM Test Failed');
            %     case '004008'
            %         error('Power-up Self-Test Failure - Scratchpad RAM Failed');
            %     case '129001'
            %         error('Command Syntax Error - Invalid Verb');
            %     case '129002'
            %         error('Command Syntax Error - Invalid Noun');
            %     case '129004'
            %         error('Command Syntax Error - Invalid Modifier');
            %     case '129008'
            %         error('Command Syntax Error - Invalid Command Data');
            %     case '129128'
            %         error('Command Syntax Error - Invalid 1st Data Value');
            %     case '129129'
            %         error('Command Syntax Error - Invalid 2nd Data Value');
            %     case '129130'
            %         error('Command Syntax Error - Invalid 3rd Data Value');
            %     case '129131'
            %         error('Command Syntax Error - Invalid 4th Data Value');
            %     case '129132'
            %         error('Command Syntax Error - Invalid Command');
            %     case '130001'
            %         error('Communications Error - UART Buffer Overrun');
            %     case '130002'
            %         error('Communications Error - UART Parity Error');
            %     case '130004'
            %         error('Communications Error - UART Framing Error');
            %     case '130128'
            %         error('Communications Error - Input Checksum Error');
            %     case '130129'
            %         error('Communications Error - Input Record Too Long');
            %     case '130130'
            %         error('Communications Error - Invalid Input Data Record');
            %     case '130133'
            %         error('Communications Error - Aborted Due to Invalid Handshake');
            %     case '131128'
            %         error('Execution Error - Invalid 1st Command Parameter');
            %     case '131129'
            %         error('Execution Error - Invalid 2nd Command Parameter');
            %     case '131130'
            %         error('Execution Error - Invalid 3rd Command Parameter');
            %     case '131131'
            %         error('Execution Error - Invalid 4th Command Parameter');
            %     case '131132'
            %         error('Execution Error - Invalid Number of Parameters');
            %     case '131133'
            %         error('Execution Error - Invalid Data (Other Than Command Data');
            %     case '131134'
            %         error('Execution Error - Could Not Load Selected Value');
            %     case '131135'
            %         error('Execution Error - Counters Must Be Stopped But Were Not');
            %     case '131136'
            %         error('Execution Error - Start/Stop Trigger Must Be Disabled');
            %     otherwise
            %         error('More Than One Error Occurred');
            % end
            success = strcmp(reply(2:7),'000000');
        end

        function [M,N] = getScientificNotation(time)
            time = time * 10;
            N = floor(log10(time));
            M = round(time./10.^N);
        end

        function mask = getMask(channel1,channel2,channel3,channel4)
            mask = 0;
            if channel1
                mask = mask + 1;
            end
            if channel2
                mask = mask + 2;
            end
            if channel3
                mask = mask + 4;
            end
            if channel4
                mask = mask + 8;
            end
            mask = num2str(mask);
        end

        function mask = getIndividualMask(index)
            mask = Counter.getMask(index==1,index==2,index==3,index==4);
        end
    end
end
