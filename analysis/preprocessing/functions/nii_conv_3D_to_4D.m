function nii_conv_3D_to_4D(all_sub_id)
% ________________________________________________________________________________________
% Create 4D nifti
% 
% author: ole.goltermann@maxplanckschools.de
% 
% ----------------------------------------------------------------------------------------
%
% Script creates 4D niftis for every run and excludes dummies
%
% output: 
%
% ----------------------------------------------------------------------------------------
%
% TODO: 
% Quick and dirty script --> clean up and write it as function 
% ________________________________________________________________________________________

% ---------- set paths -------------------------------------------------------------------

% data
raw_func_dir = '/home/goltermann/checkerboardVASO/data/raw/func';

%---------- prepare folders for later loops ----------------------------------------------

% get amount of subjects and save names into a cell array
dir_sub = dir([raw_func_dir '/sub-*']);
subs = numel(dir_sub([dir_sub(:).isdir]));
subDirsNames = {dir_sub(1:end).name};
subjects = zeros(1,subs);
for s = 1:subs
    subjects(s) = str2double(regexp(string(subDirsNames(s)),'\d*','Match'));
end

% get amount of sessions for each subject
ses = zeros(1,subs);
for s = 1:subs
    dir_ses = dir([raw_func_dir '/' char(subDirsNames(s)) '/ses*']);
    ses(s) = numel(dir_ses([dir_ses(:).isdir]));
end

%---------- if not done already exclude dummies ------------------------------------------

for s = 1:subs
    for b = 1:blocks(s)
        rundir = fullfile(basedir, char(subDirsNames(s)),sprintf('/Raw/Run%d',b));
        dum_dir = fullfile(rundir, 'dummy');
        files = spm_select('FPList',rundir,'.nii');
        scans_end = size(files,1) - scans_pain(b,s) - dum_scans(b,s);
        % check if dummy dir already exists, if not create and move scans
        if not(isfolder(dum_dir))
            if scans_pain(b,s)+dum_scans(b,s) < size(files,1)
                if size(files,1) ~= scans_pain(b,s) + dum_scans(b,s) + scans_end
                    error('Error: Probably already moved dummies for %s, Run0%d\n', char(subDirsNames(s)), b)
                end
                dummies_start = files(1:dum_scans(b,s),:);
                dummies_end = files(end-scans_end+1:end,:);% these are scans during the rating in the end
                mkdir(dum_dir)
                move = [dummies_start; dummies_end];
                for f=1:size(move,1)
                    movefile(move(f,:),dum_dir);
                end
            else 
                fprintf('There seems to be a problem with %s, Run0%d - not enough scans in folder\n', char(subDirsNames(s)), b);
            end
        else 
            fprintf('Already a dummy folder for %s, Run0%d\n', char(subDirsNames(s)), b);
        end
    end
end








