classdef UserInterface < handle
    properties (Access = private)
        photoluminescence
        BaseUI
        TabGroup
        InstrumentSetupTab
        InstructionText
        ConfirmPowerDown
        ConfirmDriverPowerDown
        ConfirmCounterPowerDown
        ConfirmConnections
        ConfirmDriverConnection
        ConfirmCounterConnection
        DriverInitialization
        ConfirmDriver5VOn
        ConfirmDriverCOM
        DriverCOMLabel
        DriverCOM
        DriverBaudLabel
        DriverBaud
        ConnectDriver
        DriverStatusLabel
        DriverStatus
        TurnOnDriver12V
        BacklashAdjustment
        CounterInitialization
        TurnOnCounter
        ConfirmCounterAddress
        CounterBoardIndexLabel
        CounterBoardIndex
        CounterPrimaryAddressLabel
        CounterPrimaryAddress
        ConnectCounter
        CounterStatusLabel
        CounterStatus
        EnterWavelengthLabel
        EnterWavelength
        ScanSetupTab
        StartWavelengthLabel
        StartWavelength
        EndWavelengthLabel
        EndWavelength
        WavelengthIncrementLabel
        WavelengthIncrement
        IntegrationTimeLabel
        IntegrationTime
        SampleIDLabel
        SampleID
        SampleTemperatureLabel
        SampleTemperature
        AttenuationLabel
        Attenuation
        MagnificationLabel
        Magnification
        LaserPowerLabel
        LaserPower
        SlitWidthLabel
        SlitWidth
        AdditionalNotesLabel
        AdditionalNotes
        FileLocationLabel
        FileLocation
        ChangeFileLocation
        StartScan
        StopScan
        ScanResultTab
        PlotScaleLabel
        PlotScale
        Plot
    end

    properties (Access = private,Constant)
        ANG = char(197)
    end

    methods (Access = private)
        function createInterface(obj)
            obj.BaseUI = uifigure;
            obj.BaseUI.Name = 'Spectrometer';
            obj.BaseUI.Position = [1 41 800 600];
            obj.BaseUI.AutoResizeChildren = 'off';
            obj.BaseUI.SizeChangedFcn = @obj.BaseUISizeChange;

            obj.TabGroup = uitabgroup(obj.BaseUI);
            obj.TabGroup.Position = [1 1 obj.BaseUI.Position(3) obj.BaseUI.Position(4)];

            obj.InstrumentSetupTab = uitab(obj.TabGroup);
            obj.InstrumentSetupTab.Title = 'Instrument Setup';
            obj.InstrumentSetupTab.AutoResizeChildren = 'off';
            obj.InstrumentSetupTab.SizeChangedFcn = @obj.InstrumentSetupTabSizeChange;

            obj.InstructionText = uilabel(obj.InstrumentSetupTab);
            obj.InstructionText.Position = [0.05*obj.BaseUI.Position(3) 0.85*obj.BaseUI.Position(4) 600 22];
            obj.InstructionText.FontSize = 18;
            obj.InstructionText.FontWeight = 'bold';
            obj.InstructionText.Text = 'Follow the checklist below to properly start the instruments';

            obj.ConfirmPowerDown = uicheckbox(obj.InstrumentSetupTab);
            obj.ConfirmPowerDown.Position = [0.08*obj.BaseUI.Position(3) 0.8*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmPowerDown.Text = 'Confirm everything is powered down, this includes:';
            obj.ConfirmPowerDown.ValueChangedFcn = @obj.ConfirmPowerDownClick;

            obj.ConfirmDriverPowerDown = uicheckbox(obj.InstrumentSetupTab);
            obj.ConfirmDriverPowerDown.Position = [0.1*obj.BaseUI.Position(3) 0.76*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmDriverPowerDown.Text = 'Driver: 12V is turned off, 5V can be either turned on or off';
            obj.ConfirmDriverPowerDown.ValueChangedFcn = @obj.ConfirmDriverPowerDownClick;

            obj.ConfirmCounterPowerDown = uicheckbox(obj.InstrumentSetupTab);
            obj.ConfirmCounterPowerDown.Position = [0.1*obj.BaseUI.Position(3) 0.72*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmCounterPowerDown.Text = 'Counter: Entire system turned off';
            obj.ConfirmCounterPowerDown.ValueChangedFcn = @obj.ConfirmCounterPowerDownClick;

            obj.ConfirmConnections = uicheckbox(obj.InstrumentSetupTab);
            obj.ConfirmConnections.Position = [0.08*obj.BaseUI.Position(3) 0.68*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmConnections.Text = 'Confirm connections are properly made, this includes:';
            obj.ConfirmConnections.ValueChangedFcn = @obj.ConfirmConnectionsClick;

            obj.ConfirmDriverConnection = uicheckbox(obj.InstrumentSetupTab);
            obj.ConfirmDriverConnection.Position = [0.1*obj.BaseUI.Position(3) 0.64*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmDriverConnection.Text = 'Driver: Connect to the computer with the USB cable';
            obj.ConfirmDriverConnection.ValueChangedFcn = @obj.ConfirmDriverConnectionClick;

            obj.ConfirmCounterConnection = uicheckbox(obj.InstrumentSetupTab);
            obj.ConfirmCounterConnection.Position = [0.1*obj.BaseUI.Position(3) 0.6*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmCounterConnection.Text = 'Counter: Connect to the computer with the USB-GPIB cable';
            obj.ConfirmCounterConnection.ValueChangedFcn = @obj.ConfirmCounterConnectionClick;

            obj.DriverInitialization = uicheckbox(obj.InstrumentSetupTab);
            obj.DriverInitialization.Position = [0.08*obj.BaseUI.Position(3) 0.56*obj.BaseUI.Position(4) 600 22];
            obj.DriverInitialization.Text = 'Initialize the driver:';

            obj.ConfirmDriver5VOn = uicheckbox(obj.InstrumentSetupTab);
            obj.ConfirmDriver5VOn.Position = [0.1*obj.BaseUI.Position(3) 0.52*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmDriver5VOn.Text = 'Confirm the 5V is turned on for the driver';

            obj.ConfirmDriverCOM = uicheckbox(obj.InstrumentSetupTab);
            obj.ConfirmDriverCOM.Position = [0.1*obj.BaseUI.Position(3) 0.48*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmDriverCOM.Text = 'Confirm COM Port and Baud Rate of the driver below:';

            obj.DriverCOMLabel = uilabel(obj.InstrumentSetupTab);
            obj.DriverCOMLabel.Position = [0.12*obj.BaseUI.Position(3) 0.44*obj.BaseUI.Position(4) 100 22];
            obj.DriverCOMLabel.Text = 'COM Port';

            obj.DriverCOM = uidropdown(obj.InstrumentSetupTab);
            obj.DriverCOM.Position = [0.12*obj.BaseUI.Position(3)+100 0.44*obj.BaseUI.Position(4) 75 22];
            if length(seriallist) == 0
                obj.DriverCOM.Items = {'COM1','COM2','COM3','COM4','COM5','COM6','COM7','COM8','COM9','COM10'};
            else
                obj.DriverCOM.Items = seriallist;
            end

            obj.DriverBaudLabel = uilabel(obj.InstrumentSetupTab);
            obj.DriverBaudLabel.Position = [0.12*obj.BaseUI.Position(3)+250 0.44*obj.BaseUI.Position(4) 100 22];
            obj.DriverBaudLabel.Text = 'Baud Rate';

            obj.DriverBaud = uidropdown(obj.InstrumentSetupTab);
            obj.DriverBaud.Position = [0.12*obj.BaseUI.Position(3)+350 0.44*obj.BaseUI.Position(4) 75 22];
            obj.DriverBaud.Items = {'1200','2400','4800','9600','19200','38400','57600','115200'};
            obj.DriverBaud.Value = '9600';

            obj.ConnectDriver = uibutton(obj.InstrumentSetupTab,'push');
            obj.ConnectDriver.Position = [0.1*obj.BaseUI.Position(3) 0.4*obj.BaseUI.Position(4) 150 22];
            obj.ConnectDriver.Text = 'Connect Driver';
            obj.ConnectDriver.ButtonPushedFcn = @obj.ConnectDriverClick;

            obj.DriverStatusLabel = uilabel(obj.InstrumentSetupTab);
            obj.DriverStatusLabel.Position = [0.1*obj.BaseUI.Position(3)+200 0.4*obj.BaseUI.Position(4) 100 22];
            obj.DriverStatusLabel.Text = 'Driver Status';

            obj.DriverStatus = uilamp(obj.InstrumentSetupTab);
            obj.DriverStatus.Position = [0.1*obj.BaseUI.Position(3)+300 0.4*obj.BaseUI.Position(4) 20 20];
            obj.DriverStatus.Color = 'red';

            obj.TurnOnDriver12V = uicheckbox(obj.InstrumentSetupTab);
            obj.TurnOnDriver12V.Position = [0.1*obj.BaseUI.Position(3) 0.36*obj.BaseUI.Position(4) 600 22];
            obj.TurnOnDriver12V.Text = 'Turn on the 12V supply of the driver';

            obj.BacklashAdjustment = uibutton(obj.InstrumentSetupTab,'push');
            obj.BacklashAdjustment.Position = [0.1*obj.BaseUI.Position(3) 0.32*obj.BaseUI.Position(4) 150 22];
            obj.BacklashAdjustment.Text = 'Backlash Adjustment';
            obj.BacklashAdjustment.ButtonPushedFcn = @obj.BacklashAdjustmentClick;

            obj.CounterInitialization = uicheckbox(obj.InstrumentSetupTab);
            obj.CounterInitialization.Position = [0.08*obj.BaseUI.Position(3) 0.28*obj.BaseUI.Position(4) 600 22];
            obj.CounterInitialization.Text = 'Initialize the counter:';

            obj.TurnOnCounter = uicheckbox(obj.InstrumentSetupTab);
            obj.TurnOnCounter.Position = [0.1*obj.BaseUI.Position(3) 0.24*obj.BaseUI.Position(4) 600 22];
            obj.TurnOnCounter.Text = 'Turn on power supply of the counter';

            obj.ConfirmCounterAddress = uicheckbox(obj.InstrumentSetupTab);
            obj.ConfirmCounterAddress.Position = [0.1*obj.BaseUI.Position(3) 0.2*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmCounterAddress.Text = 'Confirm Board Index and Primary Address of the counter below:';

            obj.CounterBoardIndexLabel = uilabel(obj.InstrumentSetupTab);
            obj.CounterBoardIndexLabel.Position = [0.12*obj.BaseUI.Position(3) 0.16*obj.BaseUI.Position(4) 100 22];
            obj.CounterBoardIndexLabel.Text = 'Board Index';

            obj.CounterBoardIndex = uieditfield(obj.InstrumentSetupTab,'numeric');
            obj.CounterBoardIndex.Position = [0.12*obj.BaseUI.Position(3)+100 0.16*obj.BaseUI.Position(4) 75 22];
            obj.CounterBoardIndex.Limits = [0 14];

            obj.CounterPrimaryAddressLabel = uilabel(obj.InstrumentSetupTab);
            obj.CounterPrimaryAddressLabel.Position = [0.12*obj.BaseUI.Position(3)+250 0.16*obj.BaseUI.Position(4) 100 22];
            obj.CounterPrimaryAddressLabel.Text = 'Primary Address';

            obj.CounterPrimaryAddress = uieditfield(obj.InstrumentSetupTab,'numeric');
            obj.CounterPrimaryAddress.Position = [0.12*obj.BaseUI.Position(3)+350 0.16*obj.BaseUI.Position(4) 75 22];
            obj.CounterPrimaryAddress.Limits = [0 30];
            obj.CounterPrimaryAddress.Value = 26;

            obj.ConnectCounter = uibutton(obj.InstrumentSetupTab,'push');
            obj.ConnectCounter.Position = [0.1*obj.BaseUI.Position(3) 0.12*obj.BaseUI.Position(4) 150 22];
            obj.ConnectCounter.Text = 'Connect Counter';
            obj.ConnectCounter.ButtonPushedFcn = @obj.ConnectCounterClick;

            obj.CounterStatusLabel = uilabel(obj.InstrumentSetupTab);
            obj.CounterStatusLabel.Position = [0.1*obj.BaseUI.Position(3)+200 0.12*obj.BaseUI.Position(4) 100 22];
            obj.CounterStatusLabel.Text = 'Counter Status';

            obj.CounterStatus = uilamp(obj.InstrumentSetupTab);
            obj.CounterStatus.Position = [0.1*obj.BaseUI.Position(3)+300 0.12*obj.BaseUI.Position(4) 20 20];
            obj.CounterStatus.Color = 'red';

            obj.EnterWavelengthLabel = uilabel(obj.InstrumentSetupTab);
            obj.EnterWavelengthLabel.Position = [0.08*obj.BaseUI.Position(3) 0.08*obj.BaseUI.Position(4) 600 25];
            obj.EnterWavelengthLabel.Text = 'Enter spectrometer wavelength reading after backlash adjustment';

            obj.EnterWavelength = uieditfield(obj.InstrumentSetupTab, 'numeric');
            obj.EnterWavelength.Position = [0.08*obj.BaseUI.Position(3)+360 0.08*obj.BaseUI.Position(4) 100 22];
            obj.EnterWavelength.Limits = [0 10000];
            obj.EnterWavelength.ValueChangedFcn = @obj.EnterWavelengthClick;

            obj.ScanSetupTab = uitab(obj.TabGroup);
            obj.ScanSetupTab.Title = 'Scan Setup';
            obj.ScanSetupTab.AutoResizeChildren = 'off';
            obj.ScanSetupTab.SizeChangedFcn = @obj.ScanSetupTabSizeChange;

            obj.StartWavelengthLabel = uilabel(obj.ScanSetupTab);
            obj.StartWavelengthLabel.Position = [0.1*obj.BaseUI.Position(3) 0.85*obj.BaseUI.Position(4) 150 22];
            obj.StartWavelengthLabel.Text = strcat('Start Wavelength (',UserInterface.ANG,')');

            obj.StartWavelength = uieditfield(obj.ScanSetupTab,'numeric');
            obj.StartWavelength.Position = [0.1*obj.BaseUI.Position(3)+150 0.85*obj.BaseUI.Position(4) 75 22];
            obj.StartWavelength.Limits = [0 10000];

            obj.EndWavelengthLabel = uilabel(obj.ScanSetupTab);
            obj.EndWavelengthLabel.Position = [0.1*obj.BaseUI.Position(3)+350 0.85*obj.BaseUI.Position(4) 150 22];
            obj.EndWavelengthLabel.Text = strcat('End Wavelength (',UserInterface.ANG,')');

            obj.EndWavelength = uieditfield(obj.ScanSetupTab,'numeric');
            obj.EndWavelength.Position = [0.1*obj.BaseUI.Position(3)+500 0.85*obj.BaseUI.Position(4) 75 22];
            obj.EndWavelength.Limits = [0 10000];

            obj.WavelengthIncrementLabel = uilabel(obj.ScanSetupTab);
            obj.WavelengthIncrementLabel.Position = [0.1*obj.BaseUI.Position(3) 0.8*obj.BaseUI.Position(4) 150 22];
            obj.WavelengthIncrementLabel.Text = strcat('Wavelength Increment (',UserInterface.ANG,')');

            obj.WavelengthIncrement = uieditfield(obj.ScanSetupTab,'numeric');
            obj.WavelengthIncrement.Position = [0.1*obj.BaseUI.Position(3)+150 0.8*obj.BaseUI.Position(4) 75 22];
            obj.WavelengthIncrement.Limits = [0 10000];

            obj.IntegrationTimeLabel = uilabel(obj.ScanSetupTab);
            obj.IntegrationTimeLabel.Position = [0.1*obj.BaseUI.Position(3)+350 0.8*obj.BaseUI.Position(4) 150 22];
            obj.IntegrationTimeLabel.Text = 'IntegrationTime (s)';

            obj.IntegrationTime = uieditfield(obj.ScanSetupTab,'numeric');
            obj.IntegrationTime.Position = [0.1*obj.BaseUI.Position(3)+500 0.8*obj.BaseUI.Position(4) 75 22];
            obj.IntegrationTime.Limits = [0 10000];

            obj.SampleIDLabel = uilabel(obj.ScanSetupTab);
            obj.SampleIDLabel.Position = [0.1*obj.BaseUI.Position(3) 0.7*obj.BaseUI.Position(4) 150 22];
            obj.SampleIDLabel.Text = 'Sample ID';

            obj.SampleID = uieditfield(obj.ScanSetupTab,'text');
            obj.SampleID.Position = [0.1*obj.BaseUI.Position(3)+150 0.7*obj.BaseUI.Position(4) 75 22];

            obj.SampleTemperatureLabel = uilabel(obj.ScanSetupTab);
            obj.SampleTemperatureLabel.Position = [0.1*obj.BaseUI.Position(3)+350 0.7*obj.BaseUI.Position(4) 150 22];
            obj.SampleTemperatureLabel.Text = 'Sample Temperature';

            obj.SampleTemperature = uieditfield(obj.ScanSetupTab,'text');
            obj.SampleTemperature.Position = [0.1*obj.BaseUI.Position(3)+500 0.7*obj.BaseUI.Position(4) 75 22];

            obj.AttenuationLabel = uilabel(obj.ScanSetupTab);
            obj.AttenuationLabel.Position = [0.1*obj.BaseUI.Position(3) 0.65*obj.BaseUI.Position(4) 150 22];
            obj.AttenuationLabel.Text = 'Attenuation';

            obj.Attenuation = uieditfield(obj.ScanSetupTab,'text');
            obj.Attenuation.Position = [0.1*obj.BaseUI.Position(3)+150 0.65*obj.BaseUI.Position(4) 75 22];

            obj.MagnificationLabel = uilabel(obj.ScanSetupTab);
            obj.MagnificationLabel.Position = [0.1*obj.BaseUI.Position(3)+350 0.65*obj.BaseUI.Position(4) 150 22];
            obj.MagnificationLabel.Text = 'Magnification';

            obj.Magnification = uieditfield(obj.ScanSetupTab,'text');
            obj.Magnification.Position = [0.1*obj.BaseUI.Position(3)+500 0.65*obj.BaseUI.Position(4) 75 22];

            obj.LaserPowerLabel = uilabel(obj.ScanSetupTab);
            obj.LaserPowerLabel.Position = [0.1*obj.BaseUI.Position(3) 0.6*obj.BaseUI.Position(4) 150 22];
            obj.LaserPowerLabel.Text = 'Laser Power';

            obj.LaserPower = uieditfield(obj.ScanSetupTab,'text');
            obj.LaserPower.Position = [0.1*obj.BaseUI.Position(3)+150 0.6*obj.BaseUI.Position(4) 75 22];

            obj.SlitWidthLabel = uilabel(obj.ScanSetupTab);
            obj.SlitWidthLabel.Position = [0.1*obj.BaseUI.Position(3)+350 0.6*obj.BaseUI.Position(4) 150 22];
            obj.SlitWidthLabel.Text = 'Slit Width';

            obj.SlitWidth = uieditfield(obj.ScanSetupTab,'text');
            obj.SlitWidth.Position = [0.1*obj.BaseUI.Position(3)+500 0.6*obj.BaseUI.Position(4) 75 22];

            obj.AdditionalNotesLabel = uilabel(obj.ScanSetupTab);
            obj.AdditionalNotesLabel.Position = [0.1*obj.BaseUI.Position(3) 0.55*obj.BaseUI.Position(4) 150 22];
            obj.AdditionalNotesLabel.Text = 'Additional Notes';

            obj.AdditionalNotes = uitextarea(obj.ScanSetupTab);
            obj.AdditionalNotes.Position = [0.1*obj.BaseUI.Position(3)+150 0.55*obj.BaseUI.Position(4)-80+22 425 80];

            obj.FileLocationLabel = uilabel(obj.ScanSetupTab);
            obj.FileLocationLabel.Position = [0.1*obj.BaseUI.Position(3) 0.35*obj.BaseUI.Position(4) 150 22];
            obj.FileLocationLabel.Text = 'Save Result To';

            obj.FileLocation = uieditfield(obj.ScanSetupTab,'text');
            obj.FileLocation.Position = [0.1*obj.BaseUI.Position(3)+150 0.35*obj.BaseUI.Position(4) 400 22];

            obj.ChangeFileLocation = uibutton(obj.ScanSetupTab,'push');
            obj.ChangeFileLocation.Position = [0.1*obj.BaseUI.Position(3)+550 0.35*obj.BaseUI.Position(4) 50 22];
            obj.ChangeFileLocation.Text = 'Change';
            obj.ChangeFileLocation.ButtonPushedFcn = @obj.ChangeFileLocationClick;

            obj.StartScan = uibutton(obj.ScanSetupTab,'push');
            obj.StartScan.Position = [0.2*obj.BaseUI.Position(3) 0.15*obj.BaseUI.Position(4) 150 50];
            obj.StartScan.FontSize = 22;
            obj.StartScan.Text = 'Start Scan';
            obj.StartScan.ButtonPushedFcn = @obj.StartScanClick;

            obj.StopScan = uibutton(obj.ScanSetupTab,'push');
            obj.StopScan.Position = [0.2*obj.BaseUI.Position(3)+250 0.15*obj.BaseUI.Position(4) 150 50];
            obj.StopScan.FontSize = 22;
            obj.StopScan.Text = 'Stop Scan';
            obj.StopScan.ButtonPushedFcn = @obj.StopScanClick;

            obj.ScanResultTab = uitab(obj.TabGroup);
            obj.ScanResultTab.Title = 'Scan Result';
            obj.ScanResultTab.AutoResizeChildren = 'off';
            obj.ScanResultTab.SizeChangedFcn = @obj.ScanResultTabSizeChange;

            obj.PlotScaleLabel = uilabel(obj.ScanResultTab);
            obj.PlotScaleLabel.Position = [20 obj.BaseUI.Position(4)-60 100 22];
            obj.PlotScaleLabel.Text = 'Plot Scale';

            obj.PlotScale = uidropdown(obj.ScanResultTab);
            obj.PlotScale.Position = [120 obj.BaseUI.Position(4)-60 75 22];
            obj.PlotScale.Items = {'Linear','Log'};
            obj.PlotScale.ValueChangedFcn = @obj.PlotScaleClick;

            obj.Plot = uiaxes(obj.ScanResultTab);
            obj.Plot.Position = [20 20 obj.BaseUI.Position(3)-40 obj.BaseUI.Position(4)-100];
            obj.Plot.Box = 'on';
            title(obj.Plot,'Result');
            xlabel(obj.Plot,strcat('Wavelength (',UserInterface.ANG,')'));
            ylabel(obj.Plot,'Photon Count');
        end

        function BaseUISizeChange(obj,src,event)
            obj.TabGroup.Position = [1 1 obj.BaseUI.Position(3) obj.BaseUI.Position(4)];
        end

        function InstrumentSetupTabSizeChange(obj,src,event)
            obj.InstructionText.Position = [0.05*obj.BaseUI.Position(3) 0.85*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmPowerDown.Position = [0.08*obj.BaseUI.Position(3) 0.8*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmDriverPowerDown.Position = [0.1*obj.BaseUI.Position(3) 0.76*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmCounterPowerDown.Position = [0.1*obj.BaseUI.Position(3) 0.72*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmConnections.Position = [0.08*obj.BaseUI.Position(3) 0.68*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmDriverConnection.Position = [0.1*obj.BaseUI.Position(3) 0.64*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmCounterConnection.Position = [0.1*obj.BaseUI.Position(3) 0.6*obj.BaseUI.Position(4) 600 22];
            obj.DriverInitialization.Position = [0.08*obj.BaseUI.Position(3) 0.56*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmDriver5VOn.Position = [0.1*obj.BaseUI.Position(3) 0.52*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmDriverCOM.Position = [0.1*obj.BaseUI.Position(3) 0.48*obj.BaseUI.Position(4) 600 22];
            obj.DriverCOMLabel.Position = [0.12*obj.BaseUI.Position(3) 0.44*obj.BaseUI.Position(4) 100 22];
            obj.DriverCOM.Position = [0.12*obj.BaseUI.Position(3)+100 0.44*obj.BaseUI.Position(4) 75 22];
            obj.DriverBaudLabel.Position = [0.12*obj.BaseUI.Position(3)+250 0.44*obj.BaseUI.Position(4) 100 22];
            obj.DriverBaud.Position = [0.12*obj.BaseUI.Position(3)+350 0.44*obj.BaseUI.Position(4) 75 22];
            obj.ConnectDriver.Position = [0.1*obj.BaseUI.Position(3) 0.4*obj.BaseUI.Position(4) 150 22];
            obj.DriverStatusLabel.Position = [0.1*obj.BaseUI.Position(3)+200 0.4*obj.BaseUI.Position(4) 100 22];
            obj.DriverStatus.Position = [0.1*obj.BaseUI.Position(3)+300 0.4*obj.BaseUI.Position(4) 20 20];
            obj.TurnOnDriver12V.Position = [0.1*obj.BaseUI.Position(3) 0.36*obj.BaseUI.Position(4) 600 22];
            obj.BacklashAdjustment.Position = [0.1*obj.BaseUI.Position(3) 0.32*obj.BaseUI.Position(4) 150 22];
            obj.CounterInitialization.Position = [0.08*obj.BaseUI.Position(3) 0.28*obj.BaseUI.Position(4) 600 22];
            obj.TurnOnCounter.Position = [0.1*obj.BaseUI.Position(3) 0.24*obj.BaseUI.Position(4) 600 22];
            obj.ConfirmCounterAddress.Position = [0.1*obj.BaseUI.Position(3) 0.2*obj.BaseUI.Position(4) 600 22];
            obj.CounterBoardIndexLabel.Position = [0.12*obj.BaseUI.Position(3) 0.16*obj.BaseUI.Position(4) 100 22];
            obj.CounterBoardIndex.Position = [0.12*obj.BaseUI.Position(3)+100 0.16*obj.BaseUI.Position(4) 75 22];
            obj.CounterPrimaryAddressLabel.Position = [0.12*obj.BaseUI.Position(3)+250 0.16*obj.BaseUI.Position(4) 100 22];
            obj.CounterPrimaryAddress.Position = [0.12*obj.BaseUI.Position(3)+350 0.16*obj.BaseUI.Position(4) 75 22];
            obj.ConnectCounter.Position = [0.1*obj.BaseUI.Position(3) 0.12*obj.BaseUI.Position(4) 150 22];
            obj.CounterStatusLabel.Position = [0.1*obj.BaseUI.Position(3)+200 0.12*obj.BaseUI.Position(4) 100 22];
            obj.CounterStatus.Position = [0.1*obj.BaseUI.Position(3)+300 0.12*obj.BaseUI.Position(4) 20 20];
            obj.EnterWavelengthLabel.Position = [0.08*obj.BaseUI.Position(3) 0.08*obj.BaseUI.Position(4) 600 25];
            obj.EnterWavelength.Position = [0.08*obj.BaseUI.Position(3)+360 0.08*obj.BaseUI.Position(4) 100 22];
        end

        function ScanSetupTabSizeChange(obj,src,event)
            obj.StartWavelengthLabel.Position = [0.1*obj.BaseUI.Position(3) 0.85*obj.BaseUI.Position(4) 150 22];
            obj.StartWavelength.Position = [0.1*obj.BaseUI.Position(3)+150 0.85*obj.BaseUI.Position(4) 75 22];
            obj.EndWavelengthLabel.Position = [0.1*obj.BaseUI.Position(3)+350 0.85*obj.BaseUI.Position(4) 150 22];
            obj.EndWavelength.Position = [0.1*obj.BaseUI.Position(3)+500 0.85*obj.BaseUI.Position(4) 75 22];
            obj.WavelengthIncrementLabel.Position = [0.1*obj.BaseUI.Position(3) 0.8*obj.BaseUI.Position(4) 150 22];
            obj.WavelengthIncrement.Position = [0.1*obj.BaseUI.Position(3)+150 0.8*obj.BaseUI.Position(4) 75 22];
            obj.IntegrationTimeLabel.Position = [0.1*obj.BaseUI.Position(3)+350 0.8*obj.BaseUI.Position(4) 150 22];
            obj.IntegrationTime.Position = [0.1*obj.BaseUI.Position(3)+500 0.8*obj.BaseUI.Position(4) 75 22];
            obj.SampleIDLabel.Position = [0.1*obj.BaseUI.Position(3) 0.7*obj.BaseUI.Position(4) 150 22];
            obj.SampleID.Position = [0.1*obj.BaseUI.Position(3)+150 0.7*obj.BaseUI.Position(4) 75 22];
            obj.SampleTemperatureLabel.Position = [0.1*obj.BaseUI.Position(3)+350 0.7*obj.BaseUI.Position(4) 150 22];
            obj.SampleTemperature.Position = [0.1*obj.BaseUI.Position(3)+500 0.7*obj.BaseUI.Position(4) 75 22];
            obj.AttenuationLabel.Position = [0.1*obj.BaseUI.Position(3) 0.65*obj.BaseUI.Position(4) 150 22];
            obj.Attenuation.Position = [0.1*obj.BaseUI.Position(3)+150 0.65*obj.BaseUI.Position(4) 75 22];
            obj.MagnificationLabel.Position = [0.1*obj.BaseUI.Position(3)+350 0.65*obj.BaseUI.Position(4) 150 22];
            obj.Magnification.Position = [0.1*obj.BaseUI.Position(3)+500 0.65*obj.BaseUI.Position(4) 75 22];
            obj.LaserPowerLabel.Position = [0.1*obj.BaseUI.Position(3) 0.6*obj.BaseUI.Position(4) 150 22];
            obj.LaserPower.Position = [0.1*obj.BaseUI.Position(3)+150 0.6*obj.BaseUI.Position(4) 75 22];
            obj.SlitWidthLabel.Position = [0.1*obj.BaseUI.Position(3)+350 0.6*obj.BaseUI.Position(4) 150 22];
            obj.SlitWidth.Position = [0.1*obj.BaseUI.Position(3)+500 0.6*obj.BaseUI.Position(4) 75 22];
            obj.AdditionalNotesLabel.Position = [0.1*obj.BaseUI.Position(3) 0.55*obj.BaseUI.Position(4) 150 22];
            obj.AdditionalNotes.Position = [0.1*obj.BaseUI.Position(3)+150 0.55*obj.BaseUI.Position(4)-80+22 425 80];
            obj.FileLocationLabel.Position = [0.1*obj.BaseUI.Position(3) 0.35*obj.BaseUI.Position(4) 150 22];
            obj.FileLocation.Position = [0.1*obj.BaseUI.Position(3)+150 0.35*obj.BaseUI.Position(4) 400 22];
            obj.ChangeFileLocation.Position = [0.1*obj.BaseUI.Position(3)+550 0.35*obj.BaseUI.Position(4) 50 22];
            obj.StartScan.Position = [0.2*obj.BaseUI.Position(3) 0.15*obj.BaseUI.Position(4) 150 50];
            obj.StopScan.Position = [0.2*obj.BaseUI.Position(3)+250 0.15*obj.BaseUI.Position(4) 150 50];
        end

        function ScanResultTabSizeChange(obj,src,event)
            obj.PlotScaleLabel.Position = [20 obj.BaseUI.Position(4)-60 100 22];
            obj.PlotScale.Position = [120 obj.BaseUI.Position(4)-60 75 22];
            obj.Plot.Position = [20 20 obj.BaseUI.Position(3)-40 obj.BaseUI.Position(4)-100];
        end

        function ConfirmPowerDownClick(obj,src,event)
            if obj.ConfirmPowerDown.Value
                obj.ConfirmDriverPowerDown.Value = true;
                obj.ConfirmCounterPowerDown.Value = true;
            else
                obj.ConfirmDriverPowerDown.Value = false;
                obj.ConfirmCounterPowerDown.Value = false;
            end
        end

        function ConfirmDriverPowerDownClick(obj,src,event)
            if obj.ConfirmDriverPowerDown.Value && obj.ConfirmCounterPowerDown.Value
                obj.ConfirmPowerDown.Value = true;
            else
                obj.ConfirmPowerDown.Value = false;
            end
        end

        function ConfirmCounterPowerDownClick(obj,src,event)
            if obj.ConfirmCounterPowerDown.Value && obj.ConfirmDriverPowerDown.Value
                obj.ConfirmPowerDown.Value = true;
            else
                obj.ConfirmPowerDown.Value = false;
            end
        end

        function ConfirmConnectionsClick(obj,src,event)
            if obj.ConfirmConnections.Value
                obj.ConfirmDriverConnection.Value = true;
                obj.ConfirmCounterConnection.Value = true;
            else
                obj.ConfirmDriverConnection.Value = false;
                obj.ConfirmCounterConnection.Value = false;
            end
        end

        function ConfirmDriverConnectionClick(obj,src,event)
            if obj.ConfirmDriverConnection.Value && obj.ConfirmCounterConnection.Value
                obj.ConfirmConnections.Value = true;
            else
                obj.ConfirmConnections.Value = false;
            end
        end

        function ConfirmCounterConnectionClick(obj,src,event)
            if obj.ConfirmCounterConnection.Value && obj.ConfirmDriverConnection.Value
                obj.ConfirmConnections.Value = true;
            else
                obj.ConfirmConnections.Value = false;
            end
        end

        function ConnectDriverClick(obj,src,event)
            if obj.ConfirmPowerDown.Value && obj.ConfirmConnections.Value && obj.ConfirmDriver5VOn.Value && obj.ConfirmDriverCOM.Value
                if obj.photoluminescence.connectDriver(obj.DriverCOM.Value,str2double(obj.DriverBaud.Value))
                    obj.DriverStatus.Color = 'green';
                end
            end
        end

        function BacklashAdjustmentClick(obj,src,event)
            if all(eq(obj.DriverStatus.Color,[0,1,0])) && obj.TurnOnDriver12V.Value
                if obj.photoluminescence.backlashAdjustment()
                    obj.DriverInitialization.Value = true;
                end
            end
        end

        function ConnectCounterClick(obj,src,event)
            if obj.ConfirmPowerDown.Value && obj.ConfirmConnections.Value && obj.TurnOnCounter.Value && obj.ConfirmCounterAddress.Value
                if obj.photoluminescence.connectCounter(obj.CounterBoardIndex.Value,obj.CounterPrimaryAddress.Value)
                    obj.CounterStatus.Color = 'green';
                    obj.CounterInitialization.Value = true;
                end
            end
        end

        function EnterWavelengthClick(obj,src,event)
            if obj.ConfirmPowerDown.Value && obj.ConfirmConnections.Value && obj.DriverInitialization.Value && obj.CounterInitialization.Value
                obj.photoluminescence.setInitialPosition(obj.EnterWavelength.Value);
            else
                errordlg('Entering wavelength requires all items in the checklist to be completed.','Checklist Incomplete');
            end
        end

        function ChangeFileLocationClick(obj,src,event)
            [file,path] = uiputfile();
            obj.FileLocation.Value = strcat(path,file);
        end

        function StartScanClick(obj,src,event)
            scanParameters.startWavelength = obj.StartWavelength.Value;
            scanParameters.endWavelength = obj.EndWavelength.Value;
            scanParameters.wavelengthIncrement = obj.WavelengthIncrement.Value;
            scanParameters.integrationTime = obj.IntegrationTime.Value;
            scanParameters.sampleID = obj.SampleID.Value;
            scanParameters.sampleTemperature = obj.SampleTemperature.Value;
            scanParameters.attenuation = obj.Attenuation.Value;
            scanParameters.magnification = obj.Magnification.Value;
            scanParameters.laserPower = obj.LaserPower.Value;
            scanParameters.slitWidth = obj.SlitWidth.Value;
            scanParameters.additionalNotes = char(obj.AdditionalNotes.Value);
            scanParameters.fileName = obj.FileLocation.Value;
            result = obj.photoluminescence.scan(scanParameters,obj.Plot);
            Photoluminescence.saveResult(scanParameters,result);
        end

        function StopScanClick(obj,src,event)
        end

        function PlotScaleClick(obj,src,event)
            switch obj.PlotScale.Value
                case 'Linear'
                    obj.Plot.YScale = 'linear';
                case 'Log'
                    obj.Plot.YScale = 'log';
            end
        end
    end

    methods (Access = public)
        function obj = UserInterface()
            obj.createInterface();
            obj.photoluminescence = Photoluminescence();
        end
    end
end
