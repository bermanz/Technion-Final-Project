function  Fetal_QRS_idx_true  = FECGClassifier( bpm,fecg_noisy,fs,fecg_noisy_peaks_idx)
    %FECGClassifier Summary of this function goes here
    %   Detailed explanation goes here

    %% Build Synthectic fetal mask
    load single_FECG_pulse.mat;

    fetal_freq = bpm/60;
    FQRS_delta = fs/fetal_freq;
    zero_pad_len = round((FQRS_delta-length(single_pulse))/2);
    zero_pad = zeros(zero_pad_len,1);
    single_pulse_padded = [zero_pad;single_pulse;zero_pad];
    num_of_pulses = ceil(length(fecg_noisy)*fetal_freq/fs);
    mask = repmat(single_pulse_padded,num_of_pulses,1);
    
    delta = length(mask)- length(fecg_noisy);
    if delta > 0
        fecg_noisy = [fecg_noisy;zeros(delta,1)];
    elseif delta < 0
        mask = [mask;zeros(abs(delta),1)];
    end
    
    [corr_res,corr_lags] = xcorr(fecg_noisy,mask);
    [~,max_corr_idx] = max(corr_res);
    if corr_lags(max_corr_idx)>0
        off_ratio = ceil(corr_lags(max_corr_idx)/FQRS_delta);
    elseif corr_lags(max_corr_idx)< -FQRS_delta
        off_ratio = -floor(-corr_lags(max_corr_idx)/FQRS_delta);        
    else
        off_ratio = 0;        
    end    
    mask_offset = corr_lags(max_corr_idx)-FQRS_delta*off_ratio;
    
    [mask_peaks,mask_peaks_idx] = findpeaks(mask);
    
    % a single pulse might contain more than one maxima
    if length(mask_peaks)> num_of_pulses 
        [~,mask_peaks_sorted_idx] = sort(mask_peaks,'descend');
        mask_peaks_sorted_idx(num_of_pulses+1:end) = [];
        mask_peaks_idx = mask_peaks_idx(mask_peaks_sorted_idx);
    end
    
    Fetal_QRS_idx = mask_peaks_idx+mask_offset;
    Fetal_QRS_idx(Fetal_QRS_idx>length(fecg_noisy)) = [];
    Fetal_QRS_idx(Fetal_QRS_idx<1) = length(fecg_noisy)+Fetal_QRS_idx(Fetal_QRS_idx<1);
    Fetal_QRS_idx_sorted = sort(Fetal_QRS_idx);
    
    %% classify
    
    [~,noisy_peaks_idx] = findpeaks(fecg_noisy);
    
    class_num = 5;
    [indices,~] = knnsearch(noisy_peaks_idx,Fetal_QRS_idx_sorted,'K',class_num);
    
    fecg_best_candidates = noisy_peaks_idx(indices(:,1));
    true_fecg_peaks_idx = zeros(1,size(indices,1));
%     fecg_peaks_med=  median(fecg_noisy(noisy_peaks_idx(indices(:,1))));
    fecg_dist_med =  median(diff(fecg_best_candidates));
    
    did_converge = 0;
    while ~did_converge
        true_fecg_peaks_idx_prev = true_fecg_peaks_idx;
        
        [ QRS_true_candidates_idx,QRS_true_dist_avg ] = FiltFalsePositives( fecg_best_candidates ,fecg_dist_med);
        
        for i=1:size(indices,1)
            
            if ismember(i,QRS_true_candidates_idx)
                if ~true_fecg_peaks_idx(i)
                    true_fecg_peaks_idx(i) = indices(i,1);
                end
            else
                cur_candidates_idx = noisy_peaks_idx(indices(i,:));
                cur_candidates_idx_mat = repmat(cur_candidates_idx,1,length(QRS_true_candidates_idx));
                cur_candidates_diffs = cur_candidates_idx_mat-fecg_best_candidates(QRS_true_candidates_idx)';
                cur_candidates_diffs_w = cur_candidates_diffs./(abs(QRS_true_candidates_idx-i))';
                dev_from_avg_dist = abs(cur_candidates_diffs_w)-QRS_true_dist_avg;
                ssd = sqrt(sum(dev_from_avg_dist.^2,2));
                [~,fecg_best_fit_peak_idx] = min(ssd);
                true_fecg_peaks_idx(i) = indices(i,fecg_best_fit_peak_idx);
            end
        end
        fecg_best_candidates = noisy_peaks_idx(true_fecg_peaks_idx);
        
        fecg_dist_med = QRS_true_dist_avg;

        
        did_converge = isequal(true_fecg_peaks_idx,true_fecg_peaks_idx_prev);
        
    end
    
    Fetal_QRS_diff_idx = noisy_peaks_idx(true_fecg_peaks_idx);
    
    %% find original Fetal QRSs:
%     [~,Fetal_QRS_idx_true] = quantiz(Fetal_QRS_diff_idx,fecg_noisy_peaks_idx,[fecg_noisy_peaks_idx; Inf]);
    [~,Fetal_QRS_idx_true] = quantiz(Fetal_QRS_diff_idx,fecg_noisy_peaks_idx,[1;fecg_noisy_peaks_idx]);
    Fetal_QRS_idx_true(Fetal_QRS_idx_true==Inf) = [];
end

