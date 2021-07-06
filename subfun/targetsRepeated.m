%This function gives the matrix with the targets(paired). This is used in
%expDesign
function [MYfixationTargets_matrix] = targetsRepeated(fixationTargets)

cfg.design.fixationTargets=zeros(size(fixationTargets,1), (size(fixationTargets,2)+size(fixationTargets,2)));
    for t=1:size(fixationTargets,2)
        cfg.design.fixationTargets(:,2*t-1) =fixationTargets(:,t);
        cfg.design.fixationTargets(:,2*t)=fixationTargets(:,t); 
    end
cfg.design.fixationTargets
MYfixationTargets_matrix=cfg.design.fixationTargets;
end