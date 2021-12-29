%% Signature code to obtain seasonal transition metrics

function [seasontrans_date, seasontrans_duration] ...
    = sig_seasontrans2(smtt, t_valley, wp, fc, plot_results)

%% Initialization

% Record the results
seasontrans_date = repelem(NaN,length(t_valley)-1,4);
%(1) dry2wet_start; (2) dry2wet_end; (3) wet2dry_start; (4) wet2dry_end;
seasontrans_duration = repelem(NaN,length(t_valley)-1,2);
%(1) dry2wet; (2) wet2dry;

trans = ["dry2wet"; "wet2dry"];

%% Main execution
% Loop for transitions
for t = 1:2
    
    % Record the parameters
    Pfit = zeros(length(t_valley)-1,6); % store parameter sets for linear piecewise eq.
    
    % Loop for water years
    for i = 1:length(t_valley)-1 %cut out at every two peaks

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
        
        % find the actual dryest & wettest point during a season using max and min
        t_min = find(seasonsmvalue == min(seasonsmvalue),1);
        t_max = find(seasonsmvalue == max(seasonsmvalue),1);
        switch trans(t)
            case "dry2wet"
                % as dryest period is short, do not use wettest point for cutting out the TS
                trans_start = seasonsm.Properties.RowTimes(t_min);
                trans_end = trans_end0;
                % Get the second start/end date with buffer
                seasonsm = smtt(timerange(trans_start-days(15), trans_end+days(30)),:);
            case "wet2dry"
                % find the actual dryest & wettest point during a season using max and min
                trans_start = seasonsm.Properties.RowTimes(t_max);
                % should be happening later than wettest point
                t_min = find(seasonsmvalue == min(seasonsmvalue(t_min:end)), 1);
                trans_end = seasonsm.Properties.RowTimes(t_min);
                % Get the second start/end date with buffer
                seasonsm = smtt(timerange(trans_start-days(30), trans_end+days(15)),:);
        end
        
        % Remove unnecessary data
        seasonsm.Properties.VariableNames = {'Var1'};
        switch trans(t)
            case "dry2wet"
                % if the VWC is smaller than the minimum VWC after the wettest point, remove the data
                if length(seasonsm.Var1) >= 30
                    seasonsm.Var1(seasonsm.Var1(end-30:end)< min(seasonsmvalue)) = NaN;
                end
            case "wet2dry"
                % if the VWC is larger than the max VWC after the dryest point, remove the data
                if length(seasonsm.Var1) >= 30
                    seasonsm.Var1(seasonsm.Var1(end-30:end)> max(seasonsmvalue)) = NaN;
                end
        end
        seasonsmvalue = table2array(seasonsm);

        
        % ======================================
        % ====   Execute the analysis   ========
        % ======================================
        
        if sum(isnan(seasonsmvalue))/size(seasonsmvalue,1) > 0.5 || isempty(seasonsmvalue) || length(seasonsmvalue) < 50
            % If there is too much NaN, or the timeseries is too short, skip the season and return NaN
            seasontrans_date(i,:) = NaN;
            seasontrans_duration(i,:) = NaN;
        else
            % If there is enough number of data, execute the analysis with Piecewise linear regression
            
            % Define the model input & parameters
            y = fillmissing(seasonsmvalue,'linear');
            x = [1:size(y,1)]';
            I = ones(size(y,1),1);
            switch trans(t)
                case "dry2wet"
                    P0 =  [0  0.001   50      30   wp  fc];
                    Plb = [-5    0        0       1    0   0];
                    Pub = [1.5    0.1        150     150  1   1];
                    % [P1    P2       P3      P4   wilting_point field_capacity]
                case "wet2dry"
                    P0 =   [0.5   -0.001  50      30   fc  wp];
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
            options = optimoptions('fmincon','Display','off'); % turn off the optimization results
            try
                Pfit(i,:) = fmincon(piecewisemodel,P0,A,b,Aeq,beq,Plb,Pub,nonlcon,options);
            catch
                Pfit(i,:) = NaN(1,6);
            end
            
            % If the wp and fc coincides, or transition is shorter than 7 days (likely to have failed), reject it.
            if (abs(Pfit(i,6) - Pfit(i,5)) < 1.0E-03) || Pfit(i,4) < 7
                
                
                Pfit(i,:) = NaN(1,6);
                
            end
            
            % Get signatures
            seasontrans_date(i,1+2*(t-1)) =  datenum(seasonsm.Properties.RowTimes(1)+ days(Pfit(i,3))); % dry2wet_startdate
            seasontrans_date(i,2+2*(t-1)) =  datenum(seasonsm.Properties.RowTimes(1)+ days(Pfit(i,3)+Pfit(i,4))); % dry2wet_enddate
            seasontrans_duration(i,t) = Pfit(i,4);
            
            
            % ======================================
            % ====   Plot the time series   ========
            % ======================================
            if plot_results
                figure;
                x250d = [1:250]';
                piecewisemode1 = @(P,x) P(1) + P(2)*x + P(2)*plusfun(P(3)-x) + (-P(2))*plusfun(x-(P(3)+P(4))) + 0*P(5) + 0*P(6);
                modelpred = piecewisemode1(Pfit(i,:),x250d);
                
                plot(x,y,'-'); hold on;
                plot(x250d,modelpred,'r-','LineWidth',2); hold on;
                if ~isnan(Pfit(i,3))
                    xline(Pfit(i,3),'r','LineWidth',1.5); xline(Pfit(i,3)+Pfit(i,4),'r','LineWidth',1.5);
                end
                xlabel('Time'); ylabel('VSWC [m^3/m^3]');
                title(sprintf('%s - %s', seasonsm.Properties.RowTimes(1), seasonsm.Properties.RowTimes(end)));
                hold off;
            end
            
        end
        
        % save to check the parameters
        writematrix(Pfit, sprintf('season_Pfit_%s.txt', trans(t)));
        
    end
    
end

% return signatures

end

