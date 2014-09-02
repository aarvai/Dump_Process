function [dump_stats]=flow_rate(dump_stats)

%FLOW_RATE:  calculates time dependent fuel flow rate from mom_dumps.mat

% years since launch for each dump (start time - launch time)/(sec per year)
ysl=(dump_stats.s.time-time(1999204))/(86400*365);

% thruster counts at start of each dump
sc=dump_stats.s.counts;

%thruster counts at end of each dump
ec=dump_stats.e.counts;

%on times
on_time = (ec-sc)/100;  %convert to sec from counts
on_time_per_start = sum(on_time,2);  %sum of all 4 thrusters [sec]
cumulative_on_time = cumsum(on_time_per_start);  %sum of all 4 thrusters for whole mission [sec]


%fuel flow rate fit.  fit calculated fuel left to thruster on time

fuel_poly = polyfit(cumulative_on_time,dump_stats.fuel_left,2);  %2nd order least squares fit of fuel vs. total on-time
fuel_fit = polyval(fuel_poly,cumulative_on_time);
flow_rate = -1* diff(fuel_fit)./diff(cumulative_on_time); %[lbm/sec]
flow_rate = [NaN; flow_rate];   %need to add one NaN to make vector long enough]



%plot

figure(3);
clf;
orient tall;
subplot(3,1,1);
plot(cumulative_on_time,dump_stats.fuel_left,cumulative_on_time,fuel_fit);


ylabel('Fuel Remaining [lbs]')
xlabel('cumulative MUPS thruster total on-time [sec]');
title('MUPS Fuel Remaining vs. Thruster On-Time');
%legend('Fuel Remaining','2nd Order Curve Fit');
grid;

subplot(3,1,2);
plot(ysl,dump_stats.e.pres);
ylabel('Tank Pressure [psi]')
xlabel('time since launch [years]');
title('MUPS Tank Pressure');
grid;

subplot(3,1,3);
plot(ysl,flow_rate);
ylabel('Estimated Fuel Flow Rate [lbm/sec]')
xlabel('time since launch [years]');
title('Estimated MUPS Fuel Flow Rate');
grid;

print -dpng -r80 -noui -zbuffer fig3.png

dump_stats.flow_rate=flow_rate;

