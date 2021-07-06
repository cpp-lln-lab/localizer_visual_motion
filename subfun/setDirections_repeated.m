% (C) Copyright 2020 CPP visual motion localizer developpers
%This function is adapted by Iqra Shahzad from setDirections.m. It creates a direction matrix A with 12
%events [0 180 270 90]. 
%Then it creates another direction matrix B such that the directions are
%paired (0,180) and (270,90)
%A and B are combined for their corresponding pairs, hence creating a
%matrix with 24 events
%The target matrix is also created similarly. The targets are present
%consecultively - to detect a consecutive event.

function cfg = setDirections_repeated(cfg)

    [CONDITION1_DIRECTIONS, CONDITION2_DIRECTIONS] = getDirectionBaseVectors(cfg);

    [NB_BLOCKS, NB_REPETITIONS, NB_EVENTS_PER_BLOCK] = getDesignInput(cfg); %for 24 events set in parameters.m, NB_EVENTS_PER_BLOCK=24

    [~, CONDITON1_INDEX, CONDITON2_INDEX] = assignConditions(cfg);

    if mod(NB_EVENTS_PER_BLOCK, length(CONDITION1_DIRECTIONS)) ~= 0
        error('Number of events/block not a multiple of number of motion/static direction');
    end

    % initialize
    directionsA = zeros(NB_BLOCKS, NB_EVENTS_PER_BLOCK/2); %directionsA is for 24/2

    % Create a vector for the static condition
    NB_REPEATS_BASE_VECTOR = (NB_EVENTS_PER_BLOCK/2) / length(CONDITION2_DIRECTIONS);

    static_directions = repmat( ...
                               CONDITION2_DIRECTIONS, ...
                               1, NB_REPEATS_BASE_VECTOR);

    for iMotionBlock = 1:NB_REPETITIONS

        if isfield(cfg.design, 'localizer') && strcmpi(cfg.design.localizer, 'MT_MST')

            % Set motion direction for MT/MST localizer

            directionsA(CONDITON1_INDEX(iMotionBlock), :) = ...
                repeatShuffleConditions(CONDITION1_DIRECTIONS, NB_REPEATS_BASE_VECTOR);

            directionsA(CONDITON2_INDEX(iMotionBlock), :) = ...
                repeatShuffleConditions(CONDITION1_DIRECTIONS, NB_REPEATS_BASE_VECTOR);

        else

            % Set motion direction and static order

            directionsA(CONDITON2_INDEX(iMotionBlock), :) = ...
                repeatShuffleConditions(CONDITION1_DIRECTIONS, NB_REPEATS_BASE_VECTOR);

            directionsA(CONDITON1_INDEX(iMotionBlock), :) = static_directions;  
        end

    end

    cfg.design.directionsA = directionsA;%%% direction matrix A with 12 events IQRA
    directionsB= changem(directionsA,[0, 180, 270, 90], [180, 0, 90, 270]);%creates another matrix B with values replaced for opposite directions
    
    %%%%create paired directions or direction  matrix with 24 events IQRA
    cfg.design.directions = zeros(size(directionsA,1), (size(directionsA,2)+size(directionsB,2)));
    
    for i=1:size(directionsA,2)
        cfg.design.directions(:,2*i-1) =directionsA(:,i);
        cfg.design.directions(:,2*i)=directionsB(:,i);
        
    end
    %%%create the direction matrix with targets for 24 events
    for j=1:size(cfg.design.fixationTargets,2)/2
        cfg.design.directions(:,2*j)=cfg.design.directions(:,2*j-1).*(cfg.design.fixationTargets(:,2*j-1).*cfg.design.fixationTargets(:,2*j))+cfg.design.directions(:,2*j).*(ones(size(cfg.design.fixationTargets,1),1)-cfg.design.fixationTargets(:,2*j-1).*cfg.design.fixationTargets(:,2*j));

    end
    
    
    cfg.design.directions
    
    
end
