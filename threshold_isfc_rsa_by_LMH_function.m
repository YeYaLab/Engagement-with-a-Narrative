function [high_isfc, med_isfc, low_isfc, lmh_corrected_rsa] = threshold_isfc_rsa_by_LMH_function(dataMat, high_vec, med_vec, low_vec, isfc_rsa_vec, threshold)
% dataMat_combined should be of the shape Vox X Subj X TRs

nets_names = cellstr(string(1:size(dataMat, 1)));
[high_isfc,~] = isfc_talys_version_with_fisherZ(dataMat(:, high_vec, :), '', nets_names, false); 
[med_isfc,~] = isfc_talys_version_with_fisherZ(dataMat(:, med_vec, :), '', nets_names, false); 
[low_isfc,~] = isfc_talys_version_with_fisherZ(dataMat(:, low_vec, :), '', nets_names, false); 

sig_edges = [(high_isfc > threshold | med_isfc > threshold | low_isfc > threshold)];
lmh_corrected_rsa = zeros(size(isfc_rsa_vec));
lmh_corrected_rsa(sig_edges) = isfc_rsa_vec(sig_edges);
