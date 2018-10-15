classdef Photoluminescence < handle
    properties (SetAccess = private)
        counter
        driver
    end

    methods
        function obj = Photoluminescence()
        end

        function success = connectDriver(obj,comPort,baudRate)
            obj.driver = Driver(comPort,baudRate);
            success = obj.driver.setRemote();
        end

        function success = initializeDriver(obj)
            success = obj.driver.backlashAdjustment();
        end

        function setInitialPoisition(obj,position)
            obj.driver.setCurrentPosition(position);
        end

        function success = connectCounter(obj,boardIndex,primaryAddress)
            obj.counter = Counter(boardIndex,primaryAddress);
            success = obj.counter.setRemote();
        end

        function result = scan(obj,startPosition,endPosition,increment,integrationTime,graph)
            result = zeros((endPosition-startPosition)/increment+1,2);
            index = 1;
            obj.counter.setIntegrationTime(integrationTime)
            if obj.driver.currentPosition ~= startPosition
                success = obj.driver.moveTo(startPosition);
                while success && obj.driver.currentPosition <= endPosition
                    result(index,1) = obj.driver.currentPosition;
                    obj.counter.clearCounter(2);
                    obj.counter.startCounting();
                    pause(integrationTime);
                    result(index,2) = obj.counter.getCounter(2);
                    success = obj.driver.moveTo(obj.driver.currentPosition + increment);
                    index = index + 1;
                    plot(graph,result(1:index,1),result(1:index,2));
                end
            end
        end
    end
end
