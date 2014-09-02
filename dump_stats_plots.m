% dump_stats_plots.m
% This script generates statistics and plots on the five key MUPS 
% parameters that need to be tracked.

function [dump_stats]=dump_stats_plots(d)

% These calculations are intended to be rough estimates, not exact

% 5 key parameters to track:  
% 1.  Warm starts  
% 2.  Total impulse
% 3.  Total pulses
% 4.  Throughput
% 5.  Frequency of SSM events

% -------------------------------------------------------------------------

% 1.  Warm starts - we're already tracking this
cum_warm_starts = d.warm_starts;

% 2.  Total impulse:
counts = d.e.counts - d.s.counts;
pri_thruster = (floor(counts ./ repmat(max(counts,[],2),1,8)) == 1);
thrust_pri = nan(size(pri_thruster));
thrust_pri(pri_thruster) = d.thrust(pri_thruster);
thrust_pri((thrust_pri==0))=NaN;
thrust = patch_missing_values(thrust_pri); % lbf
t_firing = counts * 0.01; % sec
impulse = thrust .* t_firing; 
cum_impulse = cumsum(impulse); % lbf-sec

% 3.  Total Pulse Count
before_new_params = (d.s.time < time('2009:300:00:00:00.000'));
after_new_params = ~before_new_params;
firing_period = 10 * before_new_params + 2.5625 * after_new_params; % sec
min_pw = 0.050 * ones(size(d.mode)); % sec
max_pw = .020 * before_new_params + .050 * after_new_params; % sec
total_pulses = floor((d.e.time - d.s.time) ./ firing_period) + 1;
total_pulses = repmat(total_pulses', 1, 8);
avg_cnts_per_pulse = counts ./ total_pulses;
below_min_pw = (avg_cnts_per_pulse < repmat(min_pw / .010, 1, 8));
pulses_per_thruster = total_pulses; 
pulses_for_low_cnts = floor(avg_cnts_per_pulse ./ (repmat(min_pw, 1, 8) / .010) .* total_pulses);
pulses_per_thruster(below_min_pw) = pulses_for_low_cnts(below_min_pw);
cum_pulses = cumsum(pulses_per_thruster);

% 4.  Propellant Throughput
flow_rate = patch_missing_values(d.flow_rate); %  lbm / sec
fuel_thru = repmat(flow_rate, 1, 8) .* t_firing; 
cum_fuel_thru = cumsum(fuel_thru); % lbm

% 5.  1-sec PW Pulse Trains - only events so far are L&A

% -------------------------------------------------------------------------

% Print Results
disp(' ')
disp('Cumulative Warm Starts:')
fprintf('MUPS-A:  [%.0f %.0f %.0f %.0f]  MUPS-B:  [%.0f %.0f %.0f %.0f]', d.warm_starts(end,:))
disp(' ')
disp(' ')
disp('Cumulative Impulse [lbf-sec]:')
fprintf('MUPS-A:  [%.0f %.0f %.0f %.0f]  MUPS-B:  [%.0f %.0f %.0f %.0f]', cum_impulse(end,:))
disp(' ')
disp(' ')
disp('Cumulative Pulse Count:')
fprintf('MUPS-A:  [%.0f %.0f %.0f %.0f]  MUPS-B:  [%.0f %.0f %.0f %.0f]', cum_pulses(end,:))
disp(' ')
disp(' ')
disp('Cumulative Propellant Throughput [lbm]:')
fprintf('MUPS-A:  [%.2f %.2f %.2f %.2f]  MUPS-B:  [%.2f %.2f %.2f %.2f]', cum_fuel_thru(end,:))
disp(' ')
disp(' ')
disp('Cumulative 1-sec Pulsewidth Trains:')
disp('MUPS-A:  [1 2 2 1]  MUPS-B:  [1 1 1 1]')
disp(' ')
disp(' ')
disp('Tabular Format for Life Remaining Table in Quarterly Report:')
fprintf('%.0f \t %.0f \t %.0f \t %.0f \t %.0f \t %.0f \t %.0f \t %.0f', d.warm_starts(end,:))
disp(' ')
fprintf('%.0f \t %.0f \t %.0f \t %.0f \t %.0f \t %.0f \t %.0f \t %.0f', cum_impulse(end,:))
disp(' ')
fprintf('%.0f \t %.0f \t %.0f \t %.0f \t %.0f \t %.0f \t %.0f \t %.0f', cum_pulses(end,:))
disp(' ')
fprintf('%.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f', cum_fuel_thru(end,:))
disp(' ')
fprintf('1 \t 2 \t 2 \t 1 \t 1 \t 1 \t 1 \t 1')
disp(' ')
disp(' ')

% -------------------------------------------------------------------------

sec_from_launch = d.s.time - time('1999:204:00:00:00');
t = sec_from_launch / (86400*365.25);

% Generate Plots
figure()
hold on
plot(t(1:893), cum_warm_starts(1:893,1),'b', 'LineWidth', 3)
plot(t(1:893), cum_warm_starts(1:893,2),'g', 'LineWidth', 3)
plot(t(1:893), cum_warm_starts(1:893,3),'m', 'LineWidth', 3)
plot(t(1:893), cum_warm_starts(1:893,4),'c', 'LineWidth', 3)
plot(t, cum_warm_starts(:,5),'b:', 'LineWidth', 3)
plot(t, cum_warm_starts(:,6),'g:', 'LineWidth', 3)
plot(t, cum_warm_starts(:,7),'m:', 'LineWidth', 3)
plot(t, cum_warm_starts(:,8),'c:', 'LineWidth', 3)
plot([2.6, 2], [310, 395], 'k')
plot([4, 3.3], [296, 395], 'k')
plot([5.4, 4.6], [282, 395], 'k')
plot([7, 7.5], [220, 149], 'k')
plot([14.2, 14.4], [80, 52], 'k')
plot(xlim(), [938 938], '--', 'LineWidth', 4, 'Color', [1, .4, 0])
plot(xlim(), [1250 1250], 'r--', 'LineWidth', 4)
grid()
title('MUPS Thruster Cumulative Warm Starts', 'FontSize', 14, 'FontWeight', 'Bold')
ylabel('Cumulative Warm Start Count', 'FontSize', 12, 'FontWeight', 'Bold')
xlabel('Years Since Launch',  'FontSize', 12, 'FontWeight', 'Bold')
legend('MUPS-A1', 'MUPS-A2', 'MUPS-A3', 'MUPS-A4', 'MUPS-B1', 'MUPS-B2', 'MUPS-B3', 'MUPS-B4','Location','NorthEast')
text(.5, 980, 'Operational Life Limit = 938', 'BackgroundColor', 'w')
text(.5, 1300, 'Effective Qual = 1250', 'BackgroundColor', 'w')
text(1.5, 430, 'A4')
text(2.8, 430, 'A3')
text(4.1, 430, 'A1')
text(7.6, 120, 'A2', 'BackgroundColor', 'w')
text(12, 100, 'B1, B2, B3, B4', 'BackgroundColor', 'w')
saveas(gcf, 'Cumulative_Warm_Starts.fig')
PNGprint('Cumulative_Warm_Starts.png')

figure()
hold on
plot(t(1:893), cum_impulse(1:893,1),'b', 'LineWidth', 3)
plot(t(1:893), cum_impulse(1:893,2),'g', 'LineWidth', 3)
plot(t(1:893), cum_impulse(1:893,3),'m', 'LineWidth', 3)
plot(t(1:893), cum_impulse(1:893,4),'c', 'LineWidth', 3)
plot(t, cum_impulse(:,5),'b:', 'LineWidth', 3)
plot(t, cum_impulse(:,6),'g:', 'LineWidth', 3)
plot(t, cum_impulse(:,7),'m:', 'LineWidth', 3)
plot(t, cum_impulse(:,8),'c:', 'LineWidth', 3)
plot(xlim(), [2749 2749], '--', 'LineWidth', 4, 'Color', [1, .4, 0])
plot(xlim(), [3665 3665], 'r--', 'LineWidth', 4)
grid()
title('MUPS Thruster Cumulative Impulse', 'FontSize', 14, 'FontWeight', 'Bold')
ylabel('Cumulative Impulse [lbf-sec]', 'FontSize', 12, 'FontWeight', 'Bold')
xlabel('Years Since Launch',  'FontSize', 12, 'FontWeight', 'Bold')
legend('MUPS-A1', 'MUPS-A2', 'MUPS-A3', 'MUPS-A4', 'MUPS-B1', 'MUPS-B2', 'MUPS-B3', 'MUPS-B4', 'Location','NorthEast')
text(.5, 2900, 'Operational Life Limit = 2,749 lbf-sec', 'BackgroundColor', 'w')
text(.5, 3800, 'Effective Qual = 3,665 lbf-sec', 'BackgroundColor', 'w')
saveas(gcf, 'Cumulative_Impulse.fig')
PNGprint('Cumulative_Impulse.png')

figure()
hold on
plot(t(1:893), cum_pulses(1:893,1)/1000,'b', 'LineWidth', 3)
plot(t(1:893), cum_pulses(1:893,2)/1000,'g', 'LineWidth', 3)
plot(t(1:893), cum_pulses(1:893,3)/1000,'m', 'LineWidth', 3)
plot(t(1:893), cum_pulses(1:893,4)/1000,'c', 'LineWidth', 3)
plot(t, cum_pulses(:,5)/1000,'b:', 'LineWidth', 3)
plot(t, cum_pulses(:,6)/1000,'g:', 'LineWidth', 3)
plot(t, cum_pulses(:,7)/1000,'m:', 'LineWidth', 3)
plot(t, cum_pulses(:,8)/1000,'c:', 'LineWidth', 3)
plot(xlim(), [128.250 128.250], '--', 'LineWidth', 4, 'Color', [1, .4, 0])
plot(xlim(), [171.000 171.000], 'r--', 'LineWidth', 4)
ylim([0, 200])
grid()
title('MUPS Thruster Cumulative Pulses', 'FontSize', 14, 'FontWeight', 'Bold')
ylabel('Cumulative Pulse Count in Thousands', 'FontSize', 12, 'FontWeight', 'Bold')
xlabel('Years Since Launch',  'FontSize', 12, 'FontWeight', 'Bold')
legend('MUPS-A1', 'MUPS-A2', 'MUPS-A3', 'MUPS-A4', 'MUPS-B1', 'MUPS-B2', 'MUPS-B3', 'MUPS-B4', 'Location','NorthEast')
text(.5, 134.000, 'Operational Life Limit = 128,250', 'BackgroundColor', 'w')
text(.5, 178.000, 'Effective Qual = 171,000', 'BackgroundColor', 'w')
saveas(gcf, 'Cumulative_Pulse_Count.fig')
PNGprint('Cumulative_Pulse_Count.png')

figure()
hold on
plot(t(1:893), cum_fuel_thru(1:893,1),'b', 'LineWidth', 3)
plot(t(1:893), cum_fuel_thru(1:893,2),'g', 'LineWidth', 3)
plot(t(1:893), cum_fuel_thru(1:893,3),'m', 'LineWidth', 3)
plot(t(1:893), cum_fuel_thru(1:893,4),'c', 'LineWidth', 3)
plot(t, cum_fuel_thru(:,5),'b:', 'LineWidth', 3)
plot(t, cum_fuel_thru(:,6),'g:', 'LineWidth', 3)
plot(t, cum_fuel_thru(:,7),'m:', 'LineWidth', 3)
plot(t, cum_fuel_thru(:,8),'c:', 'LineWidth', 3)
plot(xlim(), [21 21], '--', 'LineWidth', 4, 'Color', [1, .4, 0])
plot(xlim(), [28 28], 'r--', 'LineWidth', 4)
ylim([0,35])
grid()
title('MUPS Thruster Cumulative Propellant Throughput', 'FontSize', 14, 'FontWeight', 'Bold')
ylabel('Cumulative Propellant Throughput [lbm]', 'FontSize', 12, 'FontWeight', 'Bold')
xlabel('Years Since Launch',  'FontSize', 12, 'FontWeight', 'Bold')
legend('MUPS-A1', 'MUPS-A2', 'MUPS-A3', 'MUPS-A4', 'MUPS-B1', 'MUPS-B2', 'MUPS-B3', 'MUPS-B4', 'Location','NorthEast')
text(.5, 22, 'Operational Life Limit = 21 lbm', 'BackgroundColor', 'w')
text(.5, 29, 'Effective Qual = 28 lbm', 'BackgroundColor', 'w')
saveas(gcf, 'Cumulative_Propellant_Throughput.fig')
PNGprint('Cumulative_Propellant_Throughput.png')
