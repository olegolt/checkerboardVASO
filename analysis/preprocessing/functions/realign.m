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
% ________________________________________________________________________________________

% ---------- set paths -------------------------------------------------------------------

dir_der = '/home/goltermann/checkerboardVASO/data/derivatives/spm_preproc';

%---------- prepare folders for later loops ----------------------------------------------

% get amount of subjects and save names into a cell array
dir_subs = dir([dir_der '/sub-*']);
subs = numel(dir_subs([dir_subs(:).isdir]));
subDirsNames = {dir_subs(1:end).name};
subjects = zeros(1,subs);
for s = 1:subs
    subjects(s) = str2double(regexp(string(subDirsNames(s)),'\d*','Match'));
end