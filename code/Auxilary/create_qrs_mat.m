function [pulse_mat, residue, stich_idx] = create_qrs_mat (signal)%,threshold)
    % this creates a matrix of MECG QRS pulses by the following steps:
    % 1. applies Thresholding on the signal to avoid misdetections
    % 2. locates the peaks of the signal, which correspond to QRS MECG peaks
    % 3. cuts the signal to similarly sized pulses. all the pulses are centered at the indices
    %    of the QRS peaks, and cut simetrically, based on the minimum pulse's width
    % 4. the QRS pulses are set in a matrix as rows, so that all peaks are centered at
    %    the same column.
    % 5. the residue of the signal and the indices from which the pulses were
    %    cut are also returned for reconstruction purposes later in the code.
    
    x1 = signal;
    
    % Find the Maternal BPM based on the diferential of MECG:
    bpm = getBPM(diff(x1),1e3,120,60);
    
    % Trace the maternal QRS peaks:
    [~,x1_pks_idx] = findpeaks(x1);
    Metal_QRS_idx  = MECGClassifier( bpm,diff(x1),1e3,x1_pks_idx);
    
    
    % x1(x1<threshold) = 0; % thresholding
    
    x1_pks_idx = Metal_QRS_idx;
    
    length_x1_pks_idx = length(x1_pks_idx);
    delta_vec = abs(x1_pks_idx(1:length_x1_pks_idx-1) - x1_pks_idx(2:length_x1_pks_idx)); % a vector of the distances between neighbour QRS peaks
    delta_min = min(delta_vec);
    
    half_peak = floor(delta_min/2)-1; % the interval used to simetrically cut pulse arround the QRS peak
    pulse_mat = zeros(length_x1_pks_idx-2,(2*half_peak)+1);
    
    residue = signal; % will contain the residual parts of the signal after cutting the QRS peaks out
    stich_idx = zeros(1,length_x1_pks_idx-2);
    for i = 2:length_x1_pks_idx-1
        
        QRS_iter_peak = x1_pks_idx(i)- half_peak : x1_pks_idx(i)+ half_peak;
        pulse_mat(i-1,:) = signal(QRS_iter_peak);
        residue(QRS_iter_peak) = 0;
        stich_idx(i-1) = x1_pks_idx(i)- half_peak;
    end
    residue(1:stich_idx(1)-1) = 0;
    residue(stich_idx(end)+2*half_peak+1:end) = 0;
    
end