% run_isfc_rsa_all_steps

function run_isfc_rsa_all_steps(reduced_dataMat, output_path, save_name)

% loading overall engagement
load('/media/ubuntu/4TeraDrive/ABC_story/data_analysis/behavioral_analysis_2/overall_engagement.mat');

% true values - uncorrected
[network_combinations, pairwiseCorr, isfc_rsa_by_network] = isfc_rsa(reduced_dataMat, overall_engagement, '',  true, output_path);

save(fullfile(output_path, 'pairwiseCorr'), 'pairwiseCorr', '-v7.3');
save(fullfile(output_path, 'isfc_rsa_by_network'), 'isfc_rsa_by_network', '-v7.3');
save(fullfile(output_path, 'network_combinations'), 'network_combinations', '-v7.3');

% nullDists
isfc_rsa_nullDist = create_nullDist_for_isfc_rsa(reduced_dataMat, overall_engagement, 1000);
save(fullfile(output_path, 'nullDist_isfc_rsa'), 'isfc_rsa_nullDist', '-v7.3');

% correcting for multiple comparisions - fdr and LMH
lmh_threshold = prctile(isfc_rsa_nullDist(:), 95);
disp(['lmh_threshold: ' num2str(lmh_threshold)])
nulldist_and_trueValues_to_fdr_and_lmh_isfc_rsa(reduced_dataMat, isfc_rsa_by_network, isfc_rsa_nullDist, network_combinations, lmh_threshold, output_path, save_name)

