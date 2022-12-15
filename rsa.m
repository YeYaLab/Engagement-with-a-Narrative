%% computing spearman's correlation between brain and behavioral
function rsa_vec = rsa(behav_mat, pairwiseCorr, is_partial_correlation_true)

[Nnodes, Nsubjects, ~] = size(pairwiseCorr);
rsa_vec = zeros(Nnodes,1);
ids=find(triu(ones(Nsubjects),1)); % indicating the indices of were the binary mask should be if the xSim matrix were a vector (top to botom on the columns). the binary mask ignores the diagonal...

% regular correlation
if (nargin == 2) || (is_partial_correlation_true == false)
    % pe=randperm(size(pairwiseCorr,2)); % mixing the order of all the subjects
    for currNode = 1:Nnodes % for every node:
        xSim = squeeze(pairwiseCorr(currNode,:,:)); % this is a matrix of corelations (25*25) for a aspecific voxel
        rsa_vec(currNode) = corr(xSim(ids),behav_mat(ids),'type','spearman','rows','complete'); % computing the correlation between the behavioral mat and the corelation mat for specific voxel
    end
end

% partial correlations, required when using character engagement (for example)
if (nargin == 3) && is_partial_correlation_true == true
    load('/media/ubuntu/4TeraDrive/ABC_story/data_analysis/behavioral_analysis_2/overall_engagement.mat');
    for currNode = 1:Nnodes % for every node:
        xSim = squeeze(pairwiseCorr(currNode,:,:)); % this is a matrix of corelations (25*25) for a aspecific voxel
        rsa_vec(currNode) = partialcorr(xSim(ids),behav_mat(ids), overall_engagement(ids), 'type','spearman','rows','complete'); % computing the correlation between the behavioral mat and the corelation mat for specific voxel
    end
end

end

