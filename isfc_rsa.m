function [network_combinations, pairwiseCorr, isfc_rsa_by_network] = isfc_rsa(dataMat_combined, behave_mat, significant_parcels,  is_table, save_path)

% recomended save_path = '/media/ubuntu/4TeraDrive/ABC_story/data_analysis/ISFC/isfc_rsa'
% load('/media/ubuntu/4TeraDrive/ABC_story/data_analysis/behavioral_analysis_2/overall_engagement.mat');
% you may want to change the 'nets_names' list

if ndims(dataMat_combined) ~= 3
    error('The input matrix should be of the dimentions Vox X Subj X TRs.')
end

[nNets, nSub, ~] = size(dataMat_combined);
% nets_names = {'Attention', 'Auditory', 'DMN', 'Language', 'Reward', 'Salience'};
% nets_names = {'Primary_Auditory_Cortex_r_1','Secondary_auditory_cortex_r_2','Precentral_gyrus_l_3','Secondary_auditory_cortex_l_4','Primary_Auditory_Cortex_l_5','Temporoparietal_junction_r_6','Superior_temporal_sulcus_r_7','Medial_temporal_junction_r_8','Superior_temporal_sulcus_r_9','Medial_temporal_gyrus_r_10','Temporal_pole_r_11','Superior_temporal_gyrus_r_12','Middle_frontal_gyrus_r_13','Inferior_frontal_gyrus_r_14','Superior_frontal_gyrus_r_15','Superior_frontal_gyrus_l_16','Inferior_frontal_gyrus_l_17','Middle_frontal_gyrus_l_18','Superior_temporal_sulcus_l_19','Temporal_pole_l_20','Medial_temporal_gyrus_l_21','Superior_temporal_sulcus_l_22','Middle_temporal_gyrus_l_23','Superior_temporal_sulcus_l_24','Temporoparietal_junction_l_25','Caudate_nucleus_r_26','Inferior_frontal_gyrus_r_27','Superior_frontal_gyrus_r_28','Superior_temporal_gyrus_r_29','Superior_temporal_gyrus_l_30','Superior_frontal_gyrus_l_31','Inferior_frontal_gyrus_l_32','inferior_parietal_lobule_r_33','Middle_frontal_gyrus_r_34','Precuneus_or_Posterior_Cingulate_r_35','medial_Prefrontal_cortex_r_36','Middle_temporal_gyrus_r_37','Middle_temporal_gyrus_l_38','Medial_prefrontal_cortex_l_39','Precuneus_l_40','Middle_frontal_gyrus_l_41','inferior_parietal_lobule_l_42','Precuneus_or_Posterior_Cingulate_r_43','inferior_parietal_lobule_or_Angular_Gyrus_r_44','Middle_frontal_gyrus_r_45','Superior_frontal_gyrus_r_46','Medial_Prefrontal_cortex_m_47','Superior_frontal_gyrus_l_48','Middle_frontal_gyrus_l_49','inferior_parietal_lobule_or_Angular_Gyrus_l_50','Precuneus_or_Posterior_Cingulate_l_51','parahippocampal_gyrus_l_52'};
% nets_names = {'Auditory Network', 'Ventral Language network', 'Dorsal Language network', 'DMNa', 'DMNb (MTL Based)'};
nets_names = cellstr(string(1:nNets));
% nets_names = cellstr(string(significant_parcels));

[row, column] = find(triu(ones(nNets),1)); % this line makes sure that the index of every network corresponds to the "ids" method 

network_combinations = [row, column]; 

numOfCombinations = size(network_combinations, 1);
pairwiseCorr = zeros(nSub, nSub, numOfCombinations); % nSub X nSub X numOfCombinations
isfc_rsa_by_network = zeros(numOfCombinations, 1); % the rsa vector itself

ids=find(triu(ones(nSub),1)); % indicating the indices of where the binary mask should be if the subjectPairwise_correlation(:, :, network_pair) matrix were a vector (up to botom on the columns). the binary mask ignores the diagonal...

for network_pair = 1:numOfCombinations
    network_1 = network_combinations(network_pair, 1);
    network_2 = network_combinations(network_pair, 2);
    % disp(['Starting to analyse networks ', num2str(network_1), ' and ', num2str(network_2), ' at ', datestr(datetime('now'))]);
    
    Net1_Activity = squeeze(dataMat_combined(network_1, :, :)); % the brain activity of network_1, Subj X TRs
    Net2_Activity = squeeze(dataMat_combined(network_2, :, :)); % the brain activity of network_2, Subj X TRs
    
    % Calculating the correlation between all subjects of network_1 and all subjects of network_2:
    subjectPairwise_correlation_currNetworks = corr(Net1_Activity', Net2_Activity', 'rows','pairwise');
    pairwiseCorr(:, :, network_pair) = subjectPairwise_correlation_currNetworks;
    
    % Fining the average of upper and lower triangles of
    % subjectPairwise_correlation_currNetworks
    % maybe this isnt a good idea:
    % corr(subjectPairwise_correlation_currNetworks_transformed(ids), subjectPairwise_correlation_currNetworks(ids)) = 0.3084

    subjectPairwise_correlation_currNetworks_transformed = subjectPairwise_correlation_currNetworks';
    subjectPairwise_correlation_currNetworks = (subjectPairwise_correlation_currNetworks + subjectPairwise_correlation_currNetworks_transformed)./2;
    
    % Calculating the correlation between upper triangles of behave_mat
    % and subjectPairwise_correlation, and thus creating the
    % isfc_rsa values:
    isfc_rsa_by_network(network_pair) = corr(subjectPairwise_correlation_currNetworks(ids),behave_mat(ids),'type','spearman','rows','complete'); % computing the correlation between the behavioral mat and the subjectPairwise_correlation mat for 2 specific networks 
end

% renaming the networks
%     network_combinationsCopy = network_combinations;
%     for itter = 1:nNets
%         network_combinations(find(network_combinationsCopy(:, 1) == itter), 1) = significant_parcels(itter);
%         network_combinations(find(network_combinationsCopy(:, 2) == itter), 2) = significant_parcels(itter);
%     end
%     clear network_combinationsCopy

if is_table == 1
    isfc_rsa_by_network = array2table(isfc_rsa_by_network); % (1:numOfCombinations/2, :));
    rownames_in_cells = cellstr(string(network_combinations));
    isfc_rsa_by_network.Properties.RowNames = join(rownames_in_cells, '-'); % isfc_rsa_by_network.Properties.RowNames = num2str(network_combinations)
end
% isfc_rsa_by_network.Properties.RowNames = join([rownames_in_cells; rownames_in_cells(:, end:-1:1)], '-');


% saving
% save(fullfile(save_path, 'pairwiseCorr'), 'pairwiseCorr', '-v7.3');
% save(fullfile(save_path, 'isfc_rsa_by_network'), 'isfc_rsa_by_network', '-v7.3');
% save(fullfile(save_path, 'network_combinations'), 'network_combinations', '-v7.3');
