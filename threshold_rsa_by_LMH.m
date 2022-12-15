
function thresholded_rsa = threshold_rsa_by_LMH(rsa_path, LMH_path, threshold, is_nifty, save_path)


% % % % % % % |    VBV    |    PARC
% ____________|___________|____________
% IS-RSA      |     1     |      2 
% ISFC-RSA    |     3     |      4

% % RSA Paths:
    % 1. rsa_path = '/media/ubuntu/4TeraDrive/ABC_story/data_analysis/analysis_with_isrsa/overall_engagement/post_cluster/rsa_significant_values_qcrit_0.01.mat';
    %    rsa_path = '/media/ubuntu/4TeraDrive/ABC_story/data_analysis/analysis_with_isrsa/overall_engagement/post_cluster/rsa_significant_values_qcrit_0.05_VBV.mat';
    % 2. rsa_path = '/media/ubuntu/4TeraDrive/ABC_story/data_analysis/isRSA_with_parcells/Yeo_and_Fan_122_parcells/sig_isrsa_values_FDR01.mat';
    %    rsa_path = '/media/ubuntu/4TeraDrive/ABC_story/data_analysis/isRSA_with_parcells/Yeo_and_Fan_122_parcells/sig_isrsa_values_FDR05.mat';
    % 3.
    % 4.

% % LMH Paths:
    % 1. LMH_path = '/media/ubuntu/4TeraDrive/ABC_story/data_analysis/ISC/High_med_low_ISC_VBV';
    % 2. LMH_path = '/media/ubuntu/4TeraDrive/ABC_story/data_analysis/ISC/122_YeoFan_parcells/High_Med_Low_ISC';
    % 3. 
    % 4. 

% recomended thresholds:
    % 1. 0.2095
    % 2. 0.1621
    % 3. 0.0960
    % 4. 0.0962

% save_paths:
    % 1. save_path = '/media/ubuntu/4TeraDrive/ABC_story/data_analysis/analysis_with_isrsa/overall_engagement/post_cluster/after_thresholding_with_LMH';
    % 2. save_path = '/media/ubuntu/4TeraDrive/ABC_story/data_analysis/isRSA_with_parcells/Yeo_and_Fan_122_parcells/after_thresholding_with_LMH';
    % 3. 
    % 4. 

LMH_struct = dir(fullfile(LMH_path, 'isc*.mat'));
rsa_vec = load(rsa_path);
field = fields(rsa_vec);
rsa_vec = rsa_vec.(field{1});
number_of_voxels = length(rsa_vec);
comparing_mat = zeros(number_of_voxels, 5);
comparing_mat(:, 1) = rsa_vec;

for LMH = 1:3
    baseFileName = LMH_struct(LMH).name;
    fullFileName = fullfile(LMH_path, baseFileName);
    LMH_vec = load(fullFileName);
    field = fields(LMH_vec);
    LMH_vec = LMH_vec.(field{1});
    comparing_mat(:, (LMH+1)) = LMH_vec;
end

wanted_voxels = [(comparing_mat(:, 2) > threshold | comparing_mat(:, 3) > threshold | comparing_mat(:, 4) > threshold)];
comparing_mat(wanted_voxels, end) = comparing_mat(wanted_voxels, 1);

thresholded_rsa = comparing_mat(:, end);

if is_nifty == true
    collective_keptVox_path = '/media/ubuntu/4TeraDrive/ABC_story/data_analysis/After_Znorm_HRLock_Cutoff/nanwise_collKeptVox_allSubs_task-21styear_keptVox.mat';
    values_to_nifti(thresholded_rsa, 3, collective_keptVox_path, save_path, 'rsa_after_LMH_thresholding', true)
    % parcell_path = '/media/ubuntu/4TeraDrive/ABC_story/data_analysis/parcellation/yeo_and_fan_122/Yeo_and_fan_122_parcells.nii';
    % parcell_values_to_nifti(parcell_path, 3, thresholded_rsa, save_path, 'rsa_after_LMH_thresholding')
else
    save([save_path '/rsa_FDR05_after_LMH_thresholding_of_' num2str(threshold) '_VBV.mat'], "thresholded_rsa")
end


