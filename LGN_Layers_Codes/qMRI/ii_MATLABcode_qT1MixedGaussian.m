clear all

datadir = '~/Desktop/LGN_Layers_Codes/qMRI/data'; %for Mac
ROIs = ['lLGN';'rLGN'];
vox = 0.7^3; %size of a voxel in mm3

for s = 1:3 %for each subject
    for r = 1:size(ROIs,1) %for right and left LGN
        fname = sprintf('S%d_%s_qT1', s, ROIs(r,:));
        fprintf('%s\n',fname)
        
        data_name = sprintf('sub-0%d_qT1inT1_%s.nii.gz',s, ROIs(r,:));
        
        %load data (nifti file)
        %gunzip(fullfile(subdir,data_name)); %converts nii.gz to nii
        rawdata = niftiread(fullfile(datadir,data_name));
        
        b=find(rawdata~=0);% get the locations of nonzero
        data = rawdata(b);  % a vector
        
        %fit a Gaussian mixture model with 2 components to data
        gm = fitgmdist(data,2);
        
        %make a histogram of qT1 values of voxels
        figure
        histogram(data,40,'FaceColor',[0.7 0.7 0.7], 'Normalization','pdf');
        
        xl = xlim;
        x = linspace(xl(1),xl(2),1000);        
        hold on
        %plot(x,pdf(gm,x'),'k','LineWidth',3) % composite model
        
        %plot two separate gaussians
        n1 = makedist('normal',gm.mu(1),sqrt(gm.Sigma(1)));
        n2 = makedist('normal',gm.mu(2),sqrt(gm.Sigma(2)));
        p = gm.ComponentProportion;
        if p(1)>p(2) % the components might not be in order, so choose M as the smaller one
            gM=p(2); gP=p(1); nM=n2; nP=n1;
        else
            gM=p(1); gP=p(2); nM=n1; nP=n2;
        end
        plot(x,gP*pdf(nP,x),'Color', [0.9290 0.6940 0.3250],'LineWidth',4)
        plot(x,gM*pdf(nM,x), 'Color',[0.3010, 0.7450, 0.9330],'LineWidth',4)
        
        ylim([0 8]);
        ylabel('Voxel PDF')
        xlabel('T1 Relaxation (s)')        
        yyaxis right % plot probability of being M voxel as function of qT1 on the same axes
        ylim([0 1]);
        ylabel('Fraction of M voxels to the right')
        ax = gca;
        ax.FontSize = 15;
        
        pM = gM * cdf(nM,x,'upper') ./ (p(1) * cdf(n1,x,'upper') + p(2) * cdf(n2,x,'upper')); % fraction of voxels to the right from distribution 1
        pP = gP * cdf(nP,x,'upper') ./ (p(1) * cdf(n1,x,'upper') + p(2) * cdf(n2,x,'upper')); % fraction of voxels to the right from distribution 2
        plot(x,pM,'b-','LineWidth',2)
        thr = .5; % threshold to plot line
        [m, i] = min(abs(pM - thr)); % nearest point to threshold
        cutoff = x(i);
        
        % line at threshold
        x1 = [cutoff,xl(2)];
        y1 = [thr, thr];
        plot(x1,y1, 'Color', [0.5 0.5 0.5],'LineWidth',1)        
        xl1 = xline(cutoff,'--','M','LineWidth',2);
        xl1.LabelOrientation = 'horizontal';
        xl1.FontSize = 25;
        xl2 = xline(cutoff,'--','P','LineWidth',2);
        xl2.LabelHorizontalAlignment = 'left';
        xl2.LabelOrientation = 'horizontal';
        xl2.FontSize = 25;        
        hold off
        saveas(gcf,sprintf('%s.png',fname))
        
        %calculate the volume of LGN in mm3
        n_vox = length(data);
        q.vol_LGN(s,r) = vox*n_vox;        
        
        %calculate the proportion of M to the whole LGN
        P = data<cutoff;
        M = data>=cutoff;       
        q.prop{s,r} = [(sum(M)/(sum(M)+sum(P))*100) (sum(P)/(sum(M)+sum(P))*100)];
        
        %compare M and P qT1 maps and calculate the average qT1 value for M and P 
        q.avg_qT1_M_P{s,r} = [mean(data(M)) mean(data(P))];
        q.sd_qT1_M_P{s,r} = [std(data(M)) std(data(P))];
        [q.h(s,r),q.p(s,r),q.ci{s,r},q.stats{s,r}] = ttest2(M,P,'Vartype','unequal');        
        
        q.gm{s,r} = gm; %store the mixed Gaussian model
        q.cutoff(s,r) = cutoff; %store the threshold value, this was used to find M and P parts for each S
        q.id (s,r) = {fname}; %store the info on which cell represents what in q
     end
end
save('qT1', 'q')