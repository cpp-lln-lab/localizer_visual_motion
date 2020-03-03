function [directions, speeds,fixationTargets,names] = experimentalDesign(Cfg)


%%
%possibleModalities = Cfg.possibleModalities;
%possibleDirections = Cfg.possibleDirections;    % possible motion angles  (-1 is for static)
names               = Cfg.names;                  % 0= Right   90= Up    180= Left    270=down
numRepetitions      = Cfg.numRepetitions;
speedEvent          = Cfg.speedEvent;
%speedTarget         = Cfg.speedTarget;
numEventsPerBlock   = Cfg.numEventsPerBlock;
%numTargetPerBlock   = Cfg.numTargetPerBlock;
%numFixationTargets  = Cfg.numFixaT tionTargets;
range_targets = [1 Cfg.maxNumFixationTargetPerBlock];

%%

% nr_trials=2;
% range_targets = [2 4];
%% Define the experiment and balance trials, and conditions
% the blocks are consequtive static and motion blocks (Gives better results than randomised).
%% Assign the conditions
condition= repmat(names, 1,numRepetitions);
nr_blocks= length(condition);

%% Get the index of each condition
staticIndex = find(strcmp(condition,'static')) ;
motionIndex = find(strcmp(condition,'motion')) ;

%% Assign the targets for each condition

% Get random number of targets for one condition
%target_perCondition = randi(range_targets,1,nr_trials/2);  
target_perCondition = randi(range_targets,1,numRepetitions);  

% Assign the num of targets for each condition after shuffling
numTargets=zeros(1,nr_blocks);
numTargets(staticIndex) = Shuffle(target_perCondition) ;
numTargets(motionIndex) = Shuffle(target_perCondition) ;

%% Give the blocks the names with condition
names=cell(nr_blocks,1);

for block_nr = 1:nr_blocks
    if strcmp(condition(block_nr),'static') 
        names(block_nr)={'static'};
    elseif strcmp(condition(block_nr),'motion') 
        names(block_nr)={'motion'};
    end    
end


directions = zeros(nr_blocks,numEventsPerBlock);
speeds  = zeros(nr_blocks,numEventsPerBlock);
fixationTargets = zeros(nr_blocks,numEventsPerBlock);


motionDirections = repmat([0 90 180 270],1,3);
staticDirections = repmat([-1 -1 -1 -1] ,1,3);

for iMotionBlock = 1:numRepetitions
    
    directions(motionIndex(iMotionBlock),:)= Shuffle(motionDirections);
    directions(staticIndex(iMotionBlock),:)= Shuffle(staticDirections);
    


end

for iBlock=1:nr_blocks
    
    speeds(iBlock,:) = speedEvent;
    
    
    chosenTarget=[];
    
    
    tmpTarget = numTargets(iBlock);
    
    if tmpTarget == 1
        
        chosenTarget = datasample(2:numEventsPerBlock-1,tmpTarget,'Replace',false);
               
        fixationTargets(iBlock,chosenTarget)=1;

    elseif tmpTarget == 2
        
        targetDifference = 0;
        while targetDifference <= 2
            chosenTarget = datasample(2:numEventsPerBlock-1,tmpTarget,'Replace',false);
            
            targetDifference = (max(chosenTarget) - min(chosenTarget));
        end
        
        fixationTargets(iBlock,chosenTarget)=1;
        
    end
    
end
        
       
    
    

%% Visualize the design matrix
% uniqueNames = unique(names) ;
% 
% Ind= zeros(length(names),length(uniqueNames)) ;
% for i=1:length(uniqueNames)
%     CondInd(:,i) = find(strcmp(names,names{i})) ;
%     Ind(CondInd(:,i),i)=1 ;
% end
% 
% imagesc(Ind)
% set(gca,'XTick',1:length(unique(names')),'XTickLabel',unique(names'))
