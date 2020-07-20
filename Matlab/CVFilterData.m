function [ fig, ax, filterCVData ] = CVFilterData( testNum ) 
    % something like testNum = '15.5.3.2.1';
    
    CVData = csvread(['Data\Test ', testNum, '.csv']);
    load(['Data\Test ', testNum, '.mat']);
    fig = figure;
    ax = axes;
    %dataColourOptions = ['r', 'g', 'b', 'c','m','k', 'y'];
    dataColourOptions = linspace(0, 0.9, cycleNumber)';
    dataColourOptions = [dataColourOptions, dataColourOptions, dataColourOptions];
    
    datapointsPerCycle = find(CVData(1,:) == 0);
    datapointsPerCycle = datapointsPerCycle(3) - 1;

    filterCVData = zeros(size(CVData));
    filterCVData(2,1) = CVData(2,1);
    filterCVData(1,:) = CVData(1,:);

    oldDataWeight = 0.7;
    newDataWeight = 1-oldDataWeight;

    sharpOldDataWeight = 0.4;
    sharpNewDataWeight = 1-sharpOldDataWeight;

    % Filter the response
    for i = 2: size(CVData, 2)
        if abs(filterCVData(2,i-1) - CVData(2,i)) > 0.00025
            filterCVData(2,i) = sharpOldDataWeight*filterCVData(2,i-1) + sharpNewDataWeight*CVData(2,i);
            %filterCVData(2,i) = CVData(2,i);
        else
           filterCVData(2,i) = oldDataWeight*filterCVData(2,i-1) + newDataWeight*CVData(2,i);
        end
    end

    %scatter(ax, CVData(1,:), CVData(2, :), 'MarkerFaceColor', 'b');

    for i = 1:cycleNumber
        minCycleDataPoint = 1 + (i-1)*datapointsPerCycle;
        maxCycleDataPoint = i*datapointsPerCycle;

        if maxCycleDataPoint > size(filterCVData, 2)
            maxCycleDataPoint = size(filterCVData, 2);
        end

        hold on
        h = plot(ax, filterCVData(1,minCycleDataPoint:maxCycleDataPoint), filterCVData(2, minCycleDataPoint:maxCycleDataPoint));
        h.Color =  dataColourOptions(i, :);
        h.LineWidth = 2;
    end

    legendLocation = 'southeast';
    switch cycleNumber
        case 1
            legend('Cycle 1', 'Location', legendLocation);
        case 2
            legend('Cycle 1', 'Cycle 2', 'Location', legendLocation);
        case 3
            legend('Cycle 1', 'Cycle 2', 'Cycle 3', 'Location', legendLocation);
        case 4
            legend('Cycle 1', 'Cycle 2', 'Cycle 3', 'Cycle 4', 'Location', legendLocation);
        case 5
            legend('Cycle 1', 'Cycle 2', 'Cycle 3', 'Cycle 4', 'Cycle 5', 'Location', legendLocation);
        case 6
            legend('Cycle 1', 'Cycle 2', 'Cycle 3', 'Cycle 4', 'Cycle 5', 'Cycle 6', 'Location', legendLocation);
        case 7
            legend('Cycle 1', 'Cycle 2', 'Cycle 3', 'Cycle 4', 'Cycle 5', 'Cycle 6', 'Cycle 7', 'Location', legendLocation);
        case 8
            legend('Cycle 1', 'Cycle 2', 'Cycle 3', 'Cycle 4', 'Cycle 5', 'Cycle 6', 'Cycle 7', 'Cycle 8', 'Location', legendLocation);
        case 9
            legend('Cycle 1', 'Cycle 2', 'Cycle 3', 'Cycle 4', 'Cycle 5', 'Cycle 6', 'Cycle 7', 'Cycle 8', 'Cycle 9', 'Location', legendLocation);
        case 10
            legend('Cycle 1', 'Cycle 2', 'Cycle 3', 'Cycle 4', 'Cycle 5', 'Cycle 6', 'Cycle 7', 'Cycle 8', 'Cycle 9', 'Cycle 10', 'Location', legendLocation);
    end
    
    ax.YLabel.String = 'Current [mA]';
    ax.XLabel.String = 'Potential [V vs. Ag/Ag+]';