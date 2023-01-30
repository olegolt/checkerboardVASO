function denoise_t1(all_sub_id)
% ________________________________________________________________________________________
% Create a mean image of the structural t1 images 
% 
% author: ole.goltermann@maxplanckschools.de
% 
% ----------------------------------------------------------------------------------------
%
% Script applies a denoising technique (adaptive non-local means denoising of MR images
% with spatially varying noise levels) for the (averaged) t1 using the cat12 toolbox
%
% Link to manual cat12: https://neuro-jena.github.io/cat12-help/
% Paper the method is based on: https://pubmed.ncbi.nlm.nih.gov/20027588/
%
% output: 'sanlm_*.nii'
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

%---------- prepare folders for later loops ----------------------------------------------

matlabbatch = cell(1,subs);

for s = 1:subs
    dir_sub = fullfile(dir_der,sprintf('sub-%02.2d',subjects(s)),'anat');
    mean_t1 = cellstr(spm_select('ExtFPList', dir_sub, 'mean*'));
    matlabbatch{s}.spm.tools.cat.tools.sanlm.data = mean_t1;
    matlabbatch{s}.spm.tools.cat.tools.sanlm.spm_type = 16;
    matlabbatch{s}.spm.tools.cat.tools.sanlm.prefix = 'sanlm_';
    matlabbatch{s}.spm.tools.cat.tools.sanlm.suffix = '';
    matlabbatch{s}.spm.tools.cat.tools.sanlm.intlim = 100;
    matlabbatch{s}.spm.tools.cat.tools.sanlm.rician = 0;
    matlabbatch{s}.spm.tools.cat.tools.sanlm.replaceNANandINF = 1;
    matlabbatch{s}.spm.tools.cat.tools.sanlm.nlmfilter.optimized.NCstr = 4;
end

spm_jobman('run',matlabbatch);
clear matlabbatch files