function mean_t1(all_sub_id)
% ________________________________________________________________________________________
% Create a mean image of the structural t1 images 
% 
% author: ole.goltermann@maxplanckschools.de
% 
% ----------------------------------------------------------------------------------------
%
% Script checks how many t1 images were made, realigns them and calculates
% an average
%
% All T1s are stored twice (different contrasts?) -> we only use the
% brighter appearing ones, no consistency of how they named, but they are
% always stored as the second one for the corresponding run
%
% output: 
%
% ----------------------------------------------------------------------------------------
%
% TODO: 
% Quick and dirty script --> clean up and write it as function 
% TODO 1: integrate path function 
% TODO 2: check if script/function has already been executed
% ________________________________________________________________________________________

clear matlabbatch files

% ---------- set paths -------------------------------------------------------------------

dir_der = '/home/goltermann/checkerboardVASO/data/derivatives/spm_preproc';
dir_raw_anat = '/home/goltermann/checkerboardVASO/data/raw/anat';

% check if script has already been executed before

% TODO 2: implement here

%---------- prepare folders for later loops ----------------------------------------------

% get amount of subjects and save names into a cell array
dir_sub = dir([dir_raw_anat '/sub-*']);
subs = numel(dir_sub([dir_sub(:).isdir]));
subDirsNames = {dir_sub(1:end).name};
subjects = zeros(1,subs);
for s = 1:subs
    subjects(s) = str2double(regexp(string(subDirsNames(s)),'\d*','Match'));
end

% get amount of anatomical images for each subject
run = zeros(1,subs);
for s = 1:subs
    dir_run = dir([dir_raw_anat '/' char(subDirsNames(s)) '/anat*']);
    run(s) = numel(dir_run([dir_run(:).isdir]));
end

%---------- run realignment and average --------------------------------------------------

matlabbatch = cell(1,subs);

% subject loop for SPM batch 
for s = 1:subs
    dir_sub = fullfile(dir_raw_anat, sprintf('sub-0%d',subjects(s)));
    dir_t1 = dir(fullfile(dir_sub,'anat_*','*.nii'));
    array_t1 = fullfile({dir_t1.folder},{dir_t1.name});
    all_t1 = vertcat(array_t1{:});
    files_t1 = cellstr(all_t1(2:2:end,:));

    % create batch for estimate & write 
    matlabbatch{s}.spm.spatial.realign.estwrite.data             = {files_t1};
    matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.quality = 1;
    matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.sep     = 1.2;
    matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.fwhm    = 1;
    matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.rtm     = 1;
    matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.interp  = 7;
    matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.wrap    = [0 0 0];
    matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.weight  = {''};
    matlabbatch{s}.spm.spatial.realign.estwrite.roptions.which   = [2 1];
    matlabbatch{s}.spm.spatial.realign.estwrite.roptions.interp  = 7;
    matlabbatch{s}.spm.spatial.realign.estwrite.roptions.wrap    = [0 0 0];
    matlabbatch{s}.spm.spatial.realign.estwrite.roptions.mask    = 1;
    matlabbatch{s}.spm.spatial.realign.estwrite.roptions.prefix  = 'r';

end

spm_jobman('run',matlabbatch);
clear matlabbatch files

% subject loop for move and clean files
for s = 1:subs
    dir_der_sub = fullfile(dir_der, sprintf('sub-0%d',subjects(s)),'anat');
    if not(isfolder(dir_der_sub))
        mkdir(dir_der_sub);
        dir_sub = fullfile(dir_raw_anat, sprintf('sub-0%d',subjects(s)));
        dir_sub_mean = dir(fullfile(dir_sub,'anat_*','mean*.nii'));
        file_mean = fullfile(dir_sub_mean.folder,dir_sub_mean.name);
        movefile(file_mean,dir_der_sub)
    end
end







