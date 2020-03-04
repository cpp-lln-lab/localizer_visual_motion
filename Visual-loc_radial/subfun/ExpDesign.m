function [ExpParameters] = ExpDesign(ExpParameters)

% % % [names,targets,condition]

% This function creates the design for the visual localizer. It takes as input the number
% of trails of each condition and the range of targets desired inside the blocks.
%
% eg. experimental_design(2,[2 4])

% Set to 1 for a visualtion of the trials design order
displayFigs = 0; 

% Set variables here for a dummy test of this function
if nargin<1
    ExpParameters.nrTrials           = 2;
    ExpParameters.range_targets      = [2 4];
    ExpParameters.possibleConditions = {'static', 'motion'};
end

% Balance trials and conditions
%  the blocks are consequtive static and motion blocks (which gives better results than randomised).

% Assign the conditions
ExpParameters.condition = repmat(ExpParameters.possibleConditions, 1, ExpParameters.nrTrials);
ExpParameters.nrBlocks= length(ExpParameters.condition);

% Get the index of each condition
staticIndex = find(strcmp(ExpParameters.condition,'static')) ;
motionIndex = find(strcmp(ExpParameters.condition,'motion')) ;

% Assign the targets for each condition, get random number of targets for one condition
ExpParameters.target_perCondition = randi(ExpParameters.range_targets, 1, ExpParameters.nrTrials);

% Assign the num of targets for each condition after shuffling
ExpParameters.targets = zeros(1, ExpParameters.nrBlocks);
ExpParameters.targets(staticIndex) = Shuffle(ExpParameters.target_perCondition);
ExpParameters.targets(motionIndex) = Shuffle(ExpParameters.target_perCondition);

% Give the blocks the names with condition
ExpParameters.names=cell(ExpParameters.nrBlocks,1);

for block_nr = 1:ExpParameters.nrBlocks
    if strcmp(ExpParameters.condition(block_nr),'static')
        ExpParameters.names(block_nr) = {'static'};
    elseif strcmp(ExpParameters.condition(block_nr),'motion')
        ExpParameters.names(block_nr) = {'motion'};
    end
end

%% Visualize the design matrix

if displayFigs
    uniqueNames = unique(ExpParameters.names);
    
    Ind= zeros(length(ExpParameters.names),length(uniqueNames));
    for i=1:length(uniqueNames)
        CondInd(:,i) = find(strcmp(ExpParameters.names,ExpParameters.names{i})) ;
        Ind(CondInd(:,i),i)=1 ;
    end
    
    imagesc(Ind)
    set(gca,'XTick',1:length(unique(ExpParameters.names')),'XTickLabel',unique(ExpParameters.names'))
end
