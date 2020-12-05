function [ QRS_true_candidates_idx,QRS_true_dist_avg ] = FiltFalsePositives( QRS_candidates_idx ,QRS_dist_med)
    %FiltFalsePositives gets the indices of the best candidates for the
    %QRS's indices and filters out the false positives using an assertion
    %over the distances between them. it then returns only the true
    %candidates indices, the corresponding original index of each
    %candidate, and the newly calculated average of the distances between
    %the true positives.
    
    max_acc_dist_allowed = 20; % the ammount of accumulating distance allowed for a QRS peak to be from its neighbours
    
    diff_from_med = diff(QRS_candidates_idx)-QRS_dist_med;
    acc_diff = abs(diff_from_med(1:end-1)) + abs(diff_from_med(2:end)); % the accumulating diff from the prior and next QRS
    
    QRS_best_candidates_idx = find(acc_diff<max_acc_dist_allowed)+1;
    QRS_adj_idx_dist = diff(QRS_best_candidates_idx);
    QRS_adj_idx_dist(QRS_adj_idx_dist~=1) = 0;
    QRS_straits = bwconncomp(QRS_adj_idx_dist);
    [~,QRS_longest_strait_idx] = max(cellfun(@length,QRS_straits.PixelIdxList));
    QRS_longest_strait = QRS_straits.PixelIdxList{QRS_longest_strait_idx};
    QRS_true_candidates_idx = [QRS_best_candidates_idx(QRS_longest_strait(1));QRS_best_candidates_idx(QRS_longest_strait+1)];
    
    norm_dists = diff(QRS_candidates_idx(QRS_true_candidates_idx))./diff(QRS_true_candidates_idx);
    QRS_true_dist_avg = mean(norm_dists);
    
    
end

