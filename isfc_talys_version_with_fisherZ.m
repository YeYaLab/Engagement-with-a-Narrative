function [allParticipants_correlationZ2R,subjectWise_correlationR] = isfc_talys_version_with_fisherZ(dataMat_combined, save_path, naming_metric, is_output_table) % dataMat_combined should be of the shape Vox X Subj X TRs
% nets_names = cellstr(string(1:nNets));

% determining nets_Names
if matches(naming_metric, 'neurosynth')
    nets_Names = {'Attention', 'Auditory', 'DMN', 'Language', 'Reward', 'Salience'}; % may be changed
elseif matches(naming_metric, 'Erez_52')
    nets_Names = {'Primary_Auditory_Cortex_r_1','Secondary_auditory_cortex_r_2','Precentral_gyrus_l_3','Secondary_auditory_cortex_l_4','Primary_Auditory_Cortex_l_5','Temporoparietal_junction_r_6','Superior_temporal_sulcus_r_7','Medial_temporal_junction_r_8','Superior_temporal_sulcus_r_9','Medial_temporal_gyrus_r_10','Temporal_pole_r_11','Superior_temporal_gyrus_r_12','Middle_frontal_gyrus_r_13','Inferior_frontal_gyrus_r_14','Superior_frontal_gyrus_r_15','Superior_frontal_gyrus_l_16','Inferior_frontal_gyrus_l_17','Middle_frontal_gyrus_l_18','Superior_temporal_sulcus_l_19','Temporal_pole_l_20','Medial_temporal_gyrus_l_21','Superior_temporal_sulcus_l_22','Middle_temporal_gyrus_l_23','Superior_temporal_sulcus_l_24','Temporoparietal_junction_l_25','Caudate_nucleus_r_26','Inferior_frontal_gyrus_r_27','Superior_frontal_gyrus_r_28','Superior_temporal_gyrus_r_29','Superior_temporal_gyrus_l_30','Superior_frontal_gyrus_l_31','Inferior_frontal_gyrus_l_32','inferior_parietal_lobule_r_33','Middle_frontal_gyrus_r_34','Precuneus_or_Posterior_Cingulate_r_35','medial_Prefrontal_cortex_r_36','Middle_temporal_gyrus_r_37','Middle_temporal_gyrus_l_38','Medial_prefrontal_cortex_l_39','Precuneus_l_40','Middle_frontal_gyrus_l_41','inferior_parietal_lobule_l_42','Precuneus_or_Posterior_Cingulate_r_43','inferior_parietal_lobule_or_Angular_Gyrus_r_44','Middle_frontal_gyrus_r_45','Superior_frontal_gyrus_r_46','Medial_Prefrontal_cortex_m_47','Superior_frontal_gyrus_l_48','Middle_frontal_gyrus_l_49','inferior_parietal_lobule_or_Angular_Gyrus_l_50','Precuneus_or_Posterior_Cingulate_l_51','parahippocampal_gyrus_l_52'};
elseif matches(naming_metric, 'Erez_5')
    nets_Names = {'Auditory Network', 'Ventral Language network', 'Dorsal Language network', 'DMNa', 'DMNb (MTL Based)'};
elseif matches(naming_metric, 'Shens_parcells')
    nets_Names = cellstr(string(1:268));
elseif matches(naming_metric, 'Neurosynth_dmn')
    nets_Names = {'accumbence_R', 'accumbence_L', 'Fronto_orbital_cortex_R', 'Hippocampus_R', 'Cerebellum_M', 'Hippocampus_L', 'Cerebellum_L', 'Cerebellum_R', 'TPJ_R', 'Temporal_pole_R', 'TPJ_L', 'Temporal_pole_L', 'PCC_M', 'mPFC'};
elseif matches(naming_metric, 'song_yeo_fan')
    nets_Names = {'VIS', 'SM', 'DAN', 'VAN', 'LIMB', 'DMN', 'FPN', 'SUBC'};
elseif iscell(naming_metric)
    nets_Names = naming_metric;
end

% checking input
if ndims(dataMat_combined) ~= 3
    error('The input matrix should be of the dimentions Vox X Subj X TRs.')
end

% basic preperation
[nVox, nSub, ~] = size(dataMat_combined);
subjectWise_correlationR = zeros(nVox, nVox, nSub);

% calculating correlations
for currSub = 1:nSub
    
   % disp(['Starting to analyse subject number ', num2str(currSub),' at ', datestr(datetime('now'))]);
   allOtherSubs = 1:nSub;
   allOtherSubs(currSub) = [];
   allOtherSubs_brainMAt = dataMat_combined(:, allOtherSubs, :);
   
   allOtherSubs_averagedActivity = squeeze(mean(allOtherSubs_brainMAt, 2, 'omitnan')); % the averaged brain activity of all but current subject, Vox X TRs
   clear allOtherSubs_brainMAt % help memory
   currSub_Activity = squeeze(dataMat_combined(:, currSub, :)); % the brain activity of the current subject, Vox X TRs
   
   % Calculating the correlation between a current voxel of a current
   % subject with the average of all other subjects and all the voxels:
   subjectWise_correlationR(:, :, currSub) = corr(allOtherSubs_averagedActivity', currSub_Activity', 'rows','pairwise');

   % if the dataMat_combined is not reduced, uncomment the following two
   % lines in order to save every subjet separatly (no need if the
   % dataMat_combined is reduced):
%   current_subjectWise_correlation = subjectWise_correlation(:, :, currSub);
%   save(fullfile(save_path, ['isfc_subjectWise_correlation_' num2str(currSub)]), 'current_subjectWise_correlation', '-v7.3');
end

subjectWise_correlationR2Z = atanh(subjectWise_correlationR);
allParticipants_correlationZ = mean(subjectWise_correlationR2Z, 3, 'omitnan'); % averaging the correlations accross all participants
allParticipants_correlationZ2R = tanh(allParticipants_correlationZ);
allParticipants_correlationZ2R = (allParticipants_correlationZ2R + allParticipants_correlationZ2R')/2;
ids = find(triu(ones(nVox),1));
allParticipants_correlationZ2R = allParticipants_correlationZ2R(ids);

if is_output_table == 1
    allParticipants_correlationZ2R = array2table(allParticipants_correlationZ2R, 'VariableNames', nets_Names, 'RowNames', nets_Names);
end

% save(fullfile(save_path,'isfc_subjectWise_correlation'), 'subjectWise_correlationR', '-v7.3'); % saving the origional correlation values of every netroek of every subject
% save(fullfile(save_path,'isfc_allParticipants_correlation'), 'allParticipants_correlationZ2R', '-v7.3'); % saving the mean value of all subjects (after converting to Z and back to R with fishers Z)
