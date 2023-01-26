function [finalRating] = VAS(window2,windowRect,nRatingSteps,scale,ratingLabels,defaultRating,scaleWidth,textSize,lineWidth,tickHeight,scaleColor,activeColor,ticTextGap,TextFont)
global confirmKey leftKey rightKey escapeKey breakExperiment TriggerPulse Save h


question = scale.question;
hi_label = scale.hi_label;
low_label = scale.low_label;
 
%Skalenendpunkte
anchorWidth = 5; % breite anchor point scale
anchorHeigth = 4; % h�he anchor point scale

gray = [1 1 1]*127;
if nargin < 1; window2 = []; end
if nargin < 2; windowRect = []; end
if nargin < 3; nRatingSteps = []; end

if nargin < 5; ratingLabels = []; end
if nargin < 6; defaultRating = []; end
if nargin < 7; scaleWidth = []; end
if nargin < 8; textSize = []; end
if nargin < 9; lineWidth = []; end
if nargin < 10; tickHeight = [0]; end
if nargin < 11; scaleColor = []; end
if nargin < 12; activeColor = []; end
if nargin < 13; ticTextGap = [8]; end
if nargin < 14; TextFont = []; end

if isempty(window2); error('Please provide window2 pointer for mb_likertScale!'); end
if isempty(windowRect); error('Please provide window2 rect for mb_likertScale!'); end
if isempty(nRatingSteps); error('Number of rating steps has to be specified!'); end
if isempty(ratingLabels)
%     disp('No labels specified. Using enumeration as default.')
    for i = 1:nRatingSteps
        ratingLabels{i} = num2str(i);
    end
end

%% Default values
jitterCursor= 50;
if isempty(defaultRating); defaultRating = jitterCursor; end%round(nRatingSteps/2); end
if isempty(scaleWidth); scaleWidth = round(windowRect(3)/3); end
if isempty(textSize); textSize = 30; end
if isempty(lineWidth); lineWidth = 6; end
if isempty(tickHeight); tickHeight = 20; end
if isempty(scaleColor); scaleColor = [1,1,1]*255; end
if isempty(activeColor); activeColor = [20,200,255]; end
if isempty(ticTextGap); ticTextGap = 8; end
% if isempty(ratingLabels); ratingLabels = 500; end
% if isempty(nRatingSteps); nRatingSteps = 500; end
if isempty(TextFont); TextFont = 'Arial'; end 
% Screen('TextFont',window2,'Arial');%define font

if length(ratingLabels) ~= nRatingSteps
    error('Rating steps and label numbers do not match')
end


%% Calculate rects
% screenWidth = windowRect(3);% [0 0 (1920) 1200]
% screenHeight = windowRect(4);% [0 0 1920 (1200)]
activeAddon = 4; % width of green cursor
[xCenter, yCenter] = RectCenter(windowRect);
%axesRect= Coordinates of scale, represented by white scale line;
%axesRect -> vector with 4 numbers: axesRect(1)=start x axis, axesRect(2)=start y axis
%axesRect(3)=end x axis, axesRect(4)=end y axis
axesRect = [xCenter - scaleWidth/2; yCenter - lineWidth; xCenter + scaleWidth/2; yCenter];
ticPositions = linspace(xCenter - scaleWidth/2,xCenter + scaleWidth/2-lineWidth,nRatingSteps);
ticRects = [ticPositions;ones(1,nRatingSteps)*yCenter;ticPositions + lineWidth;ones(1,nRatingSteps)*yCenter+tickHeight];
%CursorRects: -10 and -5 to put the cursor in the middle of the scale
activeTicRects = [ticPositions-activeAddon;ones(1,nRatingSteps)*yCenter-10;ticPositions + lineWidth+activeAddon;ones(1,nRatingSteps)*yCenter+tickHeight+5];

Screen('TextSize', window2,textSize);
Screen('TextFont',window2,TextFont);%define font
Screen('TextStyle',window2,1);% define textstyle (1=bold)
currentRating = defaultRating;
interruptMeasurement = 0;
finalRating = nan; %Outcome



while 1
    Screen('FillRect',window2,gray);
    Screen('FillRect',window2,scaleColor,[axesRect,ticRects]);
    Screen('FillRect',window2,activeColor,activeTicRects(:,currentRating));
    %Labels an Skala ausrichten, nicht h�ndisch
    Screen('DrawText',window2,question,xCenter-250,yCenter-100,255);
    Screen('DrawText', window2, hi_label,axesRect(3)-100,axesRect(2)+50,255);
    Screen('DrawText',window2,low_label,axesRect(1)/2,axesRect(2)+50,255);
    Screen('FillRect', window2,scaleColor,[axesRect(1)-anchorWidth,axesRect(2)-anchorHeigth,axesRect(1),axesRect(4)+anchorHeigth]);
    Screen('FillRect',window2,scaleColor,[axesRect(3),axesRect(2)-anchorHeigth,axesRect(3)+anchorWidth,axesRect(4)+anchorHeigth]);
    
%     for i = 1:nRatingSteps
% %         Screen('TextSize', window2,textSize);
% %         Screen('TextFont',window2,'Arial');%define font
% %         Screen('TextStyle',window2,1);% define textstyle (1=bold)
%         textRect = Screen('TextBounds',window2,ratingLabels{i});
%         Screen('DrawText',window2,ratingLabels{i},round(ticRects(1,i)-textRect(3)/2),ticRects(4,i) + ticTextGap,gray);   
%     end
   Screen('Flip',window2);
    
    % Remove this line if a continuous key press should result in a
    % continuous change of the scale
%     while KbCheck; end
    
    while 1 % this creates an infinite loop
        
        [ keyIsDown, ~, keyCode ] = KbCheck; % this checks the keyboard very, very briefly.
        WaitSecs(1/1000);
        if keyIsDown % only if a key was pressed we check which key it was
            if keyCode(rightKey) % if it was the key we named key1 at the top then...
                
                currentRating = currentRating + 1;
                if currentRating > nRatingSteps
                    currentRating = nRatingSteps;
                end
                Save.Time(h,1)=toc(uint64(Save.Time(1,1)));
                Save.Stim(h,1)={'right key pressed'};
                h=h+1;  
                
                break; % now we can exit the otherwise infinite loop
                
            elseif keyCode(leftKey)
                currentRating = currentRating - 1;
                if currentRating < 1
                    currentRating = 1;
                end
                Save.Time(h,1)=toc(uint64(Save.Time(1,1)));
                Save.Stim(h,1)={'left key pressed'};    
                h=h+1;                  
                break; % now we can exit the otherwise infinite loop
            elseif keyCode(escapeKey)
                breakExperiment=1;
                interruptMeasurement = 1;
                Save.Time(h,1)=toc(uint64(Save.Time(1,1)));
                Save.Stim(h,1)={'escape key pressed'};  
                h=h+1;                  
                break;
            elseif keyCode(confirmKey)
                interruptMeasurement = 1;
                finalRating = currentRating;
                Save.Time(h,1)=toc(uint64(Save.Time(1,1)));
                Save.Stim(h,1)={'confirm key pressed'}; 
                h=h+1;                  
                break;
            elseif find(keyCode)==TriggerPulse
                Save.Time(h,1)=toc(uint64(Save.Time(1,1)));
                Save.Stim(h,1)={'MR pulse'};
                h=h+1;  
                break;
            end
        end
    end
    
    if interruptMeasurement
        break;
    end
    
end