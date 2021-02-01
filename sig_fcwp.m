%% Signature code to obtain field capacity (wet equilibrium value) from soil mositure time series
    % this code calculates the field capacity taking a wet season peak of the PDF of soil
    % mositure time series 

    % input
        % sm: an array of soil moisture without time information
    
    % output 
        % wp: wilting point 

function [fc, wp] = sig_fcwp(sm, smtt, plot_results)

% This algorithm searches peaks in optimally-smoothed PDF, pickes up the peak whichever smoother (BW=optimal or BW=0.01)
% I could use BW = BW*2 or something for more robust estimation. Will try later

%% Find local maxima
% Smooth out with optimal bandwidth to find the field capacity
[f2,xi2,bw2] = ksdensity(sm);
% Remove unsignificant peak (<10% of the largest peak)
[pks2,lks2] = findpeaks(ksdensity(sm),'MinPeakHeight',0.1*max(f2)); %down to 0.1

% Smooth out roughly to find the peak
[f,xi] = ksdensity(sm,'Bandwidth', bw2*2);  
% Remove unsignificant peak (<10% of the largest peak)
[pks,lks] = findpeaks(ksdensity(sm,'Bandwidth', bw2*2),'MinPeakHeight',0.1*max(f));

% (Note)findpeak() finds
    % the rank of the peak: lks, and
    % probability density: pks
% ksdensity() finds
    % the actual VWC of the peak: xi 
    % and its frequency: fi

%% Field capacity 
% Pick the rank of temporal field capacity in roughly-smoothed PDF  
tlks = max(lks);

% Search the peak in optimally-smoothed PDF around the peak in roughly-smoothed PDF
range = 3;
tf = 0;
A = [];
%loop until we get 2 field capacities / 1 field capacity when searching range gets too wide
for range = 3:100 
    minlks = tlks - range;
    maxlks = tlks + range;
    A = find(minlks <= lks2 & lks2 <= maxlks);      
    if (size(A,2) == 2)
        break 
    end
    if (size(A,2) == 1 && range > 15)
        break 
    end
end 

% Pick the larger peak when you find 2 candidate peaks
B = find( pks2 == max( pks2(A') ) );

% Define field capacity in opitimally-smoothed PDF
fc = xi2(lks2(B));
clear tlks tf A minlks maxlks B

%% Wilting point
% Pick the rank of temporal field capacity in roughly-smoothed PDF  
tlks = min(lks);

% Search the peak in optimally-smoothed PDF around the peak in
% roughly-smoothed PDF
range = 3;
tf = 0;
A = [];
%loop until we get 2 field capacities / 1 field capacity when searching range gets too wide
for range = 3:100 
    minlks = tlks - range;
    maxlks = tlks + range;
    A = find(minlks <= lks2 & lks2 <= maxlks);      
    if (size(A,2) == 2)
        break 
    end
    if (size(A,2) == 1 && range > 15)
        break 
    end
end 

% Pick the smaller peak when you find 2 candidate peaks
B = find( pks2 == max( pks2(A') ) );
% Define field capacity in opitimally-smoothed PDF
wp = xi2(lks2(B));

clear tlks tf A minlks maxlks B

%% Plot
if plot_results
% time series of SM + field capacity
    figure;
    x0=0;y0=0;width=250;height=200;set(gcf,'position',[x0,y0,width,height]);
    plot(smtt.Properties.RowTimes, sm);xtickformat('yyyy');hold on;yline(fc,'LineWidth',2);yline(wp,'LineWidth',2);
    xlabel('Year');ylabel('VWC(%)');
    hold off;
%             
% PDF of SM + field capacity
    [f2,xi2] = ksdensity(sm);
    figure;
    x0=0;y0=0;width=250;height=200;set(gcf,'position',[x0,y0,width,height]);
    plot(xi2,f2,'LineWidth',1.5); %f:density, xi:equal spacing (default = 100)
    hold on;xline(fc,'LineWidth',2);xline(wp,'LineWidth',2);
    xlabel('VWC(%)');ylabel('Frequency');
%             title(titlename);figname = sprintf ('wp_pdf_%s',titlename);saveas(gcf,figname,'fig');
    hold off;
end

end


%% =========== END OF THE CODE ============
