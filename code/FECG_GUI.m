function varargout = FECG_GUI(varargin)
% FECG_GUI MATLAB code for FECG_GUI.fig
%      FECG_GUI, by itself, creates a new FECG_GUI or raises the existing
%      singleton*.
%
%      H = FECG_GUI returns the handle to a new FECG_GUI or the handle to
%      the existing singleton*.
%
%      FECG_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FECG_GUI.M with the given input arguments.
%
%      FECG_GUI('Property','Value',...) creates a new FECG_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FECG_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FECG_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FECG_GUI

% Last Modified by GUIDE v2.5 19-Dec-2017 14:13:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FECG_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @FECG_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


% End initialization code - DO NOT EDIT

% --- Executes just before FECG_GUI is made visible.
function FECG_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FECG_GUI (see VARARGIN)

gui_path_split = strsplit(mfilename('fullpath'),'\');
guiData.gui_path = fullfile(gui_path_split{1:end-1});
cd(guiData.gui_path);
addpath(genpath(guiData.gui_path));

params_path = [guiData.gui_path '\gui_params.mat'];
if exist(params_path)
    load(params_path);
     handles.t_SigPath.String = sig_path;
     if exist(sig_path)
         handles.t_SigPath.UserData = true;
     end
     handles.t_Start.String = t_start;
     handles.t_End.String = t_end;
end

handles.figure1.UserData = guiData;

% Choose default command line output for FECG_GUI
handles.output = hObject;



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FECG_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FECG_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in t_LoadSig.
function t_LoadSig_Callback(hObject, eventdata, handles)
% hObject    handle to t_LoadSig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dialog_txt = 'Choose the .mat file with the signal you wish to analyze';
ext = '\*.mat'; 

cur_dir = handles.figure1.UserData.gui_path;
[FileName,PathName,~] = uigetfile([cur_dir,ext],dialog_txt);
if FileName % a valid .mat file was chosen
    handles.t_SigPath.String = [PathName,FileName];
    handles.t_SigPath.UserData = true;
    handles.t_message.String = [];
    handles.t_message.ForegroundColor = [0 0 0]; % Black
    
else
    handles.t_SigPath.String = [];
    handles.t_SigPath.UserData = false;
    handles.t_message.String = 'Error: File wasn''t chosen properly. Please retry!';
    handles.t_message.ForegroundColor = [1 0 0]; % Red
end
   


function t_SigPath_Callback(hObject, eventdata, handles)
% hObject    handle to t_SigPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: get(hObject,'String') returns contents of t_SigPath as text
%        str2double(get(hObject,'String')) returns contents of t_SigPath as a double


% --- Executes during object creation, after setting all properties.
function t_SigPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_SigPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in t_ExplrSig.
function t_ExplrSig_Callback(hObject, eventdata, handles)
% hObject    handle to t_ExplrSig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.t_SigPath.UserData
    handles.t_message.String = [];
    handles.t_message.ForegroundColor = [0 0 0]; % Black
    preFiltSig(handles.t_SigPath.String,true);
else
    handles.t_message.String = 'Error: No signal was chosen by the user. Please choose a signal to process';
    handles.t_message.ForegroundColor = [1 0 0]; % Red
end



function t_Start_Callback(hObject, eventdata, handles)
% hObject    handle to t_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_Start as text
%        str2double(get(hObject,'String')) returns contents of t_Start as a double

function t_End_Callback(hObject, eventdata, handles)
% hObject    handle to t_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_Start as text
%        str2double(get(hObject,'String')) returns contents of t_Start as a double


% --- Executes during object creation, after setting all properties.
function t_Start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in t_Analyze.
function t_Analyze_Callback(hObject, eventdata, handles)
% hObject    handle to t_Analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~handles.t_SigPath.UserData
    handles.t_message.String = 'Error: No signal was chosen by the user. Please choose a signal to process';
    handles.t_message.ForegroundColor = [1 0 0]; % Red
elseif isempty(handles.t_Start.String) || isempty(handles.s_end.String)
    handles.t_message.String = 'Error: Start/End time aren''t indicated. Please indicate a valid start/end time';
    handles.t_message.ForegroundColor = [1 0 0]; % Red
else
    sig_path = handles.t_SigPath.String;
    [t, filt_sig ] = preFiltSig( sig_path ,false);
    t_start = str2double(handles.t_Start.String);
    t_end = str2double(handles.t_End.String);
    if  t_start < t(1) || t_end > t(end)
        handles.t_message.String = ['Error: Start time should be greater than ' num2str(t(1)) ' /End time should be smaller than ' num2str(t(end))];
        handles.t_message.ForegroundColor = [1 0 0]; % Red
    else
        handles.t_message.String = 'Signal Analysis is in process...';
        handles.t_message.ForegroundColor = [0 0 0]; % Balck
        analyzed_fig = analyzeSig(filt_sig,t_start,t_end);
        handles.t_message.String = 'Analysis is done!';
        
        % save figure temporarily :
        cur_dir = handles.figure1.UserData.gui_path;
        saveas(analyzed_fig,[cur_dir '\tmpFig'],'jpg'); 
    end
end
    

% --- Executes during object creation, after setting all properties.
function t_End_CreateFcn(hObject, eventdata, handles)
% hObject    handle to s_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function s_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to s_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in t_Save.
function t_Save_Callback(hObject, eventdata, handles)
% hObject    handle to t_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cur_dir = handles.figure1.UserData.gui_path;
if ~exist([cur_dir '\tmpFig.jpg'])
    handles.t_message.String = 'Error: Analyze wasn''t performed -> no data is available to be saved' ;
    handles.t_message.ForegroundColor = [1 0 0]; % Red
else
    dialog_txt = 'Choose a folder to save the results';
    PathName = uigetdir(cur_dir,dialog_txt);
    sig_name = strsplit(handles.t_SigPath.String,{'.','\'});
    t_start = str2double(handles.t_Start.String);
    t_end = str2double(handles.t_End.String);
    copyfile([cur_dir '\tmpFig.jpg'],[PathName ,'\' sig_name{end-1} '_s' num2str(t_start) '_e' num2str(t_end) '.jpg']);
    handles.t_message.String = 'Results have been saved' ;
    handles.t_message.ForegroundColor = [0 0 0]; % Black 
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cur_dir = handles.figure1.UserData.gui_path;
sig_path = handles.t_SigPath.String;
t_start = handles.t_Start.String;
t_end = handles.t_End.String;
if exist([cur_dir '\tmpFig.jpg'])
    delete([cur_dir '\tmpFig.jpg']);
end

save([cur_dir '\gui_params.mat'],'sig_path','t_start','t_end');

% Hint: delete(hObject) closes the figure
delete(hObject);
