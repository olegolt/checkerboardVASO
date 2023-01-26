% ________________________________________________________________________________________
% Checkerboard stimulus script
% 
% author: ole.goltermann@maxplanckschools.de
% 
% ----------------------------------------------------------------------------------------
%
% based on a script by Jan Mehnert, simple visual checkerboard task
% ________________________________________________________________________________________

clear;sca;close all;% clears and closes all screens

debug = 0;

if debug == 1
    path = 'D:\goltermann\debug\checker4ASL4testing';
else 
    path = 'D:\goltermann\checker4ASL4testing';
end
    
addpath([path '\dsub25'],...
    [path '\subfunctions'],...
    path);
log_path = [path '\log'];

%number of repetitions
nRep=20;
%jitter breaks? only if nRep is divisible by 10
jitter=0;
%stim length
stimLength=20;
%emulation?
MR=0;%MR=0 emulates MR triggers only!
if MR==0
    TR=5;
end
Screen('Preference', 'SkipSyncTests', 1);

currTime=clock;
fileNameAppendix=[num2str(currTime(1),'%02d') '_' num2str(currTime(2),'%02d') '_' num2str(currTime(3),'%02d') '_time_' num2str(currTime(4),'%02d') '_' num2str(currTime(5),'%02d')];

logFileName=fullfile(log_path, ['logChecker4ASL_' fileNameAppendix '.mat']);
studyName= 'Checker4ASL';

screens = Screen('Screens');% Get the scrWhich VASeen numbers

screenNumber = 2;% Draw to the external screen if avaliable: PC:0 Scanner:2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% global anables functions, that are called in this programme have access
% to these variables
global escapeKey TriggerPulse breakExperiment Save h

KbName('UnifyKeyNames');% allows to use one common naming scheme for all operating systems
% Defines key codes
escapeKey = KbName('ESCAPE');
TriggerPulse=KbName('5%');
breakExperiment=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stimuli
visual=128;
stimuli{1}={'visual'};
stimuli{2}=visual;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Start of the trials
TrialVector= ones(nRep,1)*visual;

if jitter
    jitter_ons= repmat(25:35,1);% jitters onset of the trial
else
    jitter_ons= repmat(20,1,nRep);
end
r=randperm (length(jitter_ons));
jitter_ons=jitter_ons(r);
Save.jitter=jitter_ons;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

red = [1 0 0]*255;%red= [ 255,0,0]
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
gray = [1 1 1]*127; %gray sceen instead of black --> more comfortable for the eyes

[window2, windowRect] = Screen('OpenWindow', screenNumber, gray);% opens gray window on screen
[screenXpixels, screenYpixels] = Screen('WindowSize', window2);% Get the size of screen window2
frameDuration = Screen('GetFlipInterval',window2);% gives duration of frame

% Setup the text type for the window2
Screen('TextSize',window2,40);% define text size
Screen('TextFont',window2,'Arial');%define font
Screen('TextStyle',window2,1);% define textstyle (1=bold)

%definition of screenwidth, height and center
screenWidth = windowRect(3);% [0 0 (1920) 1200]
screenHeight = windowRect(4);% [0 0 1920 (1200)]
screenCenterX = screenWidth/2;
screenCenterY = screenHeight/2;
% Get the centre coordinate of the window2
[xCenter, yCenter] = RectCenter(windowRect);

%definition of fixation cross
% set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
fixCrossDimPix = 60;% Size of the arms of our fixation cross
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
lineWidthPix =6;% Set the line width for our fixation cross

%images for visual stimlation
imdata=imread([path '\subfunctions\checker1.bmp']);
imagetex{1}=Screen('MakeTexture', window2, imdata);
imdata=imread([path '\subfunctions\checker2.bmp']);
imagetex{2}=Screen('MakeTexture', window2, imdata);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Start of the experiment

expStart='Das Experiment beginnt...';
% commented out next line -> not used and caused trouble (170123)
expStartSize = Screen('TextBounds',window2,expStart);% finds textsize for correct localisation
% DrawFormattedText(window2,expStart,screenCenterX-(expStartSize(3)/2),screenCenterY-200,white);% vorher y-200
Screen('DrawText', window2, expStart, xCenter/2, yCenter, white);
Screen('Flip', window2);

disp('experiment starts');

WaitSecs (2);

Screen('DrawLines', window2, allCoords, lineWidthPix, white, [xCenter yCenter], 0);
Screen('Flip', window2);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('waiting for first pulse');
h=1;
Save.Time(h,1)=double(tic);
Save.Stim(h,1)={'start'};
h=h+1;

if MR==0
    WaitSecs(TR);
    Save.Time(h,1)=toc(uint64(Save.Time(1,1)));
    Save.Stim(h,1)={'MR pulse emulated'};
    h=h+1;
    WaitSecs(TR);
    Save.Time(h,1)=toc(uint64(Save.Time(1,1)));
    Save.Stim(h,1)={'MR pulse emulated 2'};
    h=h+1;
else
    % 6 dummy pulses (3 VASO, 3 BOLD)
    % 1. dummy pulse
    KbTriggerWait(TriggerPulse);
    disp('Dummy pulse 1');
    Save.Time(h,1)=toc(uint64(Save.Time(1,1)));
    Save.Stim(h,1)={'MR dummy pulse 1 VASO end'};
    h=h+1;
    % 2. dummy pulse
    KbTriggerWait(TriggerPulse);
    disp('Dummy pulse 2');
    Save.Time(h,1)=toc(uint64(Save.Time(1,1)));
    Save.Stim(h,1)={'MR dummy pulse 2 BOLD end'};
    h=h+1;
    % 3. dummy pulse
    KbTriggerWait(TriggerPulse);
    disp('Dummy pulse 3');
    Save.Time(h,1)=toc(uint64(Save.Time(1,1)));
    Save.Stim(h,1)={'MR dummy pulse 3 VASO end'};
    h=h+1;
    % 4. dummy pulse
    KbTriggerWait(TriggerPulse);
    disp('Dummy pulse 4');
    Save.Time(h,1)=toc(uint64(Save.Time(1,1)));
    Save.Stim(h,1)={'MR dummy pulse 4 BOLD end'};
    h=h+1;
    % 5. dummy pulse
    KbTriggerWait(TriggerPulse);
    disp('Dummy pulse 5');
    Save.Time(h,1)=toc(uint64(Save.Time(1,1)));
    Save.Stim(h,1)={'MR dummy pulse 5 VASO end'};
    h=h+1;  
    % 6. dummy pulse
    KbTriggerWait(TriggerPulse);
    disp('Dummy pulse 6');
    Save.Time(h,1)=toc(uint64(Save.Time(1,1)));
    Save.Stim(h,1)={'MR dummy pulse 6 BOLD end'};
    h=h+1;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:length(TrialVector)
    
    disp(['Trial number: ' num2str(k)]);
    
    WaitSecs(jitter_ons(k));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% stimulation onset
    Save.Time(h,1)=toc(uint64(Save.Time(1,1)));
    Save.Stim(h,1)={['stimulation onset: ' char(stimuli{1}(find(stimuli{2}==TrialVector(k))))]};
    h=h+1;
    disp(['stimulation onset: ' char(stimuli{1}(find(stimuli{2}==TrialVector(k))))]);
    t=0;
    while t<stimLength
        Screen('DrawTexture', window2, imagetex{1});
        Screen('Flip', window2);
        WaitSecs(1/8-6/1000);
        Screen('DrawTexture', window2, imagetex{2});
        Screen('Flip', window2);
        WaitSecs(1/8-6/1000);
        t=toc(uint64(Save.Time(1,1)))-Save.Time(h-1,1);
    end
    Save.Time(h,1)=toc(uint64(Save.Time(1,1)));
    Save.Stim(h,1)={'stimulation end'};
    h=h+1;
    disp('stimulation end');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Screen('DrawLines', window2, allCoords, lineWidthPix, white, [xCenter yCenter], 0);
    Screen('Flip', window2);   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    save(logFileName,'Save');    %saves logfile
    if breakExperiment
        break;
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('experiment end');

Save.Time(h,1)=toc(uint64(Save.Time(1,1)));
Save.Stim(h,1)={'experiment end'};
h=h+1;

Screen('DrawLines', window2, allCoords, lineWidthPix, white, [xCenter yCenter], 0);
Screen('Flip', window2,0,0,0,0);

Time_ExperimentEnd = toc(uint64(Save.Time(1,1)));
save(logFileName,'Save');
disp('Stop experiment with ESC-key')
waitWhileListen2MR(600,Save,h); %breakExperiment with escape key

sca;
