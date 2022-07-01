clear all

datadir = '../data';

ROIs = ['lLGN';'rLGN'];

for s = 1:3 %for each subject
    subdir = fullfile(datadir,sprintf('sub-0%d/qT1', s));

    for r = 1:size(ROIs,1) %for right and left LGN
        data_name = sprintf('qT1inT1_%s.nii.gz', ROIs(r,:));

        fprintf('S%d %s\n',s,data_name)

        %load data (nifti file)
        %gunzip(fullfile(subdir,data_name)); %converts nii.gz to nii
        rawdata = niftiread(fullfile(subdir,data_name));
        b=find(rawdata~=0);% get the locations of nonzero
        data = rawdata(b);  % a vector

        options = statset('MaxIter',1000);

        %fit a Gaussian model with 1 component to data
        m.GLMModel1{s,r} = fitgmdist(data,1,'Options',options);

        %fit a Gaussian model with 2 components to data
        m.GLMModel2{s,r} = fitgmdist(data,2,'Options',options);

        m.AIC{s,r}=[m.GLMModel1{s,r}.AIC m.GLMModel2{s,r}.AIC];
        m.BIC{s,r}=[m.GLMModel1{s,r}.BIC m.GLMModel2{s,r}.BIC];

        [minAIC,m.nComponentAIC(s,r)] = min(m.AIC{s,r});
        [minBIC,m.nComponentBIC(s,r)] = min(m.BIC{s,r});

    end
end
save('qT1_AICBIC', 'm')
