% Orthogonal Projective NonNegative Matrix Factorization (OPNMF) as unsupervised
% technique in segregating the monocular eye signals in the LGN

% This code uses the OPNMF package available at 
% https://github.com/asotiras/brainparts
% The brainparts-master from this link must be downloaded inside this
% folder

addpath brainparts-master

% This code uses the fMRI data from eye-specific stimulation in left and right
% LGN of 3 subjects, as stored in 'fMRIData_EyeLGN_monocular.mat' and 'fMRIData_EyeLGN_dichoptic.mat'
% Monocular task required Ss to close one eye at a time:
%   15 sec L or R eye stimulation + 5 sec blank + 1 sec visual cue
%   indicating which eye to close
% Dichoptic task showed stimulus to one eye and blank to the other:
%   16 sec L or R eye stimulation + 5 sec blank

% The data (I) shows the raw data volumes across all the runs.
% Each run lasted 300s, our TR was 1.5 sec.
% We delayed all the conditions by 6s to account for the hemodynamic response latency
% We also took out the motion outlier volumes for each subject.

ROIs = {'lLGN' 'rLGN'};
cond={'monocular' 'dichoptic' 'combined'};
k=2; %number of components
%outdir=sprintf('Results_k%d',k);
outdir=pwd;

for c=1:length(cond) % for each task

    for s = 1:3 %for each subject
        
        %load the volumetric data file
        %this file includes the struct EyeStim
        if c==1
            load('fMRIData_EyeLGN_monocular.mat')
            EyeStim_monocular=EyeStim;
        elseif c==2
            load('fMRIData_EyeLGN_dichoptic.mat')
            EyeStim_dichoptic=EyeStim;
        else %combined data
            clear EyeStim
            EyeStim(s).I=[EyeStim_monocular(s).I, EyeStim_dichoptic(s).I];
            EyeStim(s).labels=[EyeStim_monocular(s).labels, EyeStim_dichoptic(s).labels];
        end
        
        for r = 1:length(ROIs) %for each ROI

            fname=sprintf('sub-0%d_%s_%s',s,cond{c},ROIs{r});
            fprintf('%s\n',fname)


            % make volumetric data 1D
            dim=size(EyeStim(s).I{r,1}); n_vox= prod(dim);
            X=single.empty(0,length(EyeStim(s).I));

            for t=1:length(EyeStim(s).I)
                X(1:n_vox,t)=reshape(EyeStim(s).I{r,t},[n_vox 1]);
            end

            %the data includes zero values for the voxels that were not part
            %of the LGN, find them
            a=find(X(:,1)==0);
            %store their placement info so that we can add them later
            v=ones(size(X,1),1); v(a)=0;
            X(a,:)=[]; %take the NaN values out

            % X: nonnegative data input (D times N) D = #voxels, N = #time points
            % W: the factorizing matrix (D times K)
            % H: expansion coefficients

            [W, H] = opnmf_mem(double(X), k);
            save(fullfile(outdir,fname),'W', 'H','dim','v')

            %correct the weights for voxels by adding the voxels with Nan
            %values, give 0 for them so that in the nifti file they look
            %empty
            Wcorr=single.empty(0,k);
            j=0;
            for i=1:length(v)
                if v(i)==0
                    Wcorr(i,:)=0;
                else
                    j=j+1;
                    Wcorr(i,:)=W(j,:);
                end
            end
            %reshape the weights to be volumetric data
            Wcorr3D = nan(dim(1),dim(2),dim(3),k);
            for i=1:k
                Wcorr3D(:,:,:,i) = reshape(Wcorr(:,i),dim);
                niftiwrite(Wcorr3D(:,:,:,i),fullfile(outdir,sprintf('%s_W%d.nii',fname,i)),'Compressed',true);
            end
        end
    end
end
