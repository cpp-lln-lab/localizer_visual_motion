function [names,isMotion,isTarget,condition] = experimental_design(numBlocksPerCond,numEvents,range_targets,minDistanceBetTargets) 
% This function creates the design for the experiment. It takes as input the number
% of blocks, num of Events in each block, targets & returns 2 matrices (isMotion & isTarget) that
% will be used in the main experiment 
%eg. experimental_design(2,[2 4])

%  range_targets = [2 4];
%  numBlocksPerCond = 3 ;
%  numEvents = 12 ;
%  range_targets = [1 3] ;
%  minDistanceBetTargets = 2;
doPlot = 0;

%% Define the experiment and balance trials, and conditions
% the blocks are consequtive static and motion blocks (Gives better results than randomised).
% Assign the conditions
condition= repmat({'static','motion'}, 1,numBlocksPerCond);
nr_blocks= length(condition);

%% Get the index of each condition
staticIndex = find(strcmp(condition,'static')) ;
motionIndex = find(strcmp(condition,'motion')) ;

%% Assign the targets for each condition

% Get random number of targets for one condition
%target_perCondition = randi(range_targets,1,nr_trials/2);  
target_perCondition = randi(range_targets,1,numBlocksPerCond);  

% Assign the num of targets for each condition after shuffling
targets=zeros(nr_blocks,1);
targets(staticIndex) = Shuffle(target_perCondition) ;
targets(motionIndex) = Shuffle(target_perCondition) ;

%% Give the blocks the names with condition
names=cell(nr_blocks,1);  

% For each block
for block_nr = 1:nr_blocks
    if strcmp(condition(block_nr),'static')       % Give it the name static
        names(block_nr)={'static'};
    elseif strcmp(condition(block_nr),'motion')   % Or motion depending on the condition
        names(block_nr)={'motion'};
    end    
end

% Create a matrix indicating if it is a motion or static event
% the dimensions of the matrix are (num of Runs x num of Events)
isMotion = zeros(numBlocksPerCond,numEvents);
isMotion(strcmp(names,'motion'),:)=1 ; 

% Create a similar matrix for the targets 
% the dimensions of the matrix are (num of Runs x num of Events)
isTarget = zeros(numBlocksPerCond,numEvents);

for iBlock = 1:nr_blocks      % in each block                 
    % get the location of the targets (can be any number from the second event to the before last)    
    targetIdx = sort(randsample([2 : numEvents-1],targets(iBlock),0)); 

    % if there is more than one target
    if targetIdx>1 
        isDistanceShort = 1;          % check the distance between targets
        while isDistanceShort
            
            minTargetDistance = numEvents;      
            for iTarget = 2:length(targetIdx)                                   % for each target
                TargetDistance = abs(targetIdx(iTarget)-targetIdx(iTarget-1));  % check its distance with the previous target
                if TargetDistance < minTargetDistance                             
                    minTargetDistance = TargetDistance;
                end
            end
            % check if the minimum distance between targets is more than
            % the required limit
            isDistanceShort = minTargetDistance < minDistanceBetTargets;
            
            % if the distance is shorter than required, repeat the
            % selection and checking process.
            if isDistanceShort
                    targetIdx = sort(randsample([2 : numEvents-1],targets(iBlock),0));
            end
        end
        % assign the targets in the block to the "isTarget" Matrix
        isTarget(iBlock,targetIdx) = 1;
    end
    
end

% if the visualization of the runs and events are required
% you can check the motion/static and target/no target condition 
if doPlot
    figure()
    subplot(1,2,1); imagesc(isMotion);
    title('Motion')
    subplot(1,2,2); imagesc(isTarget);
    title('Targets')
end

end