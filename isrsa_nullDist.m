
function nullDist = isrsa_nullDist(brainActivityMatFile,behav_mat,numberOfScrambles,outputPath,outputName,is_partial_correlation_true)
tic
rng('shuffle');
% mat = load(brainActivityMatFile); % struct
% mat = brainActivityMatFile; % double array
% clear brainActivityMatFile
disp(['brain mat was loaded succesfully at ' datestr(datetime('now'))]);
% mat = mat.dataMat_combined;
% mat = mat.brainFunctionMat_allSubjs_TRsFirst; % ######## NOTICE: TRs X subjects X parcels(vxls) ########
[TRs, subNums, voxNums] = size(brainActivityMatFile);
pairwiseCorr_shufNum = zeros(voxNums,subNums,subNums);
nullDist = zeros(voxNums,numberOfScrambles); % output matrix

ids=find(triu(ones(subNums),1)); % = ones matrix [numSub X numSub], triu(ones(subNums)) = a 0,1, numSub X numSub matrix with ones in the upper trinagle above the main diagonal, ids = indices of the upper triangle in numSub X numSub matrix (25 X 25 matrix -> ids = 300X1)

for i = 1:numberOfScrambles % 350 sec for 1 iteration, 5000 voxels
    % tic
    % disp(['iteration number ' num2str(i)]);
    randNIfft_mat = real(phase_shuf_group_data(brainActivityMatFile));
    
    %pairwise corr between a randomized subject and a real one:
    for currVox = 1:voxNums
        pairwiseCorr_shufNum(currVox,:, :) = corr(squeeze(randNIfft_mat(:,:,currVox)),squeeze(brainActivityMatFile(:,:,currVox)));                
    end
    
    %spearman correaltion between the pseudo pairwise correlation (after
    %phase randomization of the subjects' signal) and the real behavioral
    %matrix:

    nullDist(:, i) = rsa(behav_mat, pairwiseCorr_shufNum, is_partial_correlation_true);

    % toc
end

saveName = fullfile(outputPath, outputName);
save(saveName,'nullDist','-v7.3');
toc
end