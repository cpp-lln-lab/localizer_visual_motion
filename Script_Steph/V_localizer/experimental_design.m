function [names,targets,condition] = experimental_design(nr_trials,range_targets) 
% This function creates the design for the experiment. It takes as input the number
% of trails of each condition and the range of targets wanted inside the blocks.
% 
%eg. experimental_design(2,[2 4])

% nr_trials=2;
% range_targets = [2 4];
%% Define the experiment and balance trials, and conditions
% the blocks are consequtive static and motion blocks (Gives better results than randomised).

%% Assign the conditions
condition= repmat({'static','motion'}, 1,nr_trials);
nr_blocks= length(condition);

%% Get the index of each condition
staticIndex = find(strcmp(condition,'static')) ;
motionIndex = find(strcmp(condition,'motion')) ;

%% Assign the targets for each condition

% Get random number of targets for one condition
%target_perCondition = randi(range_targets,1,nr_trials/2);  
target_perCondition = randi(range_targets,1,nr_trials);  

% Assign the num of targets for each condition after shuffling
targets=zeros(1,nr_blocks);
targets(staticIndex) = Shuffle(target_perCondition) ;
targets(motionIndex) = Shuffle(target_perCondition) ;

%% Give the blocks the names with condition
names=cell(nr_blocks,1);

for block_nr = 1:nr_blocks
    if strcmp(condition(block_nr),'static') 
        names(block_nr)={'static'};
    elseif strcmp(condition(block_nr),'motion') 
        names(block_nr)={'motion'};
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
