function [expParameters] = expDesign(expParameters, displayFigs)
% Creates the sequence of blocks and the events in them
%
% The conditions are consecutive static and motion blocks (Gives better results than randomised).
%
% EVENTS
%  The numEventsPerBlock should be a multiple of the number of "base"
%  listed in the motionDirections and staticDirections (4 at the moment).
%
%
% TARGETS:
%  If there are 2 targets per block we make sure that they are at least 2
%   events apart.
%  Targets cannot be on the first or last event of a block
%
% Input:
%   - ExpParameters: parameters returned by SetParameters
%   - displayFigs: a boolean to decide whether to show the basic design
%   matrix of the design
%
% Output:
%   - ExpDesignParam.designBlockNames      = cell array (nr_blocks, 1) with the
%    name for each block
%
%   - ExpDesignParam.designDirections      = array (nr_blocks, numEventsPerBlock) 
%    with the direction to present in a given block
%       - 0 90 180 270 indicate the angle
%       - -1 indicates static
%
%   - ExpDesignParam.designSpeeds          = array (nr_blocks, numEventsPerBlock) * speedEvent;
%
%   - ExpDesignParam.designFixationTargets = array (nr_blocks, numEventsPerBlock)
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

% Set to 1 for a visualtion of the trials design order
if nargin < 2  || isempty(displayFigs)
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

% Set directions for static and motion condition
motionDirections = repmat(motionDirections, 1, numEventsPerBlock/length(motionDirections));
staticDirections = repmat(staticDirections, 1, numEventsPerBlock/length(staticDirections));

% Assign the conditions
condition = repmat(names, 1, numRepetitions);
nrBlocks = length(condition);
% Get the index of each condition
staticIndex = find( strcmp(condition, 'static') );
motionIndex = find( strcmp(condition, 'motion') );


% Assign the targets for each condition
rangeTargets = [1 maxNumFixTargPerBlock];
% Get random number of targets for one condition
targetPerCondition = randi(rangeTargets, 1, numRepetitions);
% Assign the number of targets for each condition after shuffling
numTargets = zeros(1, nrBlocks);
numTargets(staticIndex) = Shuffle(targetPerCondition);
numTargets(motionIndex) = Shuffle(targetPerCondition);


%% Give the blocks the names with condition

expParameters.designBlockNames      = cell(nrBlocks, 1);
expParameters.designDirections      = zeros(nrBlocks, numEventsPerBlock);
expParameters.designSpeeds          = ones(nrBlocks, numEventsPerBlock) * speedEvent;
expParameters.designFixationTargets = zeros(nrBlocks, numEventsPerBlock);

for iMotionBlock = 1:numRepetitions
    
    expParameters.designDirections( motionIndex(iMotionBlock), :) = Shuffle(motionDirections);
    expParameters.designDirections( staticIndex(iMotionBlock), :) = Shuffle(staticDirections);
    
end

for iBlock = 1:nrBlocks
    
    % Set block name
    switch condition{iBlock}
        case 'static'
            thisBlockName = {'static'};
        case 'motion'
            thisBlockName = {'motion'};
    end
    expParameters.designBlockNames(iBlock) = thisBlockName;
    
    
    % set target
    % if there are 2 targets per block we make sure that they are at least
    % 2 events apart
    % targets cannot be on the first or last event of a block
    
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


%% Visualize the design matrix
if displayFigs
    
    uniqueNames = unique(expParameters.designBlockNames) ;
    
    Ind = zeros(length(expParameters.designBlockNames), length(uniqueNames)) ;
    
    for i = 1:length(uniqueNames)
        CondInd(:,i) = find(strcmp(expParameters.designBlockNames, uniqueNames{i})) ; %#ok<*AGROW>
        Ind(CondInd(:,i), i) = 1 ;
    end
    
    imagesc(Ind)
    
    set(gca, ...
        'XTick',1:length(uniqueNames),...
        'XTickLabel', uniqueNames)
    
end
