function realign(all_sub_id)
% ________________________________________________________________________________________
% Realign nulled (VASO) and notnulled (BOLD) images
% 
% author: ole.goltermann@maxplanckschools.de
% 
% ----------------------------------------------------------------------------------------
%
% Script realigns both series independently, first VASO than BOLD and
% compares realignment parameters. Images cannot be aligned together
% because VASO and BOLD contrasts differ too much
% 
%
% output: 'mc_<run1>_[nulled*.nii'
%
% Run1 used a different flip angle (19 vs. 60), have to decide how to deal
% with it
%
% ----------------------------------------------------------------------------------------
%
% TODO: 
% Quick and dirty script --> clean up and write it as function 
% TODO 1: integrate path function 
% TODO 2: run_paralell
% ________________________________________________________________________________________

% ---------- set paths -------------------------------------------------------------------

dir_der = '/home/goltermann/checkerboardVASO/data/derivatives/spm_preproc';
dir_raw_func = '/home/goltermann/checkerboardVASO/data/raw/func';
%---------- prepare folders for later loops ----------------------------------------------

% get amount of subjects and save names into a cell array
dir_subs = dir([dir_der '/sub-*']);
subs = numel(dir_subs([dir_subs(:).isdir]));
subDirsNames = {dir_subs(1:end).name};
subjects = zeros(1,subs);
for s = 1:subs
    subjects(s) = str2double(regexp(string(subDirsNames(s)),'\d*','Match'));
end

% get amount of runs for each subject
run = zeros(1,subs);
for s = 1:subs
    dir_run = dir([dir_raw_func '/' char(subDirsNames(s)) '/run*']);
    run(s) = numel(dir_run([dir_run(:).isdir]));
end

%---------- realignment of nulled (VASO) -------------------------------------------------

matlabbatch = cell(1,subs);

for s=1:subs
    dir_sub = fullfile(dir_der,sprintf('sub-%02.2d/func',subjects(s)));
    for b=1:run(s)
        mask = fullfile(dir_sub,'mask.nii');
        run_pattern = sprintf('run_%d_nulled_magn.nii',b);
        files{b} = cellstr(spm_select('ExtFPList', dir_sub, run_pattern));
        % create batch for estimate & write 
        matlabbatch{s}.spm.spatial.realign.estwrite.data             = files;
        matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.quality = 1;
        matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.sep     = 1.2;
        matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.fwhm    = 1;
        matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.rtm     = 1;
        matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.interp  = 7;
        matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.wrap    = [0 0 0];
        matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.weight  = {mask};
        matlabbatch{s}.spm.spatial.realign.estwrite.roptions.which   = [2 1];
        matlabbatch{s}.spm.spatial.realign.estwrite.roptions.interp  = 7;
        matlabbatch{s}.spm.spatial.realign.estwrite.roptions.wrap    = [0 0 0];
        matlabbatch{s}.spm.spatial.realign.estwrite.roptions.mask    = 1;
        matlabbatch{s}.spm.spatial.realign.estwrite.roptions.prefix  = 'mc_';
    end
end

spm_jobman('run',matlabbatch);
clear matlabbatch files

%---------- realignment of notnulled (BOLD) -------------------------------------------------

matlabbatch = cell(1,subs);

for s=1:subs
    dir_sub = fullfile(dir_der,sprintf('sub-%02.2d/func',subjects(s)));
    for b=1:run(s)
        mask = fullfile(dir_sub,'mask.nii');
        run_pattern = sprintf('run_%d_notnulled_magn.nii',b);
        files{b} = cellstr(spm_select('ExtFPList', dir_sub, run_pattern));
        % create batch for estimate & write 
        matlabbatch{s}.spm.spatial.realign.estwrite.data             = files;
        matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.quality = 1;
        matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.sep     = 1.2;
        matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.fwhm    = 1;
        matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.rtm     = 1;
        matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.interp  = 7;
        matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.wrap    = [0 0 0];
        matlabbatch{s}.spm.spatial.realign.estwrite.eoptions.weight  = {mask};
        matlabbatch{s}.spm.spatial.realign.estwrite.roptions.which   = [2 1];
        matlabbatch{s}.spm.spatial.realign.estwrite.roptions.interp  = 7;
        matlabbatch{s}.spm.spatial.realign.estwrite.roptions.wrap    = [0 0 0];
        matlabbatch{s}.spm.spatial.realign.estwrite.roptions.mask    = 1;
        matlabbatch{s}.spm.spatial.realign.estwrite.roptions.prefix  = 'mc_';
    end
end

spm_jobman('run',matlabbatch);
clear matlabbatch files

