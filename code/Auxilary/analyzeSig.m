function analyzed_figure = analyzeSig( filt_sig,t_start,t_end )
    
    SIG_IND = (round(t_start*1e3):round(t_end*1e3))';
    X1_a_cut = filt_sig(SIG_IND);
    
    
    %% Find QRS peaks
    
    [QRS_set_mat,residue, stich_idx] = create_qrs_mat(X1_a_cut);
    QRS_pulse_width = size(QRS_set_mat,2);
    QRS_set_mat_T = QRS_set_mat.';
    QRS_set_vec = QRS_set_mat_T(:);
    
    %% PCA
    
    [QRS_U, QRS_S , QRS_V] = svd(QRS_set_mat);
    
    % if CALIB_ON
    %    SING_VAL_NUM = input('enter the desired number of the biggest singular values to keep nonzero:\n');
    % end
    SING_VAL_NUM = 1;
    QRS_S(SING_VAL_NUM+1:end,:) = 0;
    maternal_T = QRS_U*QRS_S*QRS_V.';
    
    maternal_T_plot = maternal_T.'; % TODO: change to a more informative name
    
    
    %% Template Subtraction
    fetal_noisy = QRS_set_vec - maternal_T_plot(:);
    
    
    %% reconstruction of signal - to fit original size
    
    % We reconstruct the original abdominal ECG (after BPF) from which we cut the QRS pulses.
    % We also pad the FECG that was processed from the QRS pulses with the same
    % residue.
    
    rec_ABDOM_ECG = residue;
    rec_FECG = residue;
    for i=1:length(stich_idx)-1
        rec_FECG(stich_idx(i):stich_idx(i)+QRS_pulse_width-1) = fetal_noisy((i-1)*QRS_pulse_width+1:i*QRS_pulse_width);
        rec_ABDOM_ECG(stich_idx(i):stich_idx(i)+QRS_pulse_width-1) = QRS_set_vec((i-1)*QRS_pulse_width+1:i*QRS_pulse_width);
    end
    
    
    SIG_IND_PLOT = (stich_idx(1):stich_idx(end))';
    
    
    %% Derivation
    
    stich_idx_diff = sort([stich_idx-1 stich_idx+QRS_pulse_width-1]);
    FECG_diff = diff([rec_FECG' rec_FECG(length(rec_FECG))]');
    
    FECG_diff(stich_idx_diff) = (FECG_diff(stich_idx_diff-1)+FECG_diff(stich_idx_diff-2))/2;
    
    fecg_diff = FECG_diff(SIG_IND_PLOT);
    
    %% BPM Estimation:
    bpm = getBPM(FECG_diff,1e3,180,120);
    
    %% QRS Classifier
    [~,fecg_noisy_peaks_idx] = findpeaks(X1_a_cut(SIG_IND_PLOT));
    Fetal_QRS_idx  = FECGClassifier( bpm,fecg_diff,1e3,fecg_noisy_peaks_idx);
    
    
    %% Plot final result:
    orig_maternal = X1_a_cut(SIG_IND_PLOT);
    analyzed_figure = figure;
    plot((SIG_IND_PLOT-SIG_IND_PLOT(1))/1e3,orig_maternal);
    hold on;
    scatter(Fetal_QRS_idx/1e3,orig_maternal(Fetal_QRS_idx));
    xlabel('Time[sec]','FontSize',16);
    ylabel('Amp','FontSize',16);
    title('Fetal QRS over maternal ECG','FontSize',18);
    axis tight;
    legend({'Original Signal','Fetal QRS'},'FontSize',14);
    
end

