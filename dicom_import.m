% ________________________________________________________________________________________
% DICOM import
% 
% author: ole.goltermann@maxplanckschools.de
% 
% ----------------------------------------------------------------------------------------
%
% Script uses 'dicq' function on NIN servers to search for subjects data
% based on PRISMA number, imports functional VASO/BOLD data and anatomical t1 images
%
% ----------------------------------------------------------------------------------------
%
% TODO: 
% Quick and dirty script --> clean up and write it as function (similar to 
% https://github.com/ag-buechel/preprocessing/blob/master/preprocessing/dicom_import.m
% ________________________________________________________________________________________

batch_nr = 1;
prisma_id = 24515;
sub_folder  = '/home/goltermann/VASO_180123';
runs = 3;


[~, folders_txt] = system(sprintf('dicq -f PRISMA_%d',prisma_id));

% 1: mprage (anatomical T1-weighted image)
exp ='(?<=mprage.*] ).*/.*(?=\n)';
d_names_anat = regexp(folders_txt,exp,'match','dotexceptnewline');

% 2: fmri ep2d_bold,..., fMRI (runs 1-6) 
exp ='(?<=vaso.*] ).*/.*(?=\n)';
d_names_fMRI = regexp(folders_txt,exp,'match','dotexceptnewline');

% anatomical images fnames
for d = 1:length(d_names_anat)
    d_name              = d_names_anat{d};
    fnames_anat{d}      = spm_select('List',d_name,'^MR');
    full_fnames_anat{d} = strcat(d_names_anat{d},'/',fnames_anat{d});
end
    
% fMRI images fnames
for d = 1:length(d_names_fMRI)
    d_name              = d_names_fMRI{d};
    fnames_fMRI{d}      = spm_select('List',d_name,'^MR');
    full_fnames_fMRI{d} = strcat(d_names_fMRI{d},'/',fnames_fMRI{d});
end

% anatomical
for b = 1:length(full_fnames_anat)
    matlabbatch{batch_nr}.spm.util.import.dicom.data = cellstr(full_fnames_anat{b});
    matlabbatch{batch_nr}.spm.util.import.dicom.root = 'flat';
    
    if length(full_fnames_anat) > 1
        if ~exist(fullfile(sub_folder,sprintf('anat_%d',b)), 'dir')
                        mkdir(fullfile(sub_folder,sprintf('anat_%d',b)));
        end
        matlabbatch{batch_nr}.spm.util.import.dicom.outdir = {fullfile(sub_folder,sprintf('anat_%d',b))};
    else
        if ~exist(fullfile(sub_folder,'anat'), 'dir')
                        mkdir(fullfile(sub_folder,'anat'));
        end
        matlabbatch{batch_nr}.spm.util.import.dicom.outdir = {fullfile(sub_folder,'anat')};
    end
    matlabbatch{batch_nr}.spm.util.import.dicom.protfilter = '.*';
    matlabbatch{batch_nr}.spm.util.import.dicom.convopts.format = 'nii';
    matlabbatch{batch_nr}.spm.util.import.dicom.convopts.meta = 0;
    matlabbatch{batch_nr}.spm.util.import.dicom.convopts.icedims = 0;
    
    batch_nr = batch_nr + 1;
                
end

spm_jobman('run',matlabbatch)

clear matlabbatch batch_nr

batch_nr = 1;

% prepare loops for below
img = 4; % number of functional images per run (VASO magn/phas, BOLD magn/phas)

% create cell with 3 vectors for each run 
v = [1:runs*img]';
n = numel(v);
c = mat2cell(v,diff([0:img:n-1,n]));

for r = 1:runs

    % create run folder
    runfolder = fullfile(sub_folder,'func',sprintf('run_%d',r));

    if ~exist(runfolder,'dir')
        mkdir(runfolder);
    end

    % select corresponding values for run
    c_run = c{r}';

    names = {sprintf('VASO_magn_run_%d',r), ...
             sprintf('VASO_phas_run_%d',r), ...
             sprintf('BOLD_magn_run_%d',r), ...
             sprintf('BOLD_phas_run_%d',r)}; 

    for b = 1:length(c_run)

        folder = fullfile(runfolder,char(names(b)));
        if ~exist(folder, 'dir')
            mkdir(folder);
        end

        matlabbatch{batch_nr}.spm.util.import.dicom.data = cellstr(full_fnames_fMRI{c_run(b)});
        matlabbatch{batch_nr}.spm.util.import.dicom.root = 'flat';
        matlabbatch{batch_nr}.spm.util.import.dicom.outdir = {folder};
        matlabbatch{batch_nr}.spm.util.import.dicom.protfilter = '.*';
        matlabbatch{batch_nr}.spm.util.import.dicom.convopts.format = 'nii';
        matlabbatch{batch_nr}.spm.util.import.dicom.convopts.meta = 0;
        matlabbatch{batch_nr}.spm.util.import.dicom.convopts.icedims = 0;
   
    batch_nr = batch_nr + 1;

    end

end


spm_jobman('run',matlabbatch)
