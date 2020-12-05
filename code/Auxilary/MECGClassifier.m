function  m_qrs_idx  = MECGClassifier( bpm,Mecg,fs,Mecg_peaks_idx)
    %MECGClassifier: Summary of this function goes here
    %   Detailed explanation goes here
    
    % Consts:
    std_ratio = 3;
    num_of_suspects = 2;
    
    % Calculate the number of expected QRS pulses based on BPM and signal
    % duration:
    maternal_freq = bpm/60;
    num_of_pulses = ceil(length(Mecg)*maternal_freq/fs);
    
    % find and Sort the MECG peaks, descending from high amplitude to low 
    [mater_peaks,mater_peaks_idx] = findpeaks(Mecg);
    [~,mater_peaks_idx_sorted] = sort(mater_peaks,'descend');
    
    % Truncate the sorted peaks, keeping only the number of
    % expected+suspected QRS pulses:
    mater_peaks_idx_sorted(num_of_pulses+num_of_suspects+1:end) = [];
    m_qrs_idx_diff = mater_peaks_idx(mater_peaks_idx_sorted);
    
    % Calculate the Standard deviation based on the top 2/3rds of the
    % pulses:
    m_qrs_std = std(Mecg(m_qrs_idx_diff(1:end-floor(length(m_qrs_idx_diff)/3))));
    
    % Calculate the average of the expected QRS pulses:
    m_qrs_mean = mean(Mecg(m_qrs_idx_diff(1:end-num_of_suspects)));
    
    
   % Identify the wrong suspects, based on deviation from the average and
   % the standard deviation:
    bad_suspect_idx = [];
    for i=length(m_qrs_idx_diff):-1:1
        smallest_qrs_std = abs(m_qrs_mean-Mecg(m_qrs_idx_diff(i)));        
        if smallest_qrs_std/m_qrs_std>std_ratio
            bad_suspect_idx = [bad_suspect_idx i];       
        else
            break;
        end
    end
    
    % Remove the bad suspects from the candidates vector:
    m_qrs_idx_diff(bad_suspect_idx) = [];  
    
    % find original MECG peaks corresponding to the candidates:
    [~,m_qrs_idx] = quantiz(m_qrs_idx_diff,Mecg_peaks_idx,[Mecg_peaks_idx; Inf]);
    m_qrs_idx(m_qrs_idx==Inf) = [];
    m_qrs_idx = sort(m_qrs_idx);
end
% figure,plot(Mecg)
% hold on;
% scatter(m_qrs_idx_diff,Mecg(m_qrs_idx_diff))
