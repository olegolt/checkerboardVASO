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
%   TODO 1: automatize dummy calculation and include error message
%   TODO 2: loop to get dir names could be included in a function
%   TODO 3: integrate parallel processing
% ________________________________________________________________________________________

% ---------- set paths -------------------------------------------------------------------

% data
dir_der = '/home/goltermann/checkerboardVASO/data/derivatives';
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

% get amount of runs for each subject
run = zeros(1,subs);
for s = 1:subs
    dir_run = dir([raw_func_dir '/' char(subDirsNames(s)) '/run*']);
    run(s) = numel(dir_run([dir_run(:).isdir]));
end

%---------- if not done already exclude dummies ------------------------------------------

dummy = 3; % 3 for VASO, 3 for BOLD

for s = 1:subs
    for b = 1:run(s)
        dir_run = fullfile(raw_func_dir, sprintf('/sub-0%d/run-0%d',s,b));
        % get names of the folders inside run directory (VASO/BOLD, magn/phas)
        files = dir(dir_run);
        dir_log= [files.isdir];
        sub_folders = files(dir_log);
        subFolderNames = {sub_folders(3:end).name};
        % acess the VASO/BOLD, magn/phas folders
        for f = 1:length(subFolderNames)
            dir_seq = fullfile(dir_run, char(subFolderNames(f)));
            dir_dum = fullfile(dir_seq, 'dummy');
            % select all files in dir_seq folder
            files = spm_select('FPList',dir_seq,'.nii');
            % TODO 1: automatize dummy calculation and include error
            % message
            if not(isfolder(dir_dum))
                dummies = files(1:dummy,:);
                mkdir(dir_dum)
                for i=1:size(dummies,1)
                    movefile(dummies(i,:),dir_dum);
                end
            else
                fprintf('Already a dummy folder for sub-0%d_%s\n', ...
                    s,char(subFolderNames(f)))
            end
        end
    end
end

%---------- create 4D nifti --------------------------------------------------------------

for s = 1:subs
    dir_save = fullfile(dir_der, sprintf('/spm_preproc/sub-0%d/func/',s));
    % check if 4D folder is already there
    if not(isfolder(dir_save))
        mkdir(dir_save);
        for b = 1:run(s)
            dir_run = fullfile(raw_func_dir, sprintf('/sub-0%d/run-0%d',s,b));
            % get names of the folders inside run directory (VASO/BOLD, magn/phas)
            files = dir(dir_run);
            dir_log= [files.isdir];
            sub_folders = files(dir_log);
            subFolderNames = {sub_folders(3:end).name};
            % acess the VASO/BOLD, magn/phas folders
            for f = 1:length(subFolderNames)
                dir_seq = fullfile(dir_run, char(subFolderNames(f)));
                files = spm_select('FPList', dir_seq,'^fPRISMA.*.nii$');
                scans = spm_vol(files);
                spm_file_merge(scans,fullfile(dir_save,[char(subFolderNames(f)),'.nii']));
            end
            clear scans files
        end
    else
        fprintf('Already converted for sub-0%d\n',s)
    end
end

