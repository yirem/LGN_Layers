clear all

%load the results from the average of the 16 qT1 maps, includes variable q
load('qT1.mat')
%load the results from the subsamples of qT1 maps, includes ss
load('qT1_subsamples.mat')

ROIs = ['lLGN';'rLGN'];

for s = 1:3 %for each subject
    for r = 1:size(ROIs,1) %for right and left LGN

        x=ss.labels{s,r}; %the number subsamples
        [xl(1), xl(2)] = bounds(x);

        for i = 1:x %for each subsample
            %calculate the percent match in the categorization of voxels
            %into M and P
            mismatch=abs(ss.dataP_subs{s,r}(:,i)-q.dataP{s,r}); %0 if there's a match, 1 if mismatch
            prcnt_match=sum(mismatch==0)/length(mismatch)*100;
            ss.prcnt_match{s,r}(i,1)=prcnt_match;
        end
        %plot the classification accuracy
        y=ss.prcnt_match{s,r}(:,1);
        ylimit=[0 100];

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
        %fit an exponential growth curve
        ft=fittype('a*(1-exp(-(x_cat/b)))','indep','x_cat');
        [f,gof,output]=fit(x_cat,ymean,ft,'start',[100 8]);
        %take the CIs calculated by the model for the first parameter
        a_CI=confint(f); a_CIlower=a_CI(1,1);

        %plot the results
        subplot(3,2,(s-1)*2+r)
        scatter(x,y,50); %scatterplot of subsamples
        hold on
        xticks([1 2 4 8 16]);
        xlim([1 16]);
        ylim(ylimit);

        yticks(sort([0:20:80 round(f.a,2)])) %show the asymptote on the y axis
        %put the mean of the subsamples of different sizes with the CIs
        errorbar(x_cat,ymean,yCI,'k','LineStyle','none','LineWidth',2);
        %find the y value that's closest to the asymptote's lower bound found by the model 
        [m, i] =min(abs(f(x_cat)-a_CIlower));
        %find the required number of maps on the x axis for above
        x_asymp = x_cat(i);
        %put a line for above
        x2=[x_asymp,x_asymp]; y2=[0,a_CIlower];
        plot(x2,y2, 'Color', [0.5 0.5 0.5],'LineWidth',1)
        %add a line for the asymptote with its CIs
        yline(f.a,'--');
        fill([1 16 16 1], [a_CI(1,1) a_CI(1,1) a_CI(2,1) a_CI(2,1)],'k','edgecolor', 'none','FaceAlpha',0.15);

        fc=plot(f,'-r');
        fc.LineWidth=2;        
        legend('hide');
        set(gca,'xscale','log')
        xlabel('')
        ylabel('')
        title(sprintf('S%d %s', s, ROIs{r}))
        if(r==1)
            ylabel('Consistent categorization (%)')
        end
        if(s==3)
            xlabel('Number of qT1 maps averaged')
        end
    end
end
orient tall
print('fitfigs', '-dpdf')
