clear all

%load the results from the average of the 16 qT1 maps, includes variable q
load('qT1.mat')
%load the results from the subsamples of qT1 maps, includes ss
load('qT1_subsamples.mat')

ROIs = ['lLGN';'rLGN'];

for s = 1:3 %for each subject
    for r = 1:size(ROIs,1) %for right and left LGN
        %plot the results
        x=ss.labels{s,r}; %the number of maps in the subsample
        [xl(1), xl(2)] = bounds(x);
        % plot the threshold qT1 value for M/P separation and
        % plot the proportion of the number of M voxels to the
        % total number of voxels in the LGN
        % ss is the value from the subsample analyses
        % q is the value from the analysis on the average of the all 16 maps
        for i=1:2
            if i==1                
                y=ss.cutoff{s,r}; 
                ytot=q.cutoff(s,r);
                ylimit=[0.7 1.35];
                yname='Threshold in T1 Relaxation Time (s)';
                fname = sprintf('S%d_%s_qT1subs_cutoff.png',s,ROIs(r,:));
            else                
                y=ss.prop{s,r}(:,1);
                ytot=q.prop{s,r}(1,1);
                ylimit=[0 100];
                yname='Proportion of M to the LGN (% voxels)';
                fname = sprintf('S%d_%s_qT1subs_prop.png',s,ROIs(r,:));
            end
            yCI=double.empty(xl(2),0); ymean=yCI; x_cat=yCI;
            for n=xl(1):xl(2)
                if n==xl(2) %the entire sample so no CI here
                    ymean(n,1) = y(length(y));
                    yCI(n,1) = 0;
                else
                    ymean(n,1) = mean(y(x==n));
                    ySEM = std(y(x==n))/sqrt(length(y(x==n)));
                    yT = tinv([0.025  0.975],length(y(x==n))-1);
                    yCI(n,1) = yT(2)*ySEM;
                end
                x_cat(n,1) = n;
            end
            
            figure
            scatter(x,y,50); %scatterplot of subsamples
            hold on
            xticks(x_cat);
            ylim(ylimit);
            
            b=errorbar(x_cat,ymean,yCI,'-k'); %mean of the subsamples
            b.LineWidth=2;
            
            yline(ytot,'--','LineWidth',2);
            xlabel('Number of qT1 maps');
            ylabel(yname);
            
            ax = gca;
            ax.FontSize = 18;
            hold off
            saveas(gcf,fname)
        end
    end
end