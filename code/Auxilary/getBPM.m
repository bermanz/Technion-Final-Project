function  heart_bpm  = getBPM( sig,fs,max_bpm,min_bpm )
    %getBPM Calculates the inputs signal's heart rate using
    %autocorrelation.
    
%     Inputs:
%       - sig: the input signal
%       - fs: the sampling rate
%       - max_bpm: the upper bound for the BPM
%       - min_bpm: the lower bound for the BPM
%     Outputs:
%       - heart_bpm: the identified BPM
      
    [frame_corr,lags] = xcorr(sig);
    frame_corr = frame_corr(lags>=0);
    [max_vals,max_idx] = findpeaks(frame_corr);
    % sort the autocorrelation's peaks from biggest to smallest:
    [~,Idx] = sort(max_vals,'descend');
    
    % go over the indices of the autocorrelation's peaks from the biggest to
%     the smallest and see if the inferred frequency applies as a possible
%     BPM regarding the input limitations:
    for i=1:length(max_idx)
        cur_freq = fs/max_idx(Idx(i));
        cur_BPM = cur_freq*60;
        if (cur_BPM < max_bpm) && (cur_BPM > min_bpm)
            heart_bpm = cur_BPM;
            break;
        end
    end
    
end

