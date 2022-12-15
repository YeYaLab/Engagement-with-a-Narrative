function nulldist_and_trueValues_to_fdr_to_nifti(dataMat, trueValues, nullDist, collective_keptVox_path, lmh_threshold, save_nifti_path, save_nifti_name, is_VBV)


% see run-script "run_post_isrsa_clusters_nullDist"


qcrit_for_FDR = 0.05;
mm = 3;

[theoretic_pvalues] = theoretic_pvalues_better_version_two_tails(nullDist, trueValues);

[pcrit, sigvals, sigindx] = fdr_BH(theoretic_pvalues, qcrit_for_FDR);

sig_reall_values = trueValues;
sig_reall_values(sigindx == 0) = 0;

high_vec = [7 10 14 17 23 24 25]; med_vec = [1 5 12 13 18 19 20 21 22]; low_vec = [2 3 4 6 8 9 11 15 16];
[high_isc, med_isc, low_isc, lmh_corrected_rsa] = threshold_rsa_by_LMH_function(dataMat, high_vec, med_vec, low_vec, sig_reall_values, lmh_threshold);

if is_VBV == true
    values_to_nifti(lmh_corrected_rsa, mm, collective_keptVox_path, save_nifti_path, save_nifti_name, true);
elseif is_VBV == false
    parcell_path = '/media/ubuntu/4TeraDrive/ABC_story/data_analysis/parcellation/yeo_and_fan_122/Yeo_and_fan_122_parcells.nii';
    parcell_values_to_nifti(parcell_path, mm, lmh_corrected_rsa, save_nifti_path, save_nifti_name)
end

saveName = fullfile(save_nifti_path, [save_nifti_name '_corrections']);
save(saveName,'pcrit', 'qcrit_for_FDR', 'sig_reall_values', 'sigindx', 'sigvals', 'theoretic_pvalues', 'high_isc', 'med_isc', 'low_isc', 'lmh_threshold', 'lmh_corrected_rsa', '-v7.3');
