function [] = qc_step3p1(flag_of_interest, network, out_path) 

% preparation
[depth, nstation] = io_siteinfo(network);
stationflag = readmatrix(fullfile(out_path, network, 'stationflag1.csv'));
stationflag_of_interest = zeros(size(find(stationflag == flag_of_interest),1),4);

% plot out the flagged timeseries & prepare for manual assessment
q = 0;
for k = 1:length(depth)
    % Read soil moisture vector
    p = 0;
    
    for n = 1:nstation
        if stationflag(n,k) == flag_of_interest
            % if the data is flagged, record the depth # & station#
            p = p+1;
            q = q+1;
            stationflag_of_interest(q,1)= n;
            stationflag_of_interest(q,2)= k;
            
            % open the data
            fn = sprintf('sm_d%.3f_s%02d.csv', depth(k), n);
            sm = readtimetable(fullfile(out_path, network, fn));
            
            % get moving average
            searchrange = length(sm.sm) - 8640;
            Ma = movmean(sm.sm, 8640, 'omitnan');
            Ma(isnan(Ma)) = 0;
            ipta = findchangepts(Ma, 'MaxNumChanges', 6, 'Statistic', 'linear');
           
            % plot it out
            figure(q+1);
            plot(sm.sm, 'linewidth', 1.5,'Color',[0, 0.4470, 0.7410]); hold on;
            plot(Ma, 'DisplayName', 'Moving Average', 'linewidth', 1.5,'Color',[0.6350, 0.0780, 0.1840]); hold on;
            for nlin = 1:length(ipta)
                xline(ipta(nlin), 'DisplayName', 'Change in Moving Average','linewidth', 1.5,'Color',[0.6350, 0.0780, 0.1840]); hold on;
                text(ipta(nlin),0.9, string(ipta(nlin))); hold on;
            end
            sm_end = length(sm.sm(~isnan(sm.sm)));
            ylim([0 1]);
            xlim([1 sm_end]);
            titlename = sprintf('station%d-depth%d', n, k);
            title(titlename); 
            disp(titlename);
            hold off
            
        else
        end
        
    end
    
end

% save the station flags in csv
fn = sprintf('stationflag%d.csv', flag_of_interest);
writematrix(stationflag_of_interest, fullfile(out_path, network, fn));

end