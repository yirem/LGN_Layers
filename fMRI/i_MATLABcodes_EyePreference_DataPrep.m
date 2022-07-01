clear all

Task = ['Monocular'; 'Dichoptic']; 
ROIs = ['lLGN_func'; 'rLGN_func']; %functionally adjusted anatomical LGN masks

for t = 1:size(Task,1)
    for s = 1:3 %for each subject
        datadir = sprintf('../data/sub-0%d/fMRI/%s',s,Task(t,:));
               
        for r = 1:size(ROIs,1) %for each ROI            
            fprintf('sub-0%d, %s, T stats, %s\n', s, Task(t,:), ROIs(r,:));
            %GLM results in the data folder in this package:
            fname= sprintf('t_LEvsRE_%s.nii.gz',ROIs(r,:)); %T for LE>RE contrast
            
            %load the t values 
            rawdata = niftiread(fullfile(datadir,fname)); 
            w=find(rawdata~=0);% get the locations of nonzero 
            data = rawdata(w);  % a vector 
            
            R1 = data<0; %RE voxels
            L1 = data>0; %LE voxels          
            %store data           
            d.index{s,r}(:,t)=data;
            data(L1==1)=1;
            data(R1==1)=-1;
            d.index_labels{s,r}(:,t)=data;
            d.index_labels_id=['-1: RE voxel'; '+1: LE voxel'];
            d.id{s,r}(:,t) = sprintf('S%s_%s_%s',Subj(s),ROIs(r),Task(t));          
        end
    end    
end
save ('DATA_EyePreference_T','d')