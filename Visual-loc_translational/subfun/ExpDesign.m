function [speeds,fixationTargets,ExpDesignParameters] = ExpDesign(ExpParameters)

% Initialize the structure
ExpDesignParameters = struct;

% Set to 1 for a visualtion of the trials design order
displayFigs = 0;

% Set variables here for a dummy test of this function
if nargin<1
    ExpParameters.names              = {'static','motion'};
    ExpParameters.numRepetitions         = 1;
    ExpParameters.speedEvent             = 4;
    ExpParameters.numEventsPerBlock      = 12;
end


range_targets = [1 ExpParameters.maxNumFixationTargetPerBlock];

%%

% nr_trials=2;
% range_targets = [2 4];
%% Define the experiment and balance trials, and conditions
% the blocks are consequtive static and motion blocks (Gives better results than randomised).
%% Assign the conditions
condition= repmat(ExpParameters.names, 1,ExpParameters.numRepetitions);
nr_blocks= length(condition);

%% Get the index of each condition
staticIndex = find(strcmp(condition,'static')) ;
motionIndex = find(strcmp(condition,'motion')) ;

%% Assign the targets for each condition

% Get random number of targets for one condition
%target_perCondition = randi(range_targets,1,nr_trials/2);
target_perCondition = randi(range_targets,1,ExpParameters.numRepetitions);

% Assign the num of targets for each condition after shuffling
numTargets=zeros(1,nr_blocks);
numTargets(staticIndex) = Shuffle(target_perCondition) ;
numTargets(motionIndex) = Shuffle(target_perCondition) ;

%% Give the blocks the names with condition
ExpDesignParameters.blockNames=cell(nr_blocks,1);

for block_nr = 1:nr_blocks
    if strcmp(condition(block_nr),'static')
        ExpDesignParameters.blockNames(block_nr)={'static'};
    elseif strcmp(condition(block_nr),'motion')
        ExpDesignParameters.blockNames(block_nr)={'motion'};
    end
end


ExpDesignParameters.directions = zeros(nr_blocks,ExpParameters.numEventsPerBlock);
ExpDesignParameters.speeds  = zeros(nr_blocks,ExpParameters.numEventsPerBlock);
ExpDesignParameters.fixationTargets = zeros(nr_blocks,ExpParameters.numEventsPerBlock);


motionDirections = repmat([0 90 180 270],1,3);
staticDirections = repmat([-1 -1 -1 -1] ,1,3);

for iMotionBlock = 1:ExpParameters.numRepetitions
    
    ExpDesignParameters.directions(motionIndex(iMotionBlock),:)= Shuffle(motionDirections);
    ExpDesignParameters.directions(staticIndex(iMotionBlock),:)= Shuffle(staticDirections);
    
    
    
end

for iBlock=1:nr_blocks
    
    ExpDesignParameters.speeds(iBlock,:) = ExpParameters.speedEvent;
    
    
    chosenTarget=[];
    
    
    tmpTarget = numTargets(iBlock);
    
    if tmpTarget == 1
        
        chosenTarget = datasample(2:ExpParameters.numEventsPerBlock-1,tmpTarget,'Replace',false);
        
        ExpDesignParameters.fixationTargets(iBlock,chosenTarget)=1;
        
    elseif tmpTarget == 2
        
        targetDifference = 0;
        while targetDifference <= 2
            chosenTarget = datasample(2:ExpParameters.numEventsPerBlock-1,tmpTarget,'Replace',false);
            
            targetDifference = (max(chosenTarget) - min(chosenTarget));
        end
        
        ExpDesignParameters.fixationTargets(iBlock,chosenTarget)=1;
        
    end
    
end





%% Visualize the design matrix
% uniqueNames = unique(ExpDesignParameters.blockNames) ;
%
% Ind= zeros(length(ExpDesignParameters.blockNames),length(uniqueNames)) ;
% for i=1:length(uniqueNames)
%     CondInd(:,i) = find(strcmp(ExpDesignParameters.blockNames,ExpDesignParameters.blockNames{i})) ;
%     Ind(CondInd(:,i),i)=1 ;
% end
%
% imagesc(Ind)
% set(gca,'XTick',1:length(unique(ExpDesignParameters.blockNames')),'XTickLabel',unique(ExpDesignParameters.blockNames'))
