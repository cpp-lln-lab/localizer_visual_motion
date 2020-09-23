% (C) Copyright 2020 CPP visual motion localizer developpers

function diplayDesign(cfg, displayFigs)

    %% Visualize the design matrix
    if displayFigs

        close all;

        figure(1);

        % Shows blocks (static and motion) and events (motion direction) order
        directions = cfg.design.directions;
        directions(directions == -1) = -90;

        subplot(3, 1, 1);
        imagesc(directions);

        labelAxesBlock();

        caxis([-90 - 37, 270 + 37]);
        myColorMap = lines(5);
        colormap(myColorMap);

        title('Block (static and motion) & Events (motion direction)');

        % Shows the fixation targets design in each event (1 or 0)
        fixationTargets = cfg.design.fixationTargets;

        subplot(3, 1, 2);
        imagesc(fixationTargets);
        labelAxesBlock();
        title('Fixation Targets design');
        colormap(gray);

        % Shows the fixation targets position distribution in the block across
        % the experimet
        [~, itargetPosition] = find(fixationTargets == 1);

        subplot(3, 1, 3);
        hist(itargetPosition);
        labelAxesFreq();
        title('Fixation Targets position distribution');

        figure(2);

        [motionDirections] = getDirectionBaseVectors(cfg);
        motionDirections = unique(motionDirections);

        for iMotion = 1:length(motionDirections)

            [~, position] = find(directions == motionDirections(iMotion));

            subplot(2, 2, iMotion);
            hist(position);
            scaleAxes();
            labelAxesFreq();
            title(num2str(motionDirections(iMotion)));

        end

    end

end

function labelAxesBlock()
    % an old viking saying because they really cared about their axes
    ylabel('Block seq.', 'Fontsize', 8);
    xlabel('Events', 'Fontsize', 8);
end

function labelAxesFreq()
    % an old viking saying because they really cared about their axes
    ylabel('Number of targets', 'Fontsize', 8);
    xlabel('Events', 'Fontsize', 8);
end

function scaleAxes()
    xlim([1 12]);
    ylim([0 5]);
end
