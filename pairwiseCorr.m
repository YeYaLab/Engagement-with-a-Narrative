%% This function generates a pairwise correlation matrix.
% The matrice build is [Voxels:numOfSubj:numOfSubj]

% Run example:
% pairwiseCorr('path/to/dataMat_combined','dataMat_combined','path/to/output','outputFileName','taskName')

function pairwiseCorr(dataMat_combined,outputPath,outputName)
    % pairwiseCorr(inputPath,inputName,subNums,outputPath,outputName,task) % origional function
    % input = strcat(inputPath,'/',inputName,'.mat');
    % load the dataMat_combined, instead ofloading each subject's data separately:
    % dataMat_combined = load(input); % % % <--- un-comment if needed
    [number_of_voxels, subNums, ~] = size(dataMat_combined);
    pairwiseCorr = zeros(number_of_voxels, subNums, subNums);
    for currVox = 1:number_of_voxels % for each voxel
        for firstSub = 1:subNums
            for secondSub = 1:subNums
                pairwiseCorr(currVox,firstSub,secondSub) = corr(squeeze(dataMat_combined(currVox,firstSub,:)),squeeze(dataMat_combined(currVox,secondSub,:)));
            end
        end
    end
    
    saveName = fullfile(outputPath,outputName);
    save(saveName,'pairwiseCorr','-v7.3');
end

