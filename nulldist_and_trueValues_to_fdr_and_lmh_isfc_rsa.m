function nulldist_and_trueValues_to_fdr_and_lmh_isfc_rsa(dataMat, trueValues, nullDist, network_combinations, lmh_threshold, save_path, save_name)

% see run-script "run_post_isrsa_clusters_nullDist"

qcrit_for_FDR = 0.05;
if istable(trueValues)
    trueValues = table2array(trueValues);
end

[theoretic_pvalues] = theoretic_pvalues_better_version_two_tails(nullDist, trueValues);

[pcrit, sigvals, sigindx] = fdr_BH(theoretic_pvalues, qcrit_for_FDR);

sig_reall_values = trueValues;
sig_reall_values(sigindx == 0) = 0;

high_vec = [7 10 14 17 23 24 25]; med_vec = [1 5 12 13 18 19 20 21 22]; low_vec = [2 3 4 6 8 9 11 15 16];
[high_isfc, med_isfc, low_isfc, lmh_corrected_isfc_rsa] = threshold_isfc_rsa_by_LMH_function(dataMat, high_vec, med_vec, low_vec, trueValues, lmh_threshold);

saveName = fullfile(save_path, [save_name '_corrections']);
save(saveName,'lmh_corrected_isfc_rsa', 'pcrit', 'qcrit_for_FDR', 'sig_reall_values', 'sigindx', 'sigvals', 'theoretic_pvalues', 'high_isfc', 'med_isfc', 'low_isfc', 'lmh_threshold', '-v7.3');

LMH_isfc_values = table(network_combinations, lmh_corrected_isfc_rsa, high_isfc, med_isfc, low_isfc,'VariableNames',{'Networks', 'lmh_corrected_isfc_rsa', 'high_isfc', 'med_isfc', 'low_isfc'});
writetable(LMH_isfc_values, fullfile(save_path, [save_name '_LMH_isfc_values.csv']))
