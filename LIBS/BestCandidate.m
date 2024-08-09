function [branchTypeBest,id] = BestCandidate(branchTypeReference,branchTypeCandidates)

if length(branchTypeCandidates) > 1
    DisMin = Inf;
    for i = 1:length(branchTypeCandidates)
        branchType = branchTypeCandidates{i};
        [dF, ~] = DiscreteFrechetDist(branchTypeReference.EdgePoints,branchType.EdgePoints);
        if dF < DisMin
            DisMin = dF;
            branchTypeBest = branchType;
            id = i;
        end
    end
elseif ~isempty(branchTypeCandidates)
    branchTypeBest = branchTypeCandidates{1};
    id = 1;
else
    branchTypeBest = [];
    id = [];
end

