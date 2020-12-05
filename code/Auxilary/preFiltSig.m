function [t, filt_sig ] = preFiltSig( sig_path ,do_plot)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    load(sig_path);
    X1_a= data;
    load BPF_butter40.mat;
    X1_a_filtered = filter(BPF,X1_a);
    SIG_DIR_SWITCH =  (abs(min(X1_a_filtered))>abs(max(X1_a_filtered)));
    filt_sig= -(2*SIG_DIR_SWITCH-1)*X1_a_filtered ; % turns the signal upside down if it's the opposite direction
    
    
    t = (1:length(filt_sig))/1e3;
    if do_plot
        figure,
        plot(t,filt_sig);
        title('Explore the signal and look for a time interval to analize','FontSize',18);
        xlabel('Time[sec]','FontSize',16);
        ylabel('Amplitude','FontSize',16);
        axis tight;
    end
end

