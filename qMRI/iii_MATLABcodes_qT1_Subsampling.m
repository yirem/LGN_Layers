clear all

ROIs = ['lLGN';'rLGN'];

n_map=16; %number of qT1 maps used in the average

%data from each T1 maps is stored in this file, includes the struct ss
load('qT1_subsamples.mat');

for s = 1:3 %for each subject
    for r = 1:size(ROIs,1) %for right and left LGN
        fname = sprintf('S0%d_%s_qT1', s, ROIs(r,:));
        fprintf('%s\n',fname)
        
        % random subsampling of maps
        for n=1:n_map % # of maps to be averaged
            combs=nchoosek(1:n_map,n); %all possible combinations
            %for reproducability of the random results
            sn = RandStream('philox4x32_10'); 
            
            if n==n_map % the entire sample of qT1s, one sample
                rand_subs=1; n_subs=1;
            else
                n_subs=n_map; %take 16 subsamples
                rand_subs=randsample(sn,length(combs),n_subs); %pick the combinations
            end
            for i=1:n_subs %for each subsample
                if n==1 %one map
                    fprintf('%s %d\n',fname,i)
                    data = ss.data_all{s,r}(i);  % a vector
                else %more than a map
                    fprintf('%s #ofMaps:%d Subsample:%d\n',fname,n,i)
                    %concatenate the maps
                    data_concat=double.empty(size(ss.data_all{s,r},1),0);
                    for i_map=1:n
                        data_concat(:,i_map)=ss.data_all{s,r}(:,combs(rand_subs(i),i_map));
                    end
                    %average the maps for each row (i.e., each voxel)
                    data=mean(data_concat,2);
                end
                
                %fit a Gaussian mixture model with 2 components to data
                gm = fitgmdist(data,2);
                
                [xl(1), xl(2)]=bounds(data);
                x = linspace(xl(1),xl(2),1000);
                
                % the two separate gaussians of the model
                n1 = makedist('normal',gm.mu(1),sqrt(gm.Sigma(1)));
                n2 = makedist('normal',gm.mu(2),sqrt(gm.Sigma(2)));
                
                % the components might not be in order, so choose M as the one
                % with higher qT1 
                p = gm.ComponentProportion;
                if gm.mu(1)<gm.mu(2)
                    gM=p(2); gP=p(1); nM=n2; nP=n1;
                else
                    gM=p(1); gP=p(2); nM=n1; nP=n2;
                end
                
                pM = gM * cdf(nM,x,'upper') ./ (p(1) * cdf(n1,x,'upper') + p(2) * cdf(n2,x,'upper')); % fraction of voxels to the right
                pP = gP * cdf(nP,x,'upper') ./ (p(1) * cdf(n1,x,'upper') + p(2) * cdf(n2,x,'upper'));
                
                thr = .5; % threshold
                [m, j] = min(abs(pM - thr)); % nearest point to threshold
                cutoff = x(j);
                P = data<cutoff;
                M = data>=cutoff;
                %calculate the average qT1 value for M and P
                avg_MP = [mean(data(M)); mean(data(P))];
                %calculate the proportion of M to the whole LGN
                prop = [(sum(M)/(sum(M)+sum(P))*100) (sum(P)/(sum(M)+sum(P))*100)];
                
                %store results
                ss.avg_MP{s,r}(i+16*(n-1),:) = avg_MP;
                ss.cutoff{s,r}(i+16*(n-1),1) = cutoff;
                ss.labels{s,r}(i+16*(n-1),1)=n;
                ss.prop{s,r}(i+16*(n-1),:) = prop;
            end
        end
    end
end
save('qT1_subsamples.mat', 'ss')