% run isrsa in parcels
%
%
% finding rsa values for overall engagement in Neurosynth maps
%% loading stuff
% loading dataMat
load('/media/ubuntu/4TeraDrive/ABC_story/data_analysis/for_paper/parcellation_122/reduced_dataMat.mat');

% loading overall engagement
load('/media/ubuntu/4TeraDrive/ABC_story/data_analysis/behavioral_analysis_2/overall_engagement.mat');

%% pairwise correlations
outputPath = '/media/ubuntu/4TeraDrive/ABC_story/data_analysis/for_paper/parcellation_122/rsa_overall_engagement/pairwiseCorrs';
pairwiseCorr(reduced_dataMat,outputPath,'pairwiseCorr_parc');

%% true values - uncorrected
output_path = '/media/ubuntu/4TeraDrive/ABC_story/data_analysis/for_paper/parcellation_122/rsa_overall_engagement/uncorrected';

load('/media/ubuntu/4TeraDrive/ABC_story/data_analysis/for_paper/parcellation_122/rsa_overall_engagement/pairwiseCorrs/pairwiseCorr_parc.mat')
rsa_parc = rsa(overall_engagement,pairwiseCorr, false); save(fullfile(output_path, 'rsa_parc'),'rsa_parc','-v7.3');

%% nullDists

reduced_dataMat = permute(reduced_dataMat, [3 2 1]);
outputPath = '/media/ubuntu/4TeraDrive/ABC_story/data_analysis/for_paper/parcellation_122/rsa_overall_engagement/nullDists';

nullDist = isrsa_nullDist(reduced_dataMat,overall_engagement,1000,outputPath,'rsa_parcs_nullDist',false); % 384 seconds

%% correcting for multiple comparisions and transforming to nifti'
save_nifti_path = '/media/ubuntu/4TeraDrive/ABC_story/data_analysis/for_paper/parcellation_122/rsa_overall_engagement/corrected';
collective_keptVox_path = '';

% nulldist_and_trueValues_to_fdr_to_nifti(rsa_clara_amygdala, nullDist_clara_amygdala, collective_keptVox_path, save_nifti_path, 'rsa_clara_amygdala', true)
% nulldist_and_trueValues_to_fdr_to_nifti(rsa_alexander_amygdala, nullDist_alexander_amygdala, collective_keptVox_path, save_nifti_path, 'rsa_alexander_amygdala', true)

reduced_dataMat = permute(reduced_dataMat, [3 2 1]);
lmh_threshold = prctile(nullDist(:), 99);
disp(['lmh_threshold: ' num2str(lmh_threshold)])
nulldist_and_trueValues_to_fdr_to_nifti(reduced_dataMat, rsa_parc, nullDist, collective_keptVox_path, lmh_threshold, save_nifti_path, 'rsa_parc', false)
