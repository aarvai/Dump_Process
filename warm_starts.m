function [dump_stats]=warm_starts_b(dump_stats)

%WARM_STARTS:  uses mom_dumps structure to find and plot warm starts
%
% returns [recent_dump_rate(per week), years to qual] for all
% four thrustres


% thruster counts at start of each dump
sc=dump_stats.s.counts;

%thruster counts at end of each dump
ec=dump_stats.e.counts;


% did it change?
ws=ec-sc>0;
cum_ws=cumsum(ws)+15;   %sum them up and add 15 dumps for OAC tests

% add two warm starts for A1 and A3 and one for A2 and A4 starting
% with dump number 334 (2003:013) to account for SOH check and calibration
% for MUPS A1 anomaly.
cum_ws(334:end,:)=cum_ws(334:end,:)+repmat([2 1 2 1 0 0 0 0],length(dump_stats.s.time)-333,1);

% add one warm to B1, B2, B3, and B4 starting
% with dump number 887 (2003:013) to account for MUPS-B Checkout #1 on
% 2013:215
cum_ws(887:end,:)=cum_ws(887:end,:)+repmat([0 0 0 0 1 1 1 1],length(dump_stats.s.time)-886,1);

% add one warm to B1, B2, B3, and B4 starting
% with dump number 892 (2003:013) to account for MUPS-B Checkout #2 on
% 2013:231
cum_ws(892:end,:)=cum_ws(892:end,:)+repmat([0 0 0 0 1 1 1 1],length(dump_stats.s.time)-891,1);

% years since launch for each dump (start time - launch time)/(sec per year)
ysl=(dump_stats.s.time-time(1999204))/(86400*365);


% find years to qual (1250)
% Changed to years to swap criteria (938)  9/4/07 

ri=find(dump_stats.s.time>(time(clock)-365*86400)); %index for 1 year ago



% plot

figure(1);
clf;
plot(ysl',cum_ws);
hold on
plot(xlim(), [938, 938],'y')
plot(xlim(), [1250, 1250],'r')
ylim([0 1300])
ylabel('warm starts')
xlabel('time since launch [years]');
title('MUPS Thrusters Warm Starts vs. Qual');
legend('A1','A2','A3','A4','B1','B2','B3','B4','Operational Life (938)','Ext. Qual (1250)',2);
grid;


print -dpng -r80 -noui -zbuffer warm_starts.png
saveas(gcf,'warm_starts.fig','fig');

dump_stats.warm_starts=cum_ws;


