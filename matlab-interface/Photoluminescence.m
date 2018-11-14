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
        function saveScan(scanParameters,result)
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
            fprintf(file,'----------START OF SCAN RESULT----------\n');
            fprintf(file,'Wavelength,Photon Counts\n');
            for i = 1:length(result)
                fprintf(file,'%.2f,%d\n',result(i,1),result(i,2));
            end
            fclose(file);
        end

        function [scanParameters,result] = loadScan(fileName)
            scanParameters.fileName = fileName;
            file = fopen(fileName,'r');
            tline = fgetl(file);
            lineNum = 0;
            while ischar(tline) && ~strcmp(tline,'----------START OF SCAN RESULT----------')
                words = strsplit(tline,',');
                field = char(words(1));
                if length(words) > 1
                    value = char(words(2));
                end
                switch field
                    case 'Sample ID'
                        scanParameters.sampleID = value;
                    case 'Start Wavelength'
                        scanParameters.startWavelength = str2double(value);
                    case 'End Wavelength'
                        scanParameters.endWavelength = str2double(value);
                    case 'Wavelength Increment'
                        scanParameters.wavelengthIncrement = str2double(value);
                    case 'Integration Time'
                        scanParameters.integrationTime = str2double(value);
                    case 'Sample Temperature'
                        scanParameters.sampleTemperature = value;
                    case 'Attenuation'
                        scanParameters.attenuation = value;
                    case 'Magnification'
                        scanParameters.magnification = value;
                    case 'Laser Power'
                        scanParameters.laserPower = value;
                    case 'Slit Width'
                        scanParameters.slitWidth = value;
                    case 'Additional Notes'
                        scanParameters.additionalNotes = value;
                end
                lineNum = lineNum + 1;
                tline = fgetl(file);
            end
            fclose(file);
            result = csvread(fileName,lineNum+2,0);
        end

        function [scanParameters,result] = loadOldScan(fileName)
            scanParameters.fileName = fileName;
            file = fopen(fileName,'r');
            tline = fgetl(file);
            lineNum = 0;
            while ischar(tline) && ~strcmp(tline,'Wavelength  |  Photon Counts  |   Klinger Setting')
                words = strsplit(tline,':');
                field = char(words(1));
                if length(words) > 1
                    value = strip(char(words(2)));
                end
                switch field
                    case 'Sample ID'
                        scanParameters.sampleID = value;
                    case 'Starting Wavelength'
                        scanParameters.startWavelength = str2double(value);
                    case 'Ending Wavelength'
                        scanParameters.endWavelength = str2double(value);
                    case 'Wavelength Increment'
                        scanParameters.wavelengthIncrement = str2double(value);
                    case 'Integration Time'
                        scanParameters.integrationTime = str2double(value);
                    case 'Sample Temperature'
                        scanParameters.sampleTemperature = value;
                    case 'Attenuation'
                        scanParameters.attenuation = value;
                    case 'Magnification'
                        scanParameters.magnification = value;
                    case 'Laser Power'
                        scanParameters.laserPower = value;
                    case 'Slit Width'
                        scanParameters.slitWidth = value;
                    case 'Notes'
                        scanParameters.additionalNotes = value;
                end
                lineNum = lineNum + 1;
                tline = fgetl(file);
            end
            fclose(file);
            result = dlmread(fileName,' ',lineNum+2,0);
            result(:,3) = [];
        end

        function convertOldScan(oldFileName,newFileName)
            [scanParameters,result] = Photoluminescence.loadOldScan(oldFileName);
            scanParameters.fileName = newFileName;
            Photoluminescence.saveScan(scanParameters,result);
        end

        function plot(scanParameters,result)
        end
    end
end
