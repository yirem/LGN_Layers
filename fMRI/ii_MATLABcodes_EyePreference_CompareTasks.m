clear all

% load ocular preference data (t stat for LE>RE contrast)
% this file can be created with i_MATLABcodes_EyePreference_DataPrep
% or, the one we generated can be found in the same folder with this code 
load('DATA_EyePreference_T.mat');

ROIs = ['lLGN_func'; 'rLGN_func'];

for s = 1:3 %for each subject
    mask_dir = sprintf('../data/sub-0%d/fMRI',s);
    
    for r = 1:size(ROIs,1) %for each ROI
        mask_name = sprintf('mask_%s_sigvox21.nii.gz',ROIs(r,:));
        %load the mask that separates the significant voxels from
        %others in LGN:
        %these are the voxels that showed significant ocular preference
        %(i.e., z for LE>RE contrast was beyond +1.65 or -1.65, 
        %uncorrected signifcance level) when the GLM was conducted for
        %Monocular+Dichoptic data at a higher level analysis

        %this mask had values of 1 or 2:
        %1 was to signify the LGN voxels that did not show significant
        %ocular preference
        %2 was to signify the LGN voxels that showed significant
        %ocular preference
        mask_name = niftiread(fullfile(mask_dir,mask_name));
        z=find(mask_name~=0);
        sigvox = mask_name(z);  
        
        %correlation between eyeloc and replay
        [corr.R{s,r},corr.p{s,r},corr.lci{s,r},corr.uci{s,r}] = corrcoef(d.index{s,r}(:,1),d.index{s,r}(:,2), 'Rows','pairwise');
        %for significant voxels
        [corr.Rs{s,r},corr.ps{s,r},corr.lcis{s,r},corr.ucis{s,r}] = corrcoef(d.index{s,r}((sigvox==2),1),d.index{s,r}((sigvox==2),2), 'Rows','pairwise');
       
        %make scatterplots of voxels showing their ocular preference 
        %when calculated with the either task

        %color-code the significant voxels with red
        c=zeros(2,3);
        c(2,1)=1;
        figure
        h=gscatter(d.index{s,r}(:,1),d.index{s,r}(:,2),sigvox,c,'o');
        h(1,1).Annotation.LegendInformation.IconDisplayStyle = 'off';
        h(2,1).Annotation.LegendInformation.IconDisplayStyle = 'off';
        hold on
        
        %plot the correlation
        linearCoefficients = polyfit(d.index{s,r}(:,1), d.index{s,r}(:,2), 1);
        linearCoefficients_sig = polyfit(d.index{s,r}((sigvox==2),1), d.index{s,r}((sigvox==2),2), 1);
        % The x coefficient, slope, is coefficients(1).
        % The constant, the intercept, is coefficients(2).
        % Make fit.
        xl = xlim;
        x = linspace(xl(1),xl(2),1000);
        % Get the estimated values with polyval()
        yFit = polyval(linearCoefficients, x);
        yFit_sig = polyval(linearCoefficients_sig, x);     
        plot(x, yFit, 'k-', 'MarkerSize', 15, 'LineWidth', 3);
        plot(x, yFit_sig, 'r-', 'MarkerSize', 15, 'LineWidth', 3);

        ylabel('Dichoptic Task')
        xlabel('Monocular Task')
        ax = gca;
        ax.FontSize = 18;        
        
        txt = [min(get(gca, 'xlim')); max(get(gca, 'ylim'))];
        if corr.p{s,r}(1,2)<0.05
            str=sprintf('r = %.2f*',corr.R{s,r}(1,2));            
        else
            str=sprintf('r = %.2f',corr.R{s,r}(1,2));            
        end
        if corr.ps{s,r}(1,2)<0.05
            strs=sprintf('r = %.2f*',corr.Rs{s,r}(1,2));            
        else
            strs=sprintf('r = %.2f',corr.Rs{s,r}(1,2));            
        end   
        legend({str,strs},'Location','southeast','FontSize',18)

        hold off
        saveas(gcf,sprintf('%d_EyePreference_%s.png',s,ROIs(r,:)));
        
        %chi-squared variance test for the categories of voxels across the
        %two tasks
        [chi.tbl{s,r},chi.chi2{s,r},chi.p{s,r},chi.labels{s,r}] = crosstab(d.index_labels{s,r}(:,1),d.index_labels{s,r}(:,2));
        [chi.tbls{s,r},chi.chi2s{s,r},chi.ps{s,r},chi.labelss{s,r}] = crosstab(d.index_labels{s,r}((sigvox==2),1),d.index_labels{s,r}((sigvox==2),2));
        
        % LE voxels = 1,RE voxels = -1 in the index_labels
        sum_labels = d.index_labels{s,r}(:,1)+d.index_labels{s,r}(:,2);        
        %take the percentage of voxels that were identified as the same category with the two tasks (match for RE LE and both)
        %to the total number of voxels
        prcnt.match_RL{s,r} = [(sum(sum_labels==-2)/length(sum_labels)*100) (sum(sum_labels==2)/length(sum_labels)*100) (sum(abs(sum_labels)==2)/length(sum_labels)*100)];        
    end
end
save ('RESULTS_EyePreference_T','corr', 'chi','prcnt')