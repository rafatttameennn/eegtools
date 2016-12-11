function varargout = EEG_CAPTURE_TOOL(varargin)
% EEG_CAPTURE_TOOL MATLAB code for EEG_CAPTURE_TOOL.fig
%      EEG_CAPTURE_TOOL, by itself, creates a new EEG_CAPTURE_TOOL or raises the existing
%      singleton*.
%
%      H = EEG_CAPTURE_TOOL returns the handle to a new EEG_CAPTURE_TOOL or the handle to
%      the existing singleton*.
%
%      EEG_CAPTURE_TOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EEG_CAPTURE_TOOL.M with the given input arguments.
%
%      EEG_CAPTURE_TOOL('Property','Value',...) creates a new EEG_CAPTURE_TOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EEG_CAPTURE_TOOL_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EEG_CAPTURE_TOOL_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EEG_CAPTURE_TOOL

% Last Modified by GUIDE v2.5 11-Dec-2016 02:17:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EEG_CAPTURE_TOOL_OpeningFcn, ...
                   'gui_OutputFcn',  @EEG_CAPTURE_TOOL_OutputFcn, ...
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


% --- Executes just before EEG_CAPTURE_TOOL is made visible.
function EEG_CAPTURE_TOOL_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EEG_CAPTURE_TOOL (see VARARGIN)

% Choose default command line output for EEG_CAPTURE_TOOL
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EEG_CAPTURE_TOOL wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EEG_CAPTURE_TOOL_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function sub_txtbox_Callback(hObject, eventdata, handles)
% hObject    handle to sub_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sub_txtbox as text
%        str2double(get(hObject,'String')) returns contents of sub_txtbox as a double


% --- Executes during object creation, after setting all properties.
function sub_txtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sub_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_cap.
function btn_cap_Callback(hObject, eventdata, handles)
%%

global StopState;
StopState = 0;

% Initiate Neurosky Library
maks = 10240;
data = zeros(1,maks); %holder for 10 minutes EEG data

portNum = 3;
comPortName1 = sprintf('\\\\.\\COM%d', portNum);
TG_BAUD_57600 = 57600;
TG_STREAM_PACKETS = 0;
TG_DATA_RAW = 4;
loadlibrary('Thinkgear.dll');


userInput = get(handles.sub_txtbox,'String');

%%
% Neurosky Connection Error Handling
% Get a connection ID handle to ThinkGear
connectionId1 = calllib('Thinkgear', 'TG_GetNewConnectionId');
if ( connectionId1 < 0 )
    error( sprintf( 'ERROR: TG_GetNewConnectionId() returned %d.\n', connectionId1 ) );
end;

% Set/open stream (raw bytes) log file for connection
errCode = calllib('Thinkgear', 'TG_SetStreamLog', connectionId1, 'streamLog.txt' );
if( errCode < 0 )
    error( sprintf( 'ERROR: TG_SetStreamLog() returned %d.\n', errCode ) );
end;

% Set/open data (ThinkGear values) log file for connection
errCode = calllib('Thinkgear', 'TG_SetDataLog', connectionId1, 'dataLog.txt' );
if( errCode < 0 )
    error( sprintf( 'ERROR: TG_SetDataLog() returned %d.\n', errCode ) );
end;

% Attempt to connect the connection ID handle to serial port "COM3"
errCode = calllib('Thinkgear', 'TG_Connect',  connectionId1,comPortName1,TG_BAUD_57600,TG_STREAM_PACKETS );
if ( errCode < 0 )
    error( sprintf( 'ERROR: TG_Connect() returned %d.\n', errCode ) );
end

fprintf( 'Connected.  Reading Packets...\n' );

%%
%record data

j = 0;
i = 0;
while (i < maks)   %loop for 20 seconds
    if (calllib('Thinkgear','TG_ReadPackets',connectionId1,1) == 1)   %if a packet was read...

        if (calllib('Thinkgear','TG_GetValueStatus',connectionId1,TG_DATA_RAW) ~= 0)   %if RAW has been updated 
            j = j + 1;
            i = i + 1;
            data(j) = calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_RAW);
            total(i) = calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_RAW);
        end
    end


    if (j == 256)
        handles.data = data;
        plot(handles.data)
        axis([0 255 -2000 2000])
        drawnow;            %plot the data, update every .5 seconds (256 points)
        j = 0;
    end
    
    if StopState == 1
        assignin('base', userInput, total);
        calllib('Thinkgear', 'TG_FreeConnection', connectionId1 );
        break;
    end

end

assignin('base', userInput, total);
calllib('Thinkgear', 'TG_FreeConnection', connectionId1 );


% --- Executes on button press in btn_disconnect.
function btn_disconnect_Callback(hObject, eventdata, handles)
% hObject    handle to btn_disconnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global StopState;
StopState = 1;