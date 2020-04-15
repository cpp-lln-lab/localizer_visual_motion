function [expParameters] = expDesign(expParameters, displayFigs)
% Creates the sequence of blocks and the events in them
%
% The conditions are consecutive static and motion blocks (Gives better results than randomised).
%
% EVENTS
%  The numEventsPerBlock should be a multiple of the number of "base"
%  listed in the motionDirections and staticDirections (4 at the moment).
%  Pseudorandomization rules:
%  (1) Directions are all present in random orders in `numEventsPerBlock/nDirections`
%      consecutive chunks. This evenly distribute the directions across the
%      block.
%  (2) No same consecutive direction (TO IMPLEMENT)
%
% TARGETS
%  Pseudorandomization rules:
%  (1) If there are 2 targets per block we make sure that they are at least 2
%      events apart.
%  (2) Targets cannot be on the first or last event of a block.
%  (3) Targets can not be present more than 2 times in the same event
%      position across blocks.
%
% Input:
%   - ExpParameters: parameters returned by SetParameters
%   - displayFigs: a boolean to decide whether to show the basic design
%   matrix of the design
%
% Output:
%   - ExpParameters.designBlockNames      = cell array (nr_blocks, 1) with the
%    name for each block
%
%   - ExpParameters.designDirections      = array (nr_blocks, numEventsPerBlock)
%    with the direction to present in a given block
%       - 0 90 180 270 indicate the angle
%       - -1 indicates static
%
%   - ExpParameters.designSpeeds          = array (nr_blocks, numEventsPerBlock) * speedEvent;
%
%   - ExpParameters.designFixationTargets = array (nr_blocks, numEventsPerBlock)
%   showing for each event if it should be accompanied by a target
%

% needed to use the randsample function in octave
if IsOctave
    pkg load statistics
end

% Set directions for static and motion condition
motionDirections = [0 90 180 270];
staticDirections = [-1 -1 -1 -1];


%% Check inputs

% Set variables here for a dummy test of this function
if nargin < 1 || isempty(expParameters)
    expParameters.names             = {'static', 'motion'};
    expParameters.numRepetitions    = 4;
    expParameters.speedEvent        = 4;
    expParameters.numEventsPerBlock = 12;
    expParameters.maxNumFixationTargetPerBlock = 2;
end

% Set to 1 for a visualtion of the trials design order in case of you want
%   to run the script as stand-alone
if nargin == 0  || ~isempty(displayFigs)
    displayFigs = 1;
end

% Get the parameters
names = expParameters.names;
numRepetitions = expParameters.numRepetitions;
speedEvent = expParameters.speedEvent;
numEventsPerBlock = expParameters.numEventsPerBlock;
maxNumFixTargPerBlock = expParameters.maxNumFixationTargetPerBlock;

if mod(numEventsPerBlock, length(motionDirections))~=0
    warning('the number of events per block is not a multiple of the number of motion/static diection')
end


%% Adapt some variables according to input

% Assign the conditions
condition = repmat(names, 1, numRepetitions);
nrBlocks = length(condition);

% Assigne design parameters to be exported
expParameters.designBlockNames      = cell(nrBlocks, 1);
expParameters.designDirections      = zeros(nrBlocks, numEventsPerBlock);
expParameters.designSpeeds          = ones(nrBlocks, numEventsPerBlock) * speedEvent;
expParameters.designFixationTargets = zeros(nrBlocks, numEventsPerBlock);

% Create a vector for the static condition
staticDirections = repmat(staticDirections, 1, numEventsPerBlock/length(staticDirections));

% Get the index of each condition
staticIndex = find( strcmp(condition, 'static') );
motionIndex = find( strcmp(condition, 'motion') );

for iMotionBlock = 1:numRepetitions
    
    % Shuffle and set motion direction order
    expParameters.designDirections(motionIndex(iMotionBlock),:) = ...
        [ Shuffle(motionDirections), Shuffle(motionDirections), Shuffle(motionDirections)];
    
    % Set static condition
    expParameters.designDirections(staticIndex(iMotionBlock),:) = staticDirections;
    
end

% Assign the targets for each condition
rangeTargets = [1 maxNumFixTargPerBlock];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % % IT COULD BE A PROBLEM IF WE SET THE N OF TARGETS RANDOMLY (TOO CHOOSE
% % % RANDOMLY B/W 1 AND 2 FOR N TIMES) BECAUSE AT THE END EACH PARTICIPANT
% % % HAS A DIFFERENET NUMBER OF TARKETS TO GET, LMK

% Get random number of targets for one condition
targetPerCondition = randi(rangeTargets, 1, numRepetitions);
% Assign the number of targets for each condition after shuffling
numTargets = zeros(1, nrBlocks);
numTargets(staticIndex) = Shuffle(targetPerCondition);
numTargets(motionIndex) = Shuffle(targetPerCondition);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Give the blocks the names with condition and design the task in each event

while 1
    
    for iBlock = 1:nrBlocks
        
        
        % Set block name
        switch condition{iBlock}
            case 'static'
                thisBlockName = {'static'};
            case 'motion'
                thisBlockName = {'motion'};
        end
        
        expParameters.designBlockNames(iBlock) = thisBlockName;
        
        % Set target
        %  - if there are 2 targets per block we make sure that they are at least
        %  2 events apart
        %  - targets cannot be on the first or last event of a block
        %  - no more than 2 target in the same event order
        
        chosenTarget = [];
        
        tmpTarget = numTargets(iBlock);
        
        switch tmpTarget
            
            case 1
                
                chosenTarget = randsample(2:numEventsPerBlock-1, tmpTarget, false);
                
            case 2
                
                targetDifference = 0;
                
                
                while targetDifference <= 2
                    chosenTarget = randsample(2:numEventsPerBlock-1, tmpTarget, false);
                    targetDifference = (max(chosenTarget) - min(chosenTarget));
                end
                
        end
        
        expParameters.designFixationTargets(iBlock, chosenTarget) = 1;
        
    end
    
    % Chekc rule 3
    if max(sum(expParameters.designFixationTargets)) < 3
        break
    else
        expParameters.designBlockNames      = cell(nrBlocks, 1);
        expParameters.designFixationTargets = zeros(nrBlocks, numEventsPerBlock);
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Visualize the design matrix
if displayFigs
    
    figure(1);
    
    
    % Shows blocks (static and motion) and events (motion direction) order
    subplot(3,3,1)
    
    designDirection = expParameters.designDirections;
    designDirection(designDirection==-1) = -90;
    
    imagesc(designDirection)
    
    labelAxes()
    
    caxis([-90-37, 270+37])
    myColorMap = lines(5);
    colormap(myColorMap);
    
    title('Block (static and motion) & Events (motion direction)')
    
    
    % Shows the direction position distribution in the motion blocks
    %  across the experiment
    subplot(3,3,2)
    
    leftPosition = [];
    for i=1:nrBlocks
        leftPosition = [ leftPosition find(expParameters.designDirections(i,:)==0) ];
    end
    hist(leftPosition)
    scaleAxes()
    labelAxes()
    title('0')
    
    subplot(3,3,3)
    
    rightPosition = [];
    for i=1:nrBlocks
        rightPosition = [ rightPosition find(expParameters.designDirections(i,:)==90) ];
    end
    hist(rightPosition)
    scaleAxes()
    labelAxes()
    title('90')
    
    subplot(3,3,5)
    
    upPosition = [];
    for i=1:nrBlocks
        upPosition = [ upPosition find(expParameters.designDirections(i,:)==180) ];
    end
    hist(upPosition)
    scaleAxes()
    labelAxes()
    title('180')
    
    subplot(3,3,6)
    
    downPosition = [];
    for i=1:nrBlocks
        downPosition = [ downPosition find(expParameters.designDirections(i,:)==270) ];
    end
    hist(downPosition)
    scaleAxes()
    labelAxes()
    title('270')
    
    
    % Shows the fixation targets design in each event (1 or 0)
    subplot(3,3,7)
    
    imagesc(expParameters.designFixationTargets)
    labelAxes()
    title('Fixation Targets design')
    
    
    % Shows the fixation targets position distribution in the block across
    %  the experimet
    subplot(3,3,8)
    
    itargetPosition = [];
    for i=1:nrBlocks
        itargetPosition = [ itargetPosition find(expParameters.designFixationTargets(i,:)==1) ];
    end
    hist(itargetPosition)
    labelAxes()
    title('Fixation Targets position distribution')
    
end

end

function labelAxes()
% an old viking saying because they really cared about their axes
ylabel('freq.', 'Fontsize', 8);
xlabel('Events', 'Fontsize', 8);
end

function scaleAxes()
xlim([1 12])
ylim([0 5])
end