%% Signature code to obtain seasonal transition metrics
% 'sig_seasontrans' estimates seasonal transition duration and date(start/end)
% both for dry-to-wet and wet-to-dry transition
% based on linear piecewise model and logistic models

% applicable only for soil moisture time series with bimodal distribution PDF (i.e. clear seasonality)

% input
% smtt: time series of soil moisture in timetable format. can only have one column of data
% e.g.    |         Time        |   Var1  |
%         |2006-01-05 00:00:00: |   0.25  |
%         |       ...           |   ...   |
% wp: wilting point (dry equilibrium value) in double format
% fc: field capacity (wet equilibrium value) in double format

% output
% seasonal trans sdate & edate: start and the end of the day of seasonal transition
% seasonal trans duration: number of days it took to complete the seasonal transition

% achronym
% dry2wet: dry to wet seasoon transition
% wet2dry: wet to dry season transition
% l: logit model
% p: piecewise linear model

% requires other function files
% util_piecewise_constraint.m
% util_piecewise_constraint2.m

% credit
% Ryoko Araki
% raraki8159@sdsu.edu
% July 15, 2020

function [WY, seasontrans_time_date, seasontrans_time_deviation, seasontrans_duration, record_squaredMiOi, record_n] ...
    = sig_seasontrans_test(smtt, ridge, wp, fc, model_choice, plot_results)

%% Preparation of time series
% aggregate into daily to remove diel signals
smtt = retime(smtt,'daily','mean');

%% Main execution. Loop for water years
%% initialization

%(1) dry2wet_start; (2) dry2wet_end; (3) wet2dry_start; (4) wet2dry_end;
seasontrans_time_date = repelem(NaN,100,4);
seasontrans_time_deviation = repelem(NaN,100,4);
seasontrans_duration = repelem(days(0),1,4);

%(1) dry2wet; (2) wet2dry;
record_squaredMiOi = repelem(NaN,100,2);
record_n = repelem(NaN,100,2);

WY = repelem(NaN,1,1);

Pfit = zeros(100,6); % store parameter sets for linear piecewise eq.
Lfit = zeros(100,4);
Pfit2 = zeros(100,6); % store parameter sets for linear piecewise eq.
Lfit2 = zeros(100,4);
i = 0;

trans = ["dry2wet"; "wet2dry"];

for nWY = 1:length(ridge) %cut out at every two peaks
    i = i+1; % display #seasonal cycle
    
    for t = 1:2
        
        % specify the dryest & wettest points from the sine curve
        switch trans(t)
            case "dry2wet"
                trans_start0 = ridge(nWY);
                trans_end0 = trans_start0 + days(365/2);
            case "wet2dry"
                trans_start0 = ridge(nWY) - days(365/2);
                trans_end0 = ridge(nWY);
        end
        
        % identify Water year
        if month(ridge(nWY)) >= 10
            WY = year(ridge(nWY)) + 1;
        else
            WY = year(ridge(nWY));
        end
        
        % crop the season
        seasonsm = smtt(timerange(trans_start0-days(30),trans_end0+days(30)),:);
        seasonsmvalue = table2array(seasonsm);
        
        % If there is too much NaN, skip the season and return NaN
        if sum(isnan(seasonsmvalue))/size(seasonsmvalue,1) > 0.2 || isempty(seasonsm)
            seasontrans_time_date(i,:) = NaN;
            seasontrans_time_deviation(i,:) = NaN;
            seasontrans_duration(i,:) = NaN;
        else
            %
            %             % find the actual dryest & wettest point during a season using max and min
            %             mpt = find(seasonsmvalue == min(seasonsmvalue),1);
            %             switch trans(t)
            %                 case "dry2wet"
            %                     % as dryest period is short, do not use wettest point for cutting out the TS
            %                     % dry2wet_end2 = seasonsmtime(seasonsmvalue == max(seasonsmvalue(dryestpoint:end)));
            %                     % dry2wet_end2 = dry2wet_end2(1);
            %                 case "wet2dry"
            %                     % find the actual dryest & wettest point during a season using max and min
            %                     wet2dry_start2 = seasonsmtime2(mpt);
            %                     % should be happening later than wettest point
            %                     wet2dry_end2 = seasonsmtime(seasonsmvalue == min(seasonsmvalue(mpt:end)));
            %                     wet2dry_end2 = wet2dry_end2(1);
            %             end
            %
            %             % specify seasonal time window
            %             % 1-month buffer from the dryest/wettest point
            %             seasonsm = smtt(timerange(trans_start-days(15),trans_emd+days(30)),:);
            
            switch trans(t)
                case "dry2wet"
                    % if the VWC is smaller than the minimum VWC after the wettest point, remove the data
                    if length(seasonsm.Var1) >= 30
                        seasonsm.Var1(seasonsm.Var1(end-30+1:end)< min(seasonsmvalue)) = NaN;
                    end
                case "wet2dry"
                    % if the VWC is larger than the max VWC after the dryest point, remove the data
                    % find(seasonsm2.Var1(end-30:end)> max(seasonsmvalue2));
                    if length(seasonsm.Var1) > 30
                        seasonsm.Var1(seasonsm.Var1(end-30:end)> max(seasonsmvalue)) = NaN;
                    end
            end
            
            % if the time series is too short, skip the time series
            %             if length(seasonsm.Var1) < 100
            %                 % return NaT
            %                 record_seasontrans_date(i,:) = NaT;
            %                 record_seasontrans_date2(i,:) = NaN;
            %                 record_seasontrans_duration(i,:) = NaN;
            %             else
            
            % ==================== Piecewise linear regression ==================== %
            % define the model
            
            
            y2 = fillmissing(seasonsmvalue,'linear'); %soil moisture data
            x2 = [1:size(y2,1)]'; % #data (daily) from the cropping point
            I = ones(size(y2,1),1);
            
            switch model_choice
                case "piecewise"
                    
                    switch trans(t)
                        case "dry2wet"
                            P0 = [0.1       0.001      50      10     wp   fc]; %[P1 P2 P3 P4 wilting_point field_capacity]
                            Plb = [0        0        0       1    0   0];
                            Pub = [1        1        150     250    1   1];
                        case "wet2dry"
                            P0 =   [0.5     -0.0001          50      10     wp   fc]; %[P1 P2 P3 P4 wilting_point field_capacity]
                            Plb =  [0.1     -1           0       1    0   0];
                            Pub =  [2.0    0            150      250    1   1];
                    end
                    
                    % Minimize the least square of piecewise model
                    plusfun = @(x2) max(x2,0);
                    piecewisemodel =  @(P) sum((y2 - (P(1) + I.*P(2).*x2 + I.*P(2).*plusfun(I.*P(3) - x2) + (-I.*P(2)).*plusfun(x2-(I.*P(3)+I.*P(4))))).^2);
                    nonlcon = @util_piecewise_constraint;
                    % No other constraints
                    A = [];
                    b = [];
                    Aeq = [];
                    beq = [];
                    options = optimoptions('fmincon','Display','off'); % turn off the optimization results
                    try
                        [Pfit(i,:), record_squaredMiOi(i,1)] = fmincon(piecewisemodel,P0,A,b,Aeq,beq,Plb,Pub,nonlcon,options);
                        record_n(i,1) = length(x2);
                    catch
                        Pfit(i,:) = NaN(1,6);
                    end
                    
                    % if the parameters reached to upper boundary or lower boundary,
                    % reject it because the fitting has likely to have failed
                    % case 1: the slope maxed out
                    % case 2: the x shift reached to upper boundary
                    % case 3: transition duration reached to lower boundary
                    if Pfit(i,1) > Pub(1) - 0.01 || ...
                            (Pfit(i,3) > Pub(3)-0.01) || ...
                            (Pfit(i,4) < Plb(4)+0.01*(Pub(4)-Plb(4))) || ...
                            (Pfit(i,4) > Pub(4)-0.01*(Pub(4)-Plb(4))) || ...
                            (abs(Pfit(i,6) - Pfit(i,5)) < 1.0E-04)
                        Pfit(i,:) = NaN(1,6);
                    end
                    
                    % ==Get signature for piecewise model== %
                    % get the seasonal transition date
                    seasontrans_time_date(i,1+2*(t-1)) =  datenum(trans_start0-days(30)+ days(Pfit(i,3))); % dry2wet_startdate
                    seasontrans_time_date(i,2+2*(t-1)) =  datenum(trans_end0-days(30)+ days(Pfit(i,3)+Pfit(i,4))); % dry2wet_enddate
                    
                    seasontrans_time_deviation(i,1+2*(t-1)) =  seasontrans_time_date(i,1) - datenum(trans_start0); % dry2wet_startdate
                    seasontrans_time_deviation(i,2+2*(t-1)) =  seasontrans_time_date(i,2) - datenum(trans_end0); % dry2wet_enddate
                    % get the seasonal transition duration
                    seasontrans_duration(i,t) = days(Pfit(i,4)); % dry2wet_duration
                    % record all / take an average?
                    
                    if plot_results
                        % piecewise
                        figure;
                        x250d = [1:250]';
                        piecewisemode1 = @(P,x2) P(1) + P(2)*x2 + P(2)*plusfun(P(3)-x2) + (-P(2))*plusfun(x2-(P(3)+P(4))) + 0*P(5) + 0*P(6);
                        modelpred = piecewisemode1(Pfit(i,:),x250d);
                         
                        plot(x2,y2,'-');
                        hold on; plot(x250d,modelpred,'r-','LineWidth',2);
                        if ~isnan(Pfit(i,3))
                            hold on; xline(Pfit(i,3),'r','LineWidth',1.5); xline(Pfit(i,3)+Pfit(i,4),'r','LineWidth',1.5);
                        end
                        xlabel('Time'); ylabel('VSWC [m^3/m^3]'); title('Piecewise linear model');
                        hold off;
                    end
                case "logit"
                    
                    % ==================== Logit model ==================== %
                    switch trans
                        case "dry2wet"
                            L0 =  [wp  fc-wp     1E-1    50]; %[y-shift amplitude k_steepness x-shift]
                            Llb = [0  0.01       0       0];
                            Lub = [1  1     20       120];
                        case "wet2dry"
                            L0 =  [wp  fc-wp     -0.1  50]; %[y-shift amplitude k_steepness x-shift wilting_point field_capacity]
                            Llb = [0  0.01    -20      0];
                            Lub = [1.5  1.5     0       200];
                    end
                    
                    % Not constrained
                    logit = @(L,x2) L(1) + L(2)./( 1 + exp(1).^(-L(3).*(x2-L(4))) );
                    options = optimoptions('lsqcurvefit','Display','off'); % turn off the optimization results
                    try
                        [Lfit(i,:),record_squaredMiOi(i,2)] = lsqcurvefit(logit, L0 , x2, y2, Llb, Lub, options);
                        record_n(i,2) = length(x2);
                    catch
                        Lfit(i,:) = NaN(1,4);
                    end
                    
                    % if the parameters reached to upper boundary or lower boundary,
                    % reject it because the fitting has likely to have failed
                    % case 1: steepness got to be zero
                    if (Lfit(i,3) == 0) ||  ...
                            ( Lfit2(i,4)> Lub(4)+0.01*(Lub(4)-Llb(4))) || ...
                            ( Lfit2(i,4)> Lub(4)-0.01*(Lub(4)-Llb(4)))
                        Lfit(i,:) = NaN(1,4);
                    end
                    
                    % ==Get signature for logit model == %
                    % get the seasonal transition date
                    percent005 = find(logitpred >= Lfit(i,1)+0.05*Lfit(i,2));
                    if isempty(percent005) == 0
                        seasontrans_time_date(i,1+2*(t-1)) = datenum(trans_start0-days(30)+ days(x250d(percent005(1))));
                    else
                        seasontrans_time_date(i,1+2*(t-1)) = NaN;
                    end
                    percent095 = find(logitpred >= Lfit(i,1)+0.95*Lfit(i,2));
                    
                    % get the seasonal transition duration
                    if isempty(percent095) == 0 && isempty(percent005) == 0
                        seasontrans_time_date(i,2+2*(t-1)) = datenum(trans_end0-days(30)+ days(x250d(percent095(1))));
                        seasontrans_duration(i,t) = days(percent095(1) - percent005(1));
                    else
                        percent005 = [];
                        seasontrans_time_date(i,1+2*(t-1)) = NaT;
                        seasontrans_time_date(i,2+2*(t-1)) = NaT;
                        seasontrans_duration(i,t) = NaN;
                    end
                    
                    seasontrans_time_deviation(i,1+2*(t-1)) =  days(seasontrans_time_date(i,1+2*(t-1)) - trans_start0); % dry2wet_startdate
                    seasontrans_time_deviation(i,2+2*(t-1)) =  days(seasontrans_time_date(i,2+2*(t-1)) - trans_end0); % dry2wet_enddate
                    
                    % plot of both functions
                    if plot_results
                        %logit
                        figure;
                        
                        x250d = [1:250]';
                        logitpred = logit(Lfit(i,:),x250d);
                    
                        plot(x2,y2,'-');
                        hold on; plot(x250d,logitpred,'b-','DisplayName','logit','LineWidth',2);
                        if isempty(percent005) == 0
                            xline(percent005(1),'b','LineWidth',1.5)
                        end
                        if isempty(percent095) == 0
                            xline(percent095(1),'b','LineWidth',1.5)
                        end
                        xlabel('Time'); ylabel('VSWC [m^3/m^3]'); title('Logistic model');
                        hold off;
                    end
                    
            end
            
        end
        
    end
    
    WY(i:i+size(seasontrans_time_date,1)) = WY;
    
end

%% return signatures
% 0days --> NaN
seasontrans_duration(seasontrans_duration == days(0)) = days(NaN);

record_len = size(seasontrans_time_date,1);
record_squaredMiOi(record_len+1:end, :) = [];
record_n(record_len+1:end, :) = [];

% save to check the parameters
writematrix(Pfit, 'season_Pfit.txt');
writematrix(Pfit2, 'season_Pfit2.txt');
writematrix(Lfit, 'season_Lfit.txt');
writematrix(Lfit2, 'season_Lfit2.txt');

end

