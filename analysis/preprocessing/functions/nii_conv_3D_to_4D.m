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

dummy = 3; % 3 for VASO, 3 for BOLD

for s = 1:subs
    for b = 1:ses(s)
        dir_ses = fullfile(raw_func_dir, sprintf('/sub-0%d/ses-0%d',s,b));
        % get names of the folders inside session directory (VASO/BOLD, magn/phas)
        files = dir(dir_ses);
        dir_log= [files.isdir];
        sub_folders = files(dir_log);
        subFolderNames = {sub_folders(3:end).name};
        % acess the VASO/BOLD, magn/phas folders
        for f = 1:length(subFolderNames)
            dir_seq = fullfile(dir_ses, char(subFolderNames(f)));
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
                fprintf('Already a dummy folder')
            end
        end
    end
end







