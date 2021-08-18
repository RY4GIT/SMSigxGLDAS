%% To Clean Oznet Field data 
% This code need to be run by a section
% Sections are divided by double % and numbers
% This code is mofidied upon clean_HB_F.m

% Ryoko Araki, 4 June 2020

%% =========== BEGINNING OF THE CODE ============
%% Set the current path
    cd("G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\SignatureAnalysis\3_codes_data_cleaners");
    out_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\SignatureAnalysis\4_data_after_qc";
    
%% Manual inputs
    site = "OZ";
    obs = "F";  
    % Load the data
    wsname = sprintf('%s_%s.mat', site, obs);
    load(wsname);
    % workspace includ data, station data, nstation, depth, fillvalue
        
%% 1) replace erroneous data with NaN, take NaN stats, and interpolate short NaN sequence
    for k =1:size(depth,2)
    % Read soil moisture vector
        depthfield = sprintf('depth%dcm', depth(k));
        disp(depthfield)
        data.(depthfield).qc = zeros(dim,nstation);
        
        for n = 1:nstation
            disp(n)
            varname = sprintf('Var%d',n);
            sm = data.(depthfield).sm(:,n);

        %% VWC Above 100
        F = find( logical((sm.(varname)) >= 1)==1 );
        data.(depthfield).sm.(varname)(F) = NaN;

        %% VWC below 0
        F = find( logical((sm.(varname)) < 0)==1 );
        data.(depthfield).sm.(varname)(F) = NaN;
        
% to TEST and check the error treatment  
% plot(sm.Var1)
% hold on
% plot(data.(depthfield).sm.(varname))

        %% 10% VWC drop within one hour
        E = diff(sm.(varname));
        E = vertcat([0],E);
        G = find( (logical(E <= -0.10)) == 1);
        data.(depthfield).sm.(varname)(G) = NaN;
        
        %% 20% VWC up within one hour
        H = find( (logical(E >= 0.20)) == 1);
        data.(depthfield).sm.(varname)(H) = NaN;
        
%         %% Flat more than 30 days
%                     %Example  % xxxxxFFFFFFxxx      % xxxxxFFFFFFNNN
%                     %E        %  6345100000134      %  6345100000NNN
%         J = logical(E == 0);  % 00000011111000      % 00000011111000
%         K = abs(diff(J));     %  0000010000100      %  0000010000100
%         K = vertcat([0],K);   % 00000010000100      % 00000010000100
%         M = find(K==1);       %       7    12       %       7    12  
%         
%         % if the data starts/ends as flat, the row does not appear in L, so add it
%         if J(end) == 1;M = vertcat(M,dim);end
%         if J(1) == 1;M = vertcat([1],M);end
%         
%         % detect long flat sequence
%         Modd = M(1:2:end);Meven = M(2:2:end);  % specify the row# of starts/ends of the flat sequence
%         flatstat = abs(Meven - Modd); % Calculate length of flat sequence
%         p = find(flatstat >= 24*30); % Detect flat sequence > 30days 
%         % 30 days is determined empirically ... when sm is low, the time seires 
%         % tend to actually show flat line more than 10 days
% 
%         % replace long flat sequence with NaN 
%         for q = 1:size(p,1)
%          if   isempty(Modd) || isempty(Meven)
%              break
%          else
%             data.(depthfield).sm.(varname)(Modd(p(q)):Meven(p(q))) = NaN; % modify the original data
%             sm.(varname)(Modd(p(q)):Meven(p(q))) = NaN; % modify the current temporal sequence
%          end
%         end
        end
    end

%% 2) clean the fragmented data 
    for k = 1:size(depth,2)
    %% Read soil moisture vector
        depthfield = sprintf('depth%dcm', depth(k));
        disp(depthfield);
        
       for n = 1:nstation
            disp(n)
            varname = sprintf('Var%d',n);
            sm = data.(depthfield).sm(:,n);
            dim = size(sm,1);
           
        % Removal of fragmented time series
        % detect NaN and make the statistics
                          %Example  % xxxxxNNNxxxNNxxx 
        A = isnan(sm.(varname));    % 0000011100011000
        B = abs(diff(A));           %  000010010010100
        B = vertcat([0],B);         % 0000010010010100 
        D = find(B==1);             %      6,9  12,14

        % if the data starts/ends as not-NaN data, the row does not appear in D, so add it   
        if (isnan(sm.(varname)(1)))~= 1; D = vertcat([1],D); end
        if (isnan(sm.(varname)(end)))~= 1; D = vertcat(D, dim); end
        
        Dodd = D(1:2:end);          %   1,9,14
        Deven = D(2:2:end);         %   6,12
        ndatastat = Deven - Dodd; %non-NaN data length
        
    %% make quality flag depending on the data length
        flag6 = logical(ndatastat <= 3)*6; % less than 3 hrs
        flag7 = logical(3 < ndatastat & ndatastat <= 24*5)*7; % 3h < ndata < 5d
        flag8 = logical(24*5 < ndatastat & ndatastat <= 24*30)*8; % 5d < ndata < 30d
        flag9 = logical(24*30 < ndatastat)*9; % ndata > 30d
   
    % check quality flag is empty of not 
        if isempty(flag6)== 1;flag6 = zeros(dim,1);end
        if isempty(flag7)== 1;flag7 = zeros(dim,1);end
        if isempty(flag8)== 1;flag8 = zeros(dim,1);end
        if isempty(flag9)== 1;flag9 = zeros(dim,1);end   
        
    % put the quality flag on sm data
    % determined empirically
        flag_data = flag6 + flag7 + flag8 + flag9;
        
    % if data exist, apply the quality flag to corresponding data sequence
        if isempty(Dodd) == 0 && isempty(Deven) == 0
        for p = 1:size(flag_data,1)
         data.(depthfield).qc(Dodd(p):Deven(p)-1,n) = flag_data(p);
        end
    % if there is no data, just put zero matrix as quality flag
        else
         data.(depthfield).qc(:,n) = flag_data;
        end
        
    % replace soil moisture data to NaN when the data less than 5 days    
        E = find(data.(depthfield).qc(:,n)==6|data.(depthfield).qc(:,n)==7);
        if isempty(E) == 0 
            data.(depthfield).sm.(varname)(E,:) = NaN;
        end 
       end
    end

%% 2.5) Open GUI and classify the stations based on the data quality
    % save the TS to matlab file
    savefile = sprintf('%s_%s_cleaned.mat', site, obs);
    save(savefile, 'data','stationdata','depth','nstation','fillvalue','dim','stationlist','site','obs','-v7.3');

    % implement 'judgeTS.mlapp' to categorize stations
    % plot and check the categorization by publishing 'plot_TX_F_categorized.m'
    % modify the variable 'stationflag' and save
    save('HB_F_stationflag.mat', 'stationflag')
    
%% 3) plot and treat erroneous stations
    % load workspace
    wsname = sprintf('%s_%s_cleaned.mat', site, obs);
    load(fullfile(out_path,wsname));  
    wsname = sprintf('%s_%s_stationflag.mat', site, obs);
    load(wsname);
    
%% Remove initial errors (flag102)

% 102-1. create stationflag 102 and automatic detection of abrupt change
    stationflag102 = zeros(size(find(stationflag == 102),1),4);
    q = 0;
    for k = 1:size(depth,2)
    % Read soil moisture vector
        depthfield = sprintf('depth%dcm', depth(k));
        disp(depthfield);
        searchrange = dim - 8640; %dim - window? 
        figure;
        p=0;
        for n = 1:nstation
           if stationflag(n,k)== 102
            p = p+1;q = q+1;
            stationflag102(q,1)= n;stationflag102(q,2)= k;
            
            varname = sprintf('Var%d',n);
            sm = data.(depthfield).sm(:,n).(varname);
            sm = flip(sm(1:searchrange,1));

            % Moving average
            Ma = movmean(sm,8640,'omitnan');
            Maisnan = find(isnan(Ma));
            Ma(Maisnan)=[];
            ipta = findchangepts(Ma,'MaxNumChanges',2,'Statistic','linear');

            subplot(5,6,p)
            plot(Ma, 'DisplayName', 'Moving Average', 'linewidth', 1.5,'Color','#A2142F');hold on;
            plot(sm, 'linewidth', 1.5,'Color','#0076a8');hold on;
            xline(ipta(1,1), 'DisplayName', 'Change in Moving Average','linewidth', 1.5,'Color','#A2142F');
            if size(ipta,1)>=2
                xline(ipta(2,1), 'DisplayName', 'Change in Moving Average','linewidth', 1.5,'Color','#A2142F');
            end
            titlename = sprintf('station%d-depth%d', n, k);title(titlename);
            hold off
           else
           end
       end
    end
    
    % 102-2. eye roll the plots and identify the row# where you wanna clear out the time series 
    % write the row# down to the variable "stationflag102"
    % then run the below clearning code
       for k = 1:size(depth,2)
    % Read soil moisture vector
        depthfield = sprintf('depth%dcm', depth(k));
        disp(depthfield);
        searchrange = dim - 8640;
        figure;
        p=0;
        
        for n = 1:nstation
           if stationflag(n,k)== 102
            p = p+1;
            q = q+1;
            
            varname = sprintf('Var%d',n);
            sm = data.(depthfield).sm(:,n).(varname);
            sm = flip(sm(1:searchrange,1));

            % Moving average
            Ma = movmean(sm,8640,'omitnan');
            Maisnan = find(isnan(Ma));
            Ma(Maisnan)=[];
            ipta = findchangepts(Ma,'MaxNumChanges',2,'Statistic','linear');
            cutfromhere = ipta(stationflag102(q,3));
            sm(cutfromhere:end) = NaN; % replace rows later than 'cutfrom here' with 'NaN'
            data.(depthfield).sm(:,n).(varname)(1:searchrange) = flip(sm);
           else
           end
       end
       end 
    
       % 102-3. plot the entire TS for confirmation
    for q = 1:size(stationflag102,1)
    % Read soil moisture vector
        i = stationflag102(q,2);depthfield = sprintf('depth%dcm', depth(i));
        k = stationflag102(q,1);varname = sprintf('Var%d',k);
        figure;
        sm = data.(depthfield).sm(:,k).(varname);
        plot(sm, 'linewidth', 1.5,'Color','#0076a8')
        titlename = sprintf('station%d-depth%d', k, i);title(titlename);
    end
         save('HB_F_stationflag.mat', 'stationflag', 'stationflag102');
         
%102-4. remove remaining errors, manually specifying the errors in the the variable "stationflag102"
for q = 1:size(stationflag102,1)
        i = stationflag102(q,2);depthfield = sprintf('depth%dcm', depth(i));
        k = stationflag102(q,1);varname = sprintf('Var%d',k);
        if stationflag102(q,5)~=0 
        data.(depthfield).sm(:,k).(varname)(stationflag102(q,5):stationflag102(q,6)) = NaN;
        figure;
        plot(data.(depthfield).sm(:,k).(varname));
        titlename = sprintf('station%d-depth%d', k, i);title(titlename);
        end
end
 save('OZ_F_stationflag.mat', 'stationflag', 'stationflag102');
 savefile = sprintf('%s_%s.mat', site, obs); 
 save(savefile, 'data','stationdata','depth','stationlist','nstation','fillvalue','dim','site','obs','-v7.3');    
    
    %% Remove later errors (flag103)
% 103-1. automatic detection of abrupt change
    stationflag103 = zeros(size(find(stationflag == 103),1),4);
    q = 0;
    
    for k = 1:size(depth,2)
    % Read soil moisture vector
        depthfield = sprintf('depth%dcm', depth(k));
        disp(depthfield);
        searchrange = dim - 8640;
%         figure;
        p=0;
        for n = 1:nstation
           if stationflag(n,k)== 103
            p = p+1;
            q = q+1;
            stationflag103(q,1)= n;
            stationflag103(q,2)= k;
            
            varname = sprintf('Var%d',n);
            sm = data.(depthfield).sm(:,n).(varname);
            sm = sm(end-searchrange:end,1);

%             % Moving average
%             Ma = movmean(sm,8640,'omitnan');
%             Maisnan = find(isnan(Ma));
%             Ma(Maisnan)=[];
%             ipta = findchangepts(Ma,'MaxNumChanges',2,'Statistic','linear');
% 
%             subplot(4,5,p)
%             plot(Ma, 'DisplayName', 'Moving Average', 'linewidth', 1.5,'Color','#A2142F')
%             hold on
%             plot(sm, 'linewidth', 1.5,'Color','#0076a8')
%             hold on
%             xline(ipta(1,1), 'DisplayName', 'Change in Moving Average','linewidth', 1.5,'Color','#A2142F');
%             if size(ipta,1)>=2
%                 xline(ipta(2,1), 'DisplayName', 'Change in Moving Average','linewidth', 1.5,'Color','#A2142F');
%             end
%             titlename = sprintf('station%d-depth%d', n, k);
%             title(titlename);
%             hold off
            
           else
           end
       end
    end
    
    % 103-2. eye roll the plots and identify the #xline where you wanna clear out the time series 
    % manually type in the #xline into the stationflag103(:,3)
    % then run the below clearning code
    q=0;
       for k = 1:size(depth,2)
    % Read soil moisture vector
        depthfield = sprintf('depth%dcm', depth(k));
        disp(depthfield);
        searchrange = dim - 8640;
        p=0;
        
        for n = 1:nstation
           if stationflag(n,k)== 103
            p = p+1;
            q = q+1;
            
            varname = sprintf('Var%d',n);
            sm = data.(depthfield).sm(:,n).(varname)(end-searchrange:end,1);

            % Moving average
            Ma = movmean(sm,8640,'omitnan');
            Maisnan = find(isnan(Ma));
            Ma(Maisnan)=[];
            ipta = findchangepts(Ma,'MaxNumChanges',2,'Statistic','linear');
            cutfromhere = ipta(stationflag103(q,3));
            sm(cutfromhere:end) = NaN; % replace rows later than 'cutfrom here' with 'NaN'
            data.(depthfield).sm(:,n).(varname)(end-searchrange:end) = sm;
           else
           end
       end
       end 

% 103-3. plot the entire TS for confirmation
    for q = 1:size(stationflag103,1)
    % Read soil moisture vector
        i = stationflag103(q,2);depthfield = sprintf('depth%dcm', depth(i));
        k = stationflag103(q,1);varname = sprintf('Var%d',k);
        figure;
        sm = data.(depthfield).sm(:,k).(varname);
        plot(sm, 'linewidth', 1.5,'Color','#0076a8')
        titlename = sprintf('station%d-depth%d', k, i);title(titlename);
    end
 save('OZ_F_stationflag.mat', 'stationflag', 'stationflag102', 'stationflag103');
 save(savefile, 'data','stationdata','depth','stationlist','nstation','fillvalue','dim','site','obs','-v7.3');    
              
%103-4. remove remaining errors, manually specifying the errors in the the variable "stationflag102"
for q = 123:size(stationflag103,1)
        i = stationflag103(q,2);depthfield = sprintf('depth%dcm', depth(i));
        k = stationflag103(q,1);varname = sprintf('Var%d',k);
        if stationflag103(q,5)~=0 
        data.(depthfield).sm(:,k).(varname)(stationflag103(q,5):stationflag103(q,6)) = NaN;
        figure;
        plot(data.(depthfield).sm(:,k).(varname));
        titlename = sprintf('station%d-depth%d', k, i);title(titlename);
        end
end
  

%% Remove first & later errors (flag104)
% 104-1. automatic detection of abrupt change
    stationflag104 = zeros(size(find(stationflag == 104),1),4);
    q = 0;
    
    for k = 1:size(depth,2)
    % Read soil moisture vector
        depthfield = sprintf('depth%dcm', depth(k));
        disp(depthfield);
%         figure;
        p=0;
        
        for n = 1:nstation
           if stationflag(n,k)== 104
            p = p+1;
            q = q+1;
            stationflag104(q,1)= n;
            stationflag104(q,2)= k;
            
%             varname = sprintf('Var%d',n);
%             sm = data.(depthfield).sm(:,n).(varname);
% 
%             % Moving average
%             Ma = movmean(sm,8640,'omitnan');
%             Maisnan = find(isnan(Ma));
%             Ma(Maisnan)=[];
%             ipta = findchangepts(Ma,'MaxNumChanges',2,'Statistic','linear');
% 
%             subplot(4,5,p)
%             plot(Ma, 'DisplayName', 'Moving Average', 'linewidth', 1.5,'Color','#A2142F')
%             hold on
%             plot(sm, 'linewidth', 1.5,'Color','#0076a8')
%             hold on
%             xline(ipta(1,1), 'DisplayName', 'Change in Moving Average','linewidth', 1.5,'Color','#A2142F');
%             if size(ipta,1)>=2
%                 xline(ipta(2,1), 'DisplayName', 'Change in Moving Average','linewidth', 1.5,'Color','#A2142F');
%             end
%             titlename = sprintf('station%d-depth%d', n, k);
%             title(titlename);
%             hold off
            
           else
           end
       end
    end
    
        % 104-2. eye roll the plots and identify the #xline where you wanna clear out the time series 
    for q = 1:size(stationflag104,1)
        depthfield = sprintf('depth%dcm', depth(stationflag104(q,2)));
        disp(depthfield);
        varname = sprintf('Var%d',stationflag104(q,1));
        sm = data.(depthfield).sm(:,stationflag104(q,1)).(varname);

           if stationflag104(q,3)==0
            % Moving average
            Ma = movmean(sm,8640,'omitnan');
            Maisnan = find(isnan(Ma));
            Ma(Maisnan)=[];
            ipta = findchangepts(Ma,'MaxNumChanges',2,'Statistic','linear');
            sm(1:ipta(1)) = NaN; % replace rows later than 'cutfrom here' with 'NaN'
            sm(ipta(2):end) = NaN; 
             data.(depthfield).sm(:,stationflag104(q,1)).(varname)= sm;
           elseif stationflag104(q,3)==1
             data.(depthfield).sm(:,stationflag104(q,1)).(varname)(stationflag104(q,5):stationflag104(q,6)) = NaN;
           end
           figure;
           plot(data.(depthfield).sm.(varname))
           titlename = sprintf('station%d-depth%d',stationflag104(q,1),stationflag104(q,2));
        title(titlename);
    end
    
    % 104-3. plot the entire TS for confirmation
    for q = 1:size(stationflag104,1)
    % Read soil moisture vector
        i = stationflag104(q,2);depthfield = sprintf('depth%dcm', depth(i));
        k = stationflag104(q,1);varname = sprintf('Var%d',k);
        figure;
        sm = data.(depthfield).sm(:,k).(varname);
        plot(sm, 'linewidth', 1.5,'Color','#0076a8')
        titlename = sprintf('station%d-depth%d', k, i);title(titlename);
    end
 save('OZ_F_stationflag.mat', 'stationflag', 'stationflag102', 'stationflag103',  'stationflag104');
 save(savefile, 'data','stationdata','depth','stationlist','nstation','fillvalue','dim','site','obs','-v7.3');   
 
%104-4. remove remaining errors, manually specifying the errors in the the variable "stationflag102"
for q = 16:23 %1:size(stationflag104,1)
        i = stationflag104(q,2);depthfield = sprintf('depth%dcm', depth(i));
        k = stationflag104(q,1);varname = sprintf('Var%d',k);
        if stationflag104(q,5)~=0 
        data.(depthfield).sm(:,k).(varname)(stationflag104(q,5):stationflag104(q,6)) = NaN;
        figure;
        plot(data.(depthfield).sm(:,k).(varname));
        titlename = sprintf('station%d-depth%d', k, i);title(titlename);
        end
end
close all;  
%% Remove middle errors (flag105)
    stationflag105 = zeros(size(find(stationflag == 105),1),4);
    q = 0;
%    105-1. Plot the TS
    for k = 1:size(depth,2)
    % Read soil moisture vector
        depthfield = sprintf('depth%dcm', depth(k));
%         figure;
        p=0;
        for n = 1:nstation
           if stationflag(n,k)== 105
            p = p+1;
            q = q+1;
            stationflag105(q,1)= n;
            stationflag105(q,2)= k;
            
            varname = sprintf('Var%d',n);
            sm = data.(depthfield).sm(:,n).(varname);
% 
%             subplot(3,4,p)
%             plot(sm, 'linewidth', 1.5,'Color','#0076a8')
%             titlename = sprintf('station%d-depth%d', n, k);
%             title(titlename);      
           else
           end
       end
    end
    
     % 105-3. plot the entire TS for confirmation
    for q = 1:size(stationflag105,1)
    % Read soil moisture vector
        i = stationflag105(q,2);depthfield = sprintf('depth%dcm', depth(i));
        k = stationflag105(q,1);varname = sprintf('Var%d',k);
        figure;
        sm = data.(depthfield).sm(:,k).(varname);
        plot(sm, 'linewidth', 1.5,'Color','#0076a8')
        titlename = sprintf('station%d-depth%d', k, i);title(titlename);
    end
 save('OZ_F_stationflag.mat', 'stationflag', 'stationflag102', 'stationflag103','stationflag104', ...
     'stationflag105');
save(savefile, 'data','stationdata','depth','stationlist','nstation','fillvalue','dim','site','obs','-v7.3');   
             
%105-4. remove remaining errors, manually specifying the errors in the the variable "stationflag102"
for q = 59:64 %1:size(stationflag105,1)
        i = stationflag105(q,2);depthfield = sprintf('depth%dcm', depth(i));
        k = stationflag105(q,1);varname = sprintf('Var%d',k);
        if stationflag105(q,5)~=0 
        data.(depthfield).sm(:,k).(varname)(stationflag105(q,5):stationflag105(q,6)) = NaN;
        figure;
        plot(data.(depthfield).sm(:,k).(varname));
        titlename = sprintf('station%d-depth%d', k, i);title(titlename);
        end
end
  close all;
  

 %% Remove convex / concave data (flag 106)
     stationflag107 = zeros(size(find(stationflag == 107),1),6);
    q = 0;
%    107-1. Plot the TS
    for k = 1:size(depth,2)
        depthfield = sprintf('depth%dcm', depth(k));
        p=0;
        for n = 1:nstation
           if stationflag(n,k)== 107
            p = p+1;q = q+1;
            stationflag107(q,1)= n;stationflag107(q,2)= k;    
           else
           end
       end
    end
       % 107-1. plot the entire TS for confirmation
    for q = 1:size(stationflag107,1)
    % Read soil moisture vector
        i = stationflag107(q,2);depthfield = sprintf('depth%dcm', depth(i));
        k = stationflag107(q,1);varname = sprintf('Var%d',k);
        figure;
        sm = data.(depthfield).sm(:,k).(varname);
        plot(sm, 'linewidth', 1.5,'Color','#0076a8')
        titlename = sprintf('station%d-depth%d', k, i);title(titlename);
    end
 save('OZ_F_stationflag.mat', 'stationflag', 'stationflag102', 'stationflag103','stationflag104', ...
     'stationflag105','stationflag107');
save(savefile, 'data','stationdata','depth','stationlist','nstation','fillvalue','dim','site','obs','-v7.3');   
  %107-4. remove remaining errors, manually specifying the errors in the the variable "stationflag102"
for q = 1:size(stationflag107,1)
        i = stationflag107(q,2);depthfield = sprintf('depth%dcm', depth(i));
        k = stationflag107(q,1);varname = sprintf('Var%d',k);
        if stationflag107(q,5)~=0 
        data.(depthfield).sm(:,k).(varname)(stationflag107(q,5):stationflag107(q,6)) = NaN;
        figure;
        plot(data.(depthfield).sm(:,k).(varname));
        titlename = sprintf('station%d-depth%d', k, i);title(titlename);
        end
end
  close all;

%% Clean the setting period for all stations
    for k = 1:size(depth,2)
    % Read soil moisture vector
        depthfield = sprintf('depth%dcm', depth(k));
        for n = 1:nstation
            varname = sprintf('Var%d',n);
            data.(depthfield).sm(:,n).(varname)(1:1831) = NaN;
        end
    end

%% Clean the setting period for all stations
    for k = 1:size(depth,2)
    % Read soil moisture vector
        depthfield = sprintf('depth%dcm', depth(k));
        for n = 1:nstation
            varname = sprintf('Var%d',n);
            data.(depthfield).sm(:,n).(varname)(1:1831) = NaN;
        end
    end


% %% Manual cleaning 
% % publish using 'plot_HB_F_caterorized.m' and check remaining errors
% % manually specify the row # in stationflag manual and clean 
% for q = 1:size(stationflagmanual,1)
%         i = stationflagmanual(q,2);depthfield = sprintf('depth%dcm', depth(i));
%         k = stationflagmanual(q,1);varname = sprintf('Var%d',k);
%         if stationflagmanual(q,5)~=0 
%         data.(depthfield).sm(:,k).(varname)(stationflagmanual(q,5):stationflagmanual(q,6)) = NaN;
%         figure;
%         plot(data.(depthfield).sm(:,k).(varname));
%         titlename = sprintf('station%d-depth%d', k, i);title(titlename);
%         end
% end
  save('OZ_F_stationflag.mat', 'stationflag', 'stationflag102', 'stationflag103','stationflag104', ...
     'stationflag105');
  savefile = sprintf('%s_%s_cleaned.mat', site, obs);
  save(savefile, 'data','stationdata','depth','nstation','fillvalue','dim','-v7.3');

%% 5) % check whether the cleaned data show trend (flag 106) or not (flag 100)?  
% open judge_TS2.mlapp and run it 

%% Remove the all data (flag101)
   stationflag101 = zeros(size(find(stationflag == 101),1),2);
    q = 0;
for k = 1:size(depth,2)
    % Read soil moisture vector
        p=0;
        for n = 1:nstation
           if stationflag(n,k)== 101 || stationflag(n,k) == 108
            p = p+1;q = q+1;
            stationflag101(q,1)= n;stationflag101(q,2)= k;
           else
           end
       end
    end
for q = 1:size(stationflag101,1)
        i = stationflag101(q,2);depthfield = sprintf('depth%dcm', depth(i));
        k = stationflag101(q,1);varname = sprintf('Var%d',k);
        data.(depthfield).sm(:,k).(varname)(1:end) = NaN;
end

%% 4) take NaN stats, and interpolate short NaN sequence
    for k = 1:size(depth,2)
    % Read soil moisture vector
        depthfield = sprintf('depth%dcm', depth(k));
        disp(depthfield)
        data.(depthfield).qc = zeros(dim,nstation);
        
        for n = 1:nstation
            disp(n)
            varname = sprintf('Var%d',n);
            sm = data.(depthfield).sm(:,n);

        %% NaN statistics
        % rewrite all the fillvalue to NaN
        sm = standardizeMissing(sm,fillvalue); 
        
        % detect NaN and make the statistics
                        %Example  % xxxxxNNNNNxxx    
        A = isnan(sm.(varname));  % 0000011111000    
        B = abs(diff(A));         %  000010000100
        B = vertcat([0],B);       % 0000010000100
        D = find(B==1);           %      6    10
        
        % if the data starts/ends as NaN, the row does not appear in D, so add it       
        if (isnan(sm.(varname)(1)))==1; D = vertcat([1],D); end
        if (isnan(sm.(varname)(end)))== 1; D = vertcat(D, dim); end
        
        % detect NaN sequence
        Dodd = D(1:2:end);Deven = D(2:2:end);
        nanstat = Deven - Dodd; %NaN hours
        % change this to find hours from time time variable later ... 

    % make quality flag depending on the NaN length
        flag1 = logical(nanstat <= 3)*1; % less than 3 hrs
        flag2 = logical(3 < nanstat & nanstat <= 24*3)*2; % 3h < NaN < 3 days
        flag3 = logical(24*3 < nanstat & nanstat <= 24*30)*3; % 3d < NaN < 30 d
        flag4 = logical(24*30 < nanstat)*4; % NaN > a month
        
    % check quality flag is empty of not 
        if isempty(flag1)== 1;flag1 = zeros(dim,1);end
        if isempty(flag2)== 1;flag2 = zeros(dim,1);end
        if isempty(flag3)== 1;flag3 = zeros(dim,1);end
        if isempty(flag4)== 1;flag4 = zeros(dim,1);end
        
    % put the NaN quality flag on sm data
        flag_nan = flag1 + flag2 + flag3 + flag4;
        % if NaN data exist, apply the quality flag to corresponding data sequence
        if isempty(Dodd) == 0 && isempty(Deven) == 0
        for p = 1:size(flag_nan,1)
         data.(depthfield).qc(Dodd(p):Deven(p)-1,n) = flag_nan(p);
        end
        % if there is no NaN data, just put zero matrix as quality flag
        else
         data.(depthfield).qc(:,n) = flag_nan;
        end
        
   %% Linear interpolation of NaN less than 3 hours
        data.(depthfield).sm.(varname) = ...
           fillmissing(data.(depthfield).sm.(varname),'linear','MissingLocations',logical(data.(depthfield).qc(:,n)==1));

        end
    end

%% save the data and clear from the workspace 
    savefile = sprintf('%s_%s_cleaned.mat', site, obs);
    save(savefile, 'data','stationdata','depth','nstation','fillvalue','dim','site','obs','-v7.3');
    save('OZ_F_stationflag.mat', 'stationflag', 'stationflag101','stationflag102', 'stationflag103', ...
        'stationflag104','stationflag105', 'stationflag107');
   
%% =========== END OF THE CODE ============

