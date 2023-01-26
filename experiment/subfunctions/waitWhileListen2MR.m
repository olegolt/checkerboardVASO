function [Save2,h2]=waitWhileListen2MR(time2wait2,Save2,h2)
    global TriggerPulse escapeKey breakExperiment
    timewaited=0;
    disp(['waiting ' num2str(time2wait2) ' seconds.'])
    while timewaited<time2wait2
        [keyIsDown, ~, keyCode]=KbCheck(-1);%-1= listen to all keyboards
        if keyIsDown
            if find(keyCode)==TriggerPulse
                Save2.Time(h2,1)=toc(uint64(Save2.Time(1,1)));
                Save2.Stim(h2,1)={'MR pulse'};
                h2=h2+1;
            elseif find(keyCode)==escapeKey
                breakExperiment=1;
                Save.Time(h2,1)=toc(uint64(Save2.Time(1,1)));
                Save.Stim(h2,1)={'escape key pressed'};
                h2=h2+1;
                break;                
            end
        end
        WaitSecs(1/1000);
        timewaited=timewaited+1/1000;
    end
    KbReleaseWait;
end