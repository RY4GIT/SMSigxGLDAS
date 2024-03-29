%% Signature code to obtain seasonal transition metrics

function [seasontrans_date, seasontrans_duration] ...
    = sig_seasontrans(smtt, t_valley, P0_d2w, P0_w2d, plot_results, data_label)

%% Initialization

% Record the results
seasontrans_date = repelem(NaN,length(t_valley)-1,4);
%(1) dry2wet_start; (2) dry2wet_end; (3) wet2dry_start; (4) wet2dry_end;
seasontrans_duration = repelem(NaN,length(t_valley)-1,2);
%(1) dry2wet; (2) wet2dry;

trans = ["dry2wet"; "wet2dry"];

% Take the moving average of the data (5 days)
smtt.(string(smtt.Properties.VariableNames(1))) = movmean(smtt.(string(smtt.Properties.VariableNames(1))), 30, 'omitnan');

%% Main execution
% Loop for transitions
for t = 1:length(trans)
    
    % Record the parameters
    Pfit = zeros(length(t_valley)-1,6); % store parameter sets for linear piecewise eq.
    
    % Loop for water years
    for i = 1:length(t_valley)-1 %cut out at every two peaks

        % fprintf('%s: %d\n', trans(t), year(t_valley(i)))
        
        % ======================================
        % ====   Crop the time series   ========
        % ======================================
        
        % Get the base start/end days
        switch trans(t)
            case "dry2wet"
                trans_start0 = t_valley(i);
                trans_end0 = trans_start0 + days(365/2);
            case "wet2dry"
                trans_start0 = t_valley(i) + days(365/2);
                trans_end0 = t_valley(i+1);
        end
        
        % Crop the season with 1 month buffer
        seasonsm = smtt(timerange(trans_start0-days(30),trans_end0+days(30)),:);
        seasonsmvalue = table2array(seasonsm);
        
        if sum(isnan(seasonsmvalue))/size(seasonsmvalue,1) > 0.3 || isempty(seasonsmvalue)
            % If there is too much NaN, or the timeseries is empty, do nothing
            if sum(isnan(seasonsmvalue))/size(seasonsmvalue,1) > 0.3
                warning('data contains too much NaN')
            elseif isempty(seasonsmvalue)
                warning('timeseries was empty')
            end
        else
            % find the actual dryest & wettest point during a season
            nhalf = ceil(length(seasonsmvalue)/2);
            switch trans(t)
                case "dry2wet"
                    % The dryest point should be happening in the first half of the timeseries
                    t_min = find(seasonsmvalue(1:nhalf,:) == min(seasonsmvalue(1:nhalf,:)),1);
                    % As dryest period is short, do not use wettest point for cutting out the TS
                    trans_start = seasonsm.Properties.RowTimes(t_min);
                    trans_end = trans_end0;
                    % Get the second start/end date with buffer
                    seasonsm = smtt(timerange(trans_start-days(30), trans_end+days(30)),:);
                case "wet2dry"
                    % The wettest point should be happening in the first half of the timeseries
                    t_max = find(seasonsmvalue(1:nhalf,:) == max(seasonsmvalue(1:nhalf,:)),1);
                    % Find the actual dryest & wettest point during a season using max and min
                    trans_start = seasonsm.Properties.RowTimes(t_max);
                    % The driest point should be happening later than wettest point
                    t_min = find(seasonsmvalue(t_max:end) == min(seasonsmvalue(t_max:end)), 1);
                    trans_end = seasonsm.Properties.RowTimes(t_max+t_min-1);
                    % Get the second start/end date with buffer
                    seasonsm = smtt(timerange(trans_start-days(45), trans_end+days(15)),:);
            end

            % Remove unnecessary data
            seasonsm.Properties.VariableNames = {'Var1'};
            switch trans(t)
                case "dry2wet"
                    % if the VWC is smaller than the minimum VWC after the wettest point, remove the data
                    if length(seasonsm.Var1) >= 30
                        seasonsm.Var1(seasonsm.Var1(end-30+1:end)< min(seasonsmvalue)) = NaN;
                    end
                case "wet2dry"
                    % if the VWC is larger than the max VWC after the dryest point, remove the data
                    if length(seasonsm.Var1) >= 30
                        seasonsm.Var1(seasonsm.Var1(end-30+1:end)> max(seasonsmvalue)) = NaN;
                    end
            end
            seasonsmvalue = table2array(seasonsm);
            
        end
        
        % ======================================
        % ====   Execute the analysis   ========
        % ======================================
        
        if sum(isnan(seasonsmvalue))/size(seasonsmvalue,1) > 0.3 || isempty(seasonsmvalue) || sum(~isnan(seasonsmvalue)) < 90
            % If there is too much NaN, or the timeseries is too short, skip the season and return NaN
            seasontrans_date(i,:) = NaN;
            seasontrans_duration(i,:) = NaN;
            if sum(isnan(seasonsmvalue))/size(seasonsmvalue,1) > 0.3
                warning('data contains too much NaN')
            elseif isempty(seasonsmvalue)
                warning('timeseries was empty')
            elseif sum(~isnan(seasonsmvalue)) < 90
                warning('data was short')
            end
        else
            % If there is enough number of data, execute the analysis with Piecewise linear regression
            
            % Define the model input & parameters
            y0 = seasonsmvalue;
            y = y0(find(~any(isnan(y0),2),1,'first'):find(~any(isnan(y0),2),1,'last'),:); % truncate NaNs at the beginning and end
            x = [1:size(y,1)]';
            I = ones(size(y,1),1);
            switch trans(t)
                case "dry2wet"
                    P0 =  P0_d2w;
                    Plb = [-5    0        0       1    0   0];
                    Pub = [1.5    0.1        150     150  1   1];
                    % [P1    P2       P3      P4   wilting_point field_capacity]
                case "wet2dry"
                    P0 =   P0_w2d;
                    Plb =  [0      -0.1       0       1    0   0];
                    Pub =  [2.0   0        150     150  1   1];
                    % [P1    P2       P3      P4   wilting_point field_capacity]
            end
            
            % Minimize the least square of piecewise model
            plusfun = @(x) max(x,0);
            piecewisemodel =  @(P) sum((y - (P(1) + I.*P(2).*x + I.*P(2).*plusfun(I.*P(3) - x) + (-I.*P(2)).*plusfun(x-(I.*P(3)+I.*P(4))))).^2);
            nonlcon = @util_piecewise_constraint;
            A = [];
            b = [];
            Aeq = [];
            beq = [];
            options = optimoptions('fmincon' ,'Display','off'); % turn off the optimization results
            try
                Pfit(i,:) = fmincon(piecewisemodel,P0,A,b,Aeq,beq,Plb,Pub,nonlcon,options);
            catch
                Pfit(i,:) = NaN(1,6);
                warning('optimization failed')
            end
            
            % If the wp and fc coincides, or transition is shorter than 7 days (likely to have failed), reject it.
            if (abs(Pfit(i,6) - Pfit(i,5)) < 1.0E-03) || Pfit(i,4) < 7
                Pfit(i,:) = NaN(1,6);    
                if (abs(Pfit(i,6) - Pfit(i,5)) < 1.0E-03)
                    warning('fc and wp coincides during optimization')
                elseif Pfit(i,4) < 7
                    warning('transition was unplausibly short')
                end
            end
            
            % Get signatures
            seasontrans_date(i,1+2*(t-1)) =  datenum(seasonsm.Properties.RowTimes(1)+ days(Pfit(i,3))); % dry2wet_startdate
            seasontrans_date(i,2+2*(t-1)) =  datenum(seasonsm.Properties.RowTimes(1)+ days(Pfit(i,3)+Pfit(i,4))); % dry2wet_enddate
            seasontrans_duration(i,t) = Pfit(i,4);
            
            
        % ======================================
        % ====   Plot the time series   ========
        % ======================================
            if plot_results
                figure(i+(t-1)*length(t_valley));
                
                ax = gca; 
                ax.FontSize = 16; 
                % fontsize(gcf,16)
                x250d = [1:250]';
                piecewisemode1 = @(P,x) P(1) + P(2)*x + P(2)*plusfun(P(3)-x) + (-P(2))*plusfun(x-(P(3)+P(4))) + 0*P(5) + 0*P(6);
                modelpred = piecewisemode1(Pfit(i,:),x250d);
                
                if data_label == "gldas"
                    lcolor = [239,138,98]./255;
                    data_label_name = "GLDAS";
                else data_label == "insitu"
                    lcolor = [103,169,207]./255;
                    data_label_name = "In-situ";
                end
                
                plot(seasonsm.Properties.RowTimes(1)+days(x), y, '-', 'Color', lcolor, ...
                    'DisplayName', sprintf('%s (%3.f days)', data_label_name, seasontrans_duration(i,t))); hold on;
                plot(seasonsm.Properties.RowTimes(1)+days(x250d), modelpred, '-', 'Color', lcolor,'LineWidth',2, ...
                    'HandleVisibility','off'); hold on;
                
                if ~isnan(Pfit(i,3))
                    xline(seasonsm.Properties.RowTimes(1)+ days(Pfit(i,3)),'Color', lcolor,'LineWidth',1.5, 'LineStyle', '--', 'HandleVisibility','off');
                    xline(seasonsm.Properties.RowTimes(1)+ days(Pfit(i,3)+Pfit(i,4)),'Color', lcolor,'LineWidth', 1.5, 'LineStyle', '--', 'HandleVisibility','off');
                end
                xlabel('Time'); ylabel({'Detrended volmetric';'soil water content [m^3/m^3]'}); ylim([0.4 0.65])
                if trans(t) == "wet2dry"
                    legend('Location', 'northeast');
                elseif trans(t) == "dry2wet"
                    legend('Location', 'northwest');
                end
                
                xlim([trans_start0-days(30) trans_end0+days(30)]);
                
                % title(sprintf('%s - %s',seasonsm.Properties.RowTimes(1), seasonsm.Properties.RowTimes(end)));
                hold on;
                 
            end
            
        end
        
        % save to check the parameters
        writematrix(Pfit, sprintf('season_Pfit_%s.txt', trans(t)));
        
    end
    
end

% return signatures

end

