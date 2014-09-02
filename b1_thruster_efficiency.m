function out = b1_thruster_efficiency()

close all

%INPUTS
b1_bad_start = MatlabTime(time([2013215, 2013231, 2013352, 2014045, 2014125, 2014159, 2014194, 2014202]));
b1_bad_middle = MatlabTime(time([2013260, 2014045, 2014104, 2014159]));

%--------------------------------
thr = 1;

d = dir('/home/pcad/matlab/Thruster_Efficiency/wEnvMom/*20*mups_b*');

for thr = 1:4
    
    threff = [];
    br = [];
    mean_threff = [];
    t = time();
    v1at = [];
    v1bt = [];
    cnts = [];
    tot_cnts = [];
    for i = 1:length(d)
        eval(strcat(['load /home/pcad/matlab/Thruster_Efficiency/wEnvMom/',d(i).name, '/' d(i).name, '_mom.mat']));
        if strcmp(d(i).name, 'npm2013231_mups_b')
            %special handling for this HW checkout since there are periods
            %with no thruster firings
            thr_fired = momdata.threff(:, thr) > 0; %all pulses had 20 tot_cnts
            threff = [threff; momdata.threff(thr_fired,thr)]; %#ok
            br = [br; sum(thr_fired)]; %#ok
            mean_threff = [mean_threff; mean(momdata.threff(thr_fired,thr))];%#ok
            t = [t, momdata.Timestamp(momdata.DumpStartIndex)];%#ok
            v1at = [v1at, momdata.v1t(momdata.DumpStartIndex, 1)];%#ok
            v1bt = [v1bt, momdata.v1t(momdata.DumpStartIndex, 2)];%#ok
            cnts = [cnts; 20*ones(length(momdata.threff(thr_fired, thr)), 1)]; %#ok
            tot_cnts = [tot_cnts, sum(momdata.thrcnt(:, thr))];%#ok
        else
            pulses = sum(momdata.thrcnt,2) > 0;
            thr_fired = momdata.thrcnt(pulses,thr) > 0; %could be used to set min cnt req
            if sum(thr_fired) > 0
                threff = [threff; momdata.threff(thr_fired,thr)]; %#ok
                br = [br; sum(thr_fired)]; %#ok
                mean_threff = [mean_threff; mean(momdata.threff(thr_fired,thr))];%#ok
                t = [t momdata.Timestamp(momdata.DumpStartIndex)];%#ok
                v1at = [v1at, momdata.v1t(momdata.DumpStartIndex, 1)];%#ok
                v1bt = [v1bt, momdata.v1t(momdata.DumpStartIndex, 2)];%#ok
                all_cnts = momdata.thrcnt(pulses, thr);
                cnts = [cnts; all_cnts(thr_fired)]; %#ok
                tot_cnts = [tot_cnts, sum(momdata.thrcnt(:, thr))];%#ok
            end
        end
    end
    
    % low thrust calcs
    low = sum(threff < 70);
    tot = length(threff);
    perc = low/tot*100;
    
    figure()
    set(gcf, 'PaperPosition', [2 1 16 5]);
    scatter(1:length(threff), threff, 15, cnts, 'fill')
    ylim([0,200])
    hold on
    br_marks = cumsum(br);
    mean_i = [];
    for i = 1:length(br)
        plot([br_marks(i), br_marks(i)], ylim(), 'color', [.8, .8, .8])
        mean_i(i) = br_marks(i,1) - br(i)/2; %#ok
        date = char(t(i));
        if i==1
            text(0, 180 - 15*rem(i-1, 3), date(1:8))
        else
            text(br_marks(i-1)+5, 180 - 15*rem(i-1, 3), date(1:8))
        end
    end
    xlim([0,br_marks(end,1)])
    %plot(mean_i, mean_threff, 'g*')
    plot(xlim(), [70, 70], 'r:')
    x = xlim();
    text(x(1) + .1*(x(2)-x(1)), 30, {strcat('Total Pulses:  ', num2str(tot)), strcat('Low thrust pulses:  ', num2str(low), ' (', sprintf('%0.1f', perc), '%)')}, 'BackgroundColor', 'w')
    grid off
    xlabel({strcat('Cumulative Pulses on MUPS-B', num2str(thr), ' since Aug 2013'),'(unloads separated by gray vertical lines)'}, 'FontSize',15)
    ylabel('Thruster Efficiency (%)', 'FontSize',15)
    title(strcat('Thruster Efficiency on MUPS-B',num2str(thr)), 'FontSize',15, 'FontWeight', 'Bold')
    set(gca,'FontSize',15)
    c = colorbar();
    ylabel(c, 'Counts per Pulse')
    PNGprint(strcat('mups_b', num2str(thr), '_thruster_eff_cumulative.png'))
    
    if thr == 1
        
        % time between dumps calcs
        t_matlab = MatlabTime(t);
        dt = [14*365, diff(t_matlab)];
        
        start_i = find_closest(b1_bad_start, t_matlab);
        middle_i = find_closest(b1_bad_middle, t_matlab);
        both_i = intersect(start_i, middle_i);
        range = 1:length(t_matlab);
        good_i = setdiff(range, [start_i, middle_i]);
        
        % fuel throughput calcs -
        cum_tot_cnts = cumsum(tot_cnts);
        fuel_rate = .85*10^-3; %lbm/sec
        fuel_thru = cum_tot_cnts * 0.010 * fuel_rate; %lbm
        
        disp(' ')
        disp('Dumps at the following times are known to include low-thrust pulses at the beginning:')
        disp(char(t(start_i)))
        
        disp(' ')
        disp('Dumps at the following times are known to include low-thrust pulses mid-dump:')
        disp(char(t(middle_i)))
        
        disp(' ')
        disp('Dumps at the following times are known to include low-thrust pulses both at the beginning and mid-dump:')
        disp(char(t(both_i)))
        disp(' ')
      
        disp('On MUPS-B1, since August 2013, there have been:')
        disp(strcat([num2str(low), ' low thrust pulses (<70% of expected) out of ', num2str(tot), ' total pulses (', num2str(perc), '%)']))
        disp('Including the two MUPS-B HW checkouts')
        
        figure()
        plot(dt(good_i), ones(length(good_i)), 'go')
        hold on
        plot(dt(start_i), 2*ones(length(start_i)), 'rx')
        plot(dt(middle_i), 2*ones(length(middle_i)), 'rx')
        plot(dt(both_i), 2*ones(length(both_i)), 'rx')
        xlim([0,60])
        ylim([0, 3])
        set(gca, 'YTick', [1, 2])
        set(gca,'YTickLabel',['Nominal                    ';'Contained Low Thrust Pulses'])
        set(gca,'FontSize',15)
        xlabel('Days since Previous Unload', 'FontWeight', 'Bold')
        
        figure()
        set(gcf, 'PaperPosition', [2 1 6 10]);
        subplot(4,1,1)
        hist(dt, 0:5:110)
        title('All MUPS-B1 Unloads', 'FontWeight', 'Bold')
        xlim([0, 100])
        xlabel('Days Since Previous Unload')
        y = ylim();
        subplot(4,1,2)
        hist(dt(good_i), 0:5:110)
        title('Nominal MUPS-B1 Unloads', 'FontWeight', 'Bold')
        xlim([0, 100])
        xlabel('Days Since Previous Unload')
        ylim(y);
        ylabel('Occurrences')
        subplot(4,1,3)
        hist(dt(start_i), 0:5:110)
        title('Low Thrust on MUPS-B1 at Beginning of Unload', 'FontWeight', 'Bold')
        xlim([0, 100])
        xlabel('Days Since Previous Unload')
        ylim(y)
        ylabel('Occurrences')
        subplot(4,1,4)
        hist(dt(middle_i), 0:5:110)
        title('Low Thrust on MUPS-B1 Mid-Unload', 'FontWeight', 'Bold')
        xlim([0, 100])
        xlabel('Days Since Previous Unload')
        ylim(y)
        ylabel('Occurrences')
        PNGprint(strcat('mups_b1_low_thrust_time_btwn.png'))
        
        figure()
        set(gcf, 'PaperPosition', [2 1 6 10]);
        subplot(4,1,1)
        hist(v1bt, 95:10:205)
        title('All MUPS-B1 Unloads', 'FontWeight', 'Bold')
        xlim([100, 200])
        xlabel('B1 Firing Temp [deg F]')
        y = ylim();
        ylabel('Occurrences')
        subplot(4,1,2)
        hist(v1bt(good_i), 95:10:205)
        title('Nominal MUPS-B1 Unloads', 'FontWeight', 'Bold')
        xlim([100, 200])
        xlabel('B1 Firing Temp [deg F]')
        ylim(y)
        ylabel('Occurrences')
        subplot(4,1,3)
        hist(v1bt(start_i), 95:10:205)
        title('Low Thrust on MUPS-B1 at Beginning of Unload', 'FontWeight', 'Bold')
        xlim([100, 200])
        xlabel('B1 Firing Temp [deg F]')
        ylim(y)
        ylabel('Occurrences')
        subplot(4,1,4)
        hist(v1bt(middle_i), 95:10:205)
        title('Low Thrust on MUPS-B1 Mid-Unload', 'FontWeight', 'Bold')
        xlim([100, 200])
        xlabel('B1 Firing Temp [deg F]')
        ylim(y)
        ylabel('Occurrences')
        PNGprint(strcat('mups_b1_low_thrust_temps.png'))
        
        figure()
        plot(t, fuel_thru)
        hold on
        plot(xlim(), [.323, .323], 'r:')
        title('MUPS-B1 Fuel Throughput Since Aug 2013', 'FontWeight', 'Bold')
        ylabel('lbm')
        x = xlim();
        text(x(1) + 15*86400, .33, 'Contained within initial "hot" B1 line length')
        ylim([0, .5])
        PNGprint(strcat('mups_b1_fuel_thru.png'))
        
        f = fopen('mups_b1_thrust_updated_thru.html', 'wt');
        fprintf(f, '<font face="sans-serif" size=4> \n');
        date_thru = char(t(end));
        fprintf(f, date_thru(1:14));
        fclose(f);
        
        f = fopen('mups_b1_thrust_updated_on.html', 'wt');
        fprintf(f, '<font face="sans-serif" size=4> \n');
        date_on = char(time(clock));
        fprintf(f, date_on(1:14));
        fclose(f);
        
        f = fopen('mups_b1_thrust_start.html', 'wt');
        fprintf(f, '<font face="sans-serif" size=4> \n');
        for i = 1:length(start_i)
            fprintf(f, char(t(start_i(i))));
            fprintf(f, '<br>');
        end
        fclose(f);
        
        f = fopen('mups_b1_thrust_mid.html', 'wt');
        fprintf(f, '<font face="sans-serif" size=4> \n');
        for i = 1:length(middle_i)
            fprintf(f, char(t(middle_i(i))));
            fprintf(f, '<br>');
        end
        fclose(f);
        
    end
    
end

system('cp *.html /share/FOT/engineering/prop/plots');