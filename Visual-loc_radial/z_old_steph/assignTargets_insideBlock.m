function targets_inside_block = assignTargets_insideBlock (nframes,blockDur,ifi,nr_targets)
% function gives as output the targets locations inside each block
% The target locations are expressed in frame number inside the block

% Seconds to avoid at the beginning and end of each quadrant border (See below)
secs_avoid_inQuad= 0.5;          
%blockDur = 16;
%ifi=0.16 ;

% make a zero vector with the number of the frames inside the block
targets_inside_block = zeros(1,nframes);  

% Define borders inside the block to divide it into 4 quadrants:
%the 0,25,50,75, & 100% border of the block.

quadrant_borders= [     0         blockDur*0.25 
                   blockDur*0.25  blockDur*0.5  
                   blockDur*0.5   blockDur*0.75 
                   blockDur*0.75  blockDur]; 

%nr_targets=3;
%nr_targets = randi(4,1,1)

%If the number of targets is less than four, pick randomly n quadrants,
%where n is the number of targets in this block
if nr_targets<4
    chosen_borders=randsample(4,nr_targets);
    quadrant_borders = quadrant_borders(chosen_borders,:);
end

% for the targets (in each quadrants), pick random location for the targets
% (frames) while keeping in mind to avoid the first 0.5 secs and the last
% 0.5 secs in the quadrant, and thats to avoid very close targets in
% consequtive quadrants.
for z=1:length(quadrant_borders(:,1))                                        % For each chosen quadrant
    borders_interval = quadrant_borders(z,:);                                % Get the quadrant borders
    target_possible = [floor((borders_interval(1)+secs_avoid_inQuad)/ifi) ...% Then, find the possible frames where the targets can exist
                       floor((borders_interval(2)-secs_avoid_inQuad)/ifi)];
                   
    target_indices =randi([target_possible(1) target_possible(2)],1,1);      % pick a random frame within the allowed border (from the previously defined possible frames)

    for i=target_indices:target_indices+2                                    % Assign a value of 1 to the frames where the target was randomly chosen
        targets_inside_block(i)=1;                                           % Make the assigment for 3 consequetive frames, so we can have a red dot of
    end                                                                      % 3 flip intervals (3x0.016= 0.048 secs) "This way, it will not be too quick"
end
                                         
%imagesc(targets_inside_block)                                               % To visualize the targets location inside one block
