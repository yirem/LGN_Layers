% To calculate the correlation, chi-square test and percent match across
% the monocular and dichoptic tasks
% uses the output from j_MATLABcodes_EyePreference_OPNMF.m

ROIs = {'lLGN' 'rLGN'};
cond={'monocular' 'dichoptic' 'combined'};
k=2; %number of components
%outdir=sprintf('Results_k%d',k);
outdir=pwd;

for s = 1:3 %for each subject
    for r = 1:length(ROIs) %for each ROI
        for c=1:length(cond)

            %load opnmf results in mat file, includes:
            %H: Coefficients for time series, W: Weights for voxels in 1D
            %dim: dimensions of 3D data, v: indicating voxels within and
            %outside LGN
            f=sprintf('%d_%s_%s',s,cond{c},ROIs{r});
            fprintf('%s\n',f)
            load(fullfile(outdir,f));
            fname=cell.empty(0,k);rawdata=fname; Hm=double.empty(0,k);
            for n=1:k
                %load opnmf results in nifti file, which are the W for
                %different components
                fname{n}=sprintf('%s_W%d.nii.gz',f,n);
                rawdata{n} = niftiread(fullfile(outdir,fname{n}));
                dim=size(rawdata{n});
                Hm(n)=mean(H(n,:));
            end
            [~,k1]=max(Hm);%component with the highest coefficient
            voxels=rawdata{k1}~=0; diffW=cell.empty(3,0);
            if k==2
                k2=3-k1; %kn=(rawdata{k1}~=0);
                diffW{c}=rawdata{k1}-rawdata{k2};
                data = diffW{c}(voxels);
            elseif k==3
                %component with the lowest coefficient as noise
                [~,k3]=min(Hm); k2=6-(k1+k3);
                diff1=rawdata{k1}-rawdata{k3};
                diff2=rawdata{k2}-rawdata{k3};
                diffW{c}=diff1-diff2;
                kn1=diff1>0; kn2=diff2>0; kn=kn1+kn2;
                data = diffW{c}(voxels); diffW{c}(kn==0)=0;
                %store data
                data3=rawdata{k3};data3 = data3(voxels);opnmf.k3{s,r}(:,c)=data3;
            end
            %store data
            data1=rawdata{k1};data1 = data1(voxels);opnmf.k1{s,r}(:,c)=data1;
            data2=rawdata{k2};data2 = data2(voxels);opnmf.k2{s,r}(:,c)=data2;
            opnmf.index{s,r}(:,c)=data;

            niftiwrite(diffW{c},fullfile(outdir,sprintf('%sdiff.nii',extractBefore(fname{1},'1.nii.gz'))),'Compressed',true);

            %categorization
            if k==2
                kn1 = data>0;kn2 = data<0;
                data(kn1)=1;data(kn2)=2;
            elseif k==3
                kn=kn(voxels);
                data(data>0)=1;data(data<0)=2;data(kn==0)=0;
            end
            opnmf.index_labels{s,r}(:,c)=data;
            opnmf.id(s,r) = {f};
        end
        %find the voxels that showed ok activity w both tasks
        labels=((opnmf.index_labels{s,r}(:,1)~=0)...
            +(opnmf.index_labels{s,r}(:,2)~=0))>1;
        opnmf.labels{s,r}=ones(size(opnmf.index_labels{s,r},1),1);
        opnmf.labels{s,r}(labels)=2;
        %correlation between eye localizer tasks
        [corr.R{s,r},corr.p{s,r},corr.lci{s,r},corr.uci{s,r}] = corrcoef(opnmf.index{s,r}(:,1),opnmf.index{s,r}(:,2), 'Rows','pairwise');
        [corr.Rs{s,r},corr.ps{s,r},corr.lcis{s,r},corr.ucis{s,r}] = corrcoef(opnmf.index{s,r}((opnmf.labels{s,r}(:,1)==2),1),opnmf.index{s,r}((opnmf.labels{s,r}(:,1)==2),2), 'Rows','pairwise');
        [corr.R1{s,r},corr.p1{s,r},corr.lci1{s,r},corr.uci1{s,r}] = corrcoef(opnmf.k1{s,r}(:,1),opnmf.k1{s,r}(:,2), 'Rows','pairwise');
        [corr.R1s{s,r},corr.p1s{s,r},corr.lci1s{s,r},corr.uci1s{s,r}] = corrcoef(opnmf.k1{s,r}((opnmf.labels{s,r}(:,1)==2),1),opnmf.k1{s,r}((opnmf.labels{s,r}(:,1)==2),2), 'Rows','pairwise');
        [corr.R2{s,r},corr.p2{s,r},corr.lci2{s,r},corr.uci2{s,r}] = corrcoef(opnmf.k2{s,r}(:,1),opnmf.k2{s,r}(:,2), 'Rows','pairwise');
        [corr.R2s{s,r},corr.p2s{s,r},corr.lci2s{s,r},corr.uci2s{s,r}] = corrcoef(opnmf.k2{s,r}((opnmf.labels{s,r}(:,1)==2),1),opnmf.k2{s,r}((opnmf.labels{s,r}(:,1)==2),2), 'Rows','pairwise');
        if k==3
            [corr.R3{s,r},corr.p3{s,r},corr.lci3{s,r},corr.uci3{s,r}] = corrcoef(opnmf.k3{s,r}(:,1),opnmf.k3{s,r}(:,2), 'Rows','pairwise');
            [corr.R3s{s,r},corr.p3s{s,r},corr.lci3s{s,r},corr.uci3s{s,r}] = corrcoef(opnmf.k3{s,r}((opnmf.labels{s,r}(:,1)==2),1),opnmf.k3{s,r}((opnmf.labels{s,r}(:,1)==2),2), 'Rows','pairwise');
        end

        %chi-squared variance test for the categories of voxels across
        %monocular and dichoptic tasks
        [chi.tbl{s,r},chi.chi2{s,r},chi.p{s,r},chi.labels{s,r}] = crosstab(opnmf.index_labels{s,r}(:,1),opnmf.index_labels{s,r}(:,2));
        %take the diff of categories of voxels, L=1,R=-1,excluded=0
        sum_labels = opnmf.index_labels{s,r}(:,1)+opnmf.index_labels{s,r}(:,2);
        %take the percentage of voxels that were identified as the same category in monocular and dichoptic (match)
        %and that were identified as the opposite category in monocular and dichoptic (mismatch) to the total number of voxels
        prcnt.match{s,r}=[(sum(sum_labels==4)/length(sum_labels)*100),...
            (sum(sum_labels==2)/length(sum_labels)*100),...
            (sum(abs(sum_labels)==0)/length(sum_labels)*100)];
    end
end
save (fullfile(outdir,'EyeIndex'),'opnmf','corr', 'chi','prcnt')