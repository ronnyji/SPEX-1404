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
            if obj.driver.verifyReady()
                success = obj.driver.setRemote();
            end
        end

        function success = backlashAdjustment(obj)
            success = obj.driver.backlashAdjustment();
        end

        function setInitialPosition(obj,position)
            obj.driver.setCurrentPosition(position);
        end

        function success = connectCounter(obj,boardIndex,primaryAddress)
            obj.counter = Counter(boardIndex,primaryAddress);
            if obj.counter.verifyReady()
                success = obj.counter.setRemote(true);
            end
        end

        function result = scan(obj,scanParameters,graph)
            startPosition = scanParameters.startWavelength;
            endPosition = scanParameters.endWavelength;
            increment = scanParameters.wavelengthIncrement;
            integrationTime = scanParameters.integrationTime;
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

    methods (Static)
        function saveResult(scanParameters,result)
            file = fopen(scanParameters.fileName,'a');
            fprintf(file,'Sample ID,%s\n',scanParameters.sampleID);
            fprintf(file,'Start Wavelength,%.2f\n',scanParameters.startWavelength);
            fprintf(file,'End Wavelength,%.2f\n',scanParameters.endWavelength);
            fprintf(file,'Wavelength Increment,%.2f\n',scanParameters.wavelengthIncrement);
            fprintf(file,'Integration Time,%.1f\n',scanParameters.integrationTime);
            fprintf(file,'Sample Temperature,%s\n',scanParameters.sampleTemperature);
            fprintf(file,'Attenuation,%s\n',scanParameters.attenuation);
            fprintf(file,'Magnification,%s\n',scanParameters.magnification);
            fprintf(file,'Laser Power,%s\n',scanParameters.laserPower);
            fprintf(file,'Slit Width,%s\n',scanParameters.slitWidth);
            fprintf(file,'Additional Notes,%s\n',scanParameters.additionalNotes);
            fprintf(file,'\n');
            fprintf(file,'Wavelength,Photon Counts\n');
            for i = 1:length(result)
                fprintf(file,'%.2f,%d\n',result(i,1),result(i,2));
            end
            fclose(file);
        end

        function plot()
        end
    end
end
