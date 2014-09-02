%scrap2.m

clear all
close all
clc

load dump_stats.mat

cnts = d.e.counts - d.s.counts;
t_fire = cnts * .010;
dur = (d.e.time - d.s.time)';
dc = 100 .* t_fire ./ repmat(dur, 1, 8);
cnt10 = dc > repmat(.5*max(dc,[],2), 1, 8);
t = d.s.time;
ISP = d.ISP;
thrust = d.thrust;
valve_t = [d.s.v1t(:,1), d.s.v2t(:,1), d.s.v3t(:,1), d.s.v4t(:,1), d.s.v1t(:,2), d.s.v2t(:,2), d.s.v3t(:,2), d.s.v4t(:,2)];

%get the quaternion of rotation between the two quats
q_between = q_mult(q_inv(d.e.quat'),d.s.quat');
%the manuever angle is 2 * arccos(q4)
man_angle = abs(2*(acos(q_between(4,:)))) * 180/pi;

ok=man_angle'<2.5 & min(dc,[],2)==0 & max(dc,[],2)>0 & dur>120 & d.t_from_per'>3600;
dn=cumsum(ok);

fp = find(t>time('2009:300'),1,'first');

% First set:  to include all dumps that meet criteria
for i=1:4
    ok2 = ok & cnt10(:,i) & (t>time('2009:300'))';  %also require 10 counts and new FP
    
    figure(1)
    set(gcf, 'Position', [0,0,600,800])
    subplot(4,1,i)
    plot(dn(ok2), ISP(ok2,i), '*')
    xlabel('NPM Dump #', 'FontWeight', 'Bold', 'FontSize', 13)
    ylabel(['A',num2str(i),' ISP (sec)'], 'FontWeight', 'Bold', 'FontSize', 13)
    set(gca,'FontSize',20)
    ylim([100,250])
    grid()
    hold on
    %plot([dn(fp),dn(fp)],ylim(),'r')
    %text(350, 125, 'Updated Firing Params', 'Color','r','BackgroundColor','w', 'FontSize', 13)
        
    figure(2)
    set(gcf, 'Position', [300,300,600,800])
    subplot(4,1,i)
    plot(dn(ok2), valve_t(ok2,i), '*')
    xlabel('NPM Dump #', 'FontWeight', 'Bold', 'FontSize', 13)
    ylabel(['A',num2str(i),' Temp (deg F)'], 'FontWeight', 'Bold', 'FontSize', 13)
    set(gca,'FontSize',20)
    ylim([50,200])
    grid()
    hold on
    %plot([dn(fp),dn(fp)],ylim(),'r')
    if i == 1 | i == 2
        %text(350, 75, 'Updated Firing Params', 'Color','r','BackgroundColor','w', 'FontSize', 13)
    else
        %text(350, 175, 'Updated Firing Params', 'Color','r','BackgroundColor','w', 'FontSize', 13)
    end 
    
    figure(3)
    set(gcf, 'Position', [600,0,600,800])
    subplot(4,1,i)
    plot(dn(ok2), thrust(ok2,i), '*')
    xlabel('NPM Dump #', 'FontWeight', 'Bold', 'FontSize', 13)
    ylabel(['A',num2str(i),' Thrust (lbf)'], 'FontWeight', 'Bold', 'FontSize', 13)
    set(gca,'FontSize',20)
    ylim([.1, .3])
    grid()
    hold on
    %plot([dn(fp),dn(fp)],ylim(),'r')    
    %text(350, .26, 'Updated Firing Params', 'Color','r','BackgroundColor','w', 'FontSize', 13)
    % Calculate best-fit line
    ok3 = ok2 & (dn<500)
    p = polyfit(dn(ok3), thrust(ok3,i),1);
    plot(dn(ok2), polyval(p,dn(ok2)), 'k')
end
for i = 1:3
    figure(i)
    subplot(4,1,1)
    title('NPM Dumps:  New FP, >2 min dur, > 1 hr from perigee, > 10 cnts/pulse', 'FontWeight', 'Bold', 'FontSize', 13)
end

% Second set:  to only include dumps with new FP that meet criteria
ok=man_angle'<2.5 & min(dc,[],2)==0 & max(dc,[],2)>0 & dur>120 & d.t_from_per'>3600 & (t>time('2009:300'))';
for i=1:4
    ok2 = ok & cnt10(:,i);
        
    figure(4)
    set(gcf, 'Position', [900,300,600,800])
    subplot(4,1,i)
    plot(dur(ok2), ISP(ok2,i), '*')
    xlabel('Dump Duration (sec)', 'FontWeight', 'Bold', 'FontSize', 13)
    ylabel(['A',num2str(i),' ISP (sec)'], 'FontWeight', 'Bold', 'FontSize', 13)
    set(gca,'FontSize',20)
    xlim([100,400])
    ylim([100,250])
    grid()
    
    figure(5)
    set(gcf, 'Position', [1200,0,600,800])
    subplot(4,1,i)
    plot(valve_t(ok2,i), ISP(ok2,i), '*')
    xlabel(['A',num2str(i),' Starting Valve Temp (deg F)'], 'FontWeight', 'Bold', 'FontSize', 13)
    ylabel(['A',num2str(i),' ISP (sec)'], 'FontWeight', 'Bold', 'FontSize', 13)
    set(gca,'FontSize',20)
    xlim([50,200])
    ylim([100,250])
    grid()
    
end
for i = 4:5
    figure(i)
    subplot(4,1,1)
    title('NPM Dumps:  New FP, >2 min dur, > 1 hr from perigee, > 10 cnts/pulse', 'FontWeight', 'Bold', 'FontSize', 13)
end

% Save results
%figure(1)
%PNGprint('Cnts10_ISPvDN.png')
%figure(2)
%PNGprint('Cnts10_TempvDN.png')
%figure(3)
%PNGprint('Cnts10_ThrustvDN.png')
%figure(4)
%PNGprint('Cnts10_ISPvDur.png')
%figure(5)
%PNGprint('Cnts10_ISPvTemp.png')

% Additional data/plots for presentation charts
dn_grn = [502, 503, 504, 505, 506, 507, 510, 512, 518, 521, 530, 537, 538, 539, 540, 541, 544, 545, 546, 547, 549, 555, 557, 558, 559, 560, 562, 567, 570, 571, 572, 573];
dn_ylw = [569, 574, 575, 576, 577, 578, 584];
dn_red = [585, 586, 587];

for i = 1:length(dn_grn)
    i_grn(i) = find(dn==dn_grn(i), 1, 'first');
end
for i = 1:length(dn_ylw)
    i_ylw(i) = find(dn==dn_ylw(i), 1, 'first');
end
for i = 1:length(dn_red)
    i_red(i) = find(dn==dn_red(i), 1, 'first');
end

disp('Green:')
disp(['Temp:  ',num2str(mean(d.s.v1t(i_grn,1)))])
disp(['ISP:  ',num2str(mean(d.ISP(i_grn,1)))])
disp('Yellow:')
disp(['Temp:  ',num2str(mean(d.s.v1t(i_ylw,1)))])
disp(['ISP:  ', num2str(mean(d.ISP(i_ylw,1)))])
disp('Red:')
disp(['Temp:  ', num2str(mean(d.s.v1t(i_red,1)))])
disp(['ISP:  ', num2str(mean(d.ISP(i_red,1)))])

figure(1)
subplot(4,1,1)
plot(dn(i_grn), ISP(i_grn,1), 'g*')
plot(dn(i_ylw), ISP(i_ylw,1), 'y*')
plot(dn(i_red), ISP(i_red,1), 'r*')

figure(2)
subplot(4,1,1)
plot(dn(i_grn), valve_t(i_grn,1), 'g*')
plot(dn(i_ylw), valve_t(i_ylw,1), 'y*')
plot(dn(i_red), valve_t(i_red,1), 'r*')

figure(3)
subplot(4,1,1)
plot(dn(i_grn), thrust(i_grn,1), 'g*')
plot(dn(i_ylw), thrust(i_ylw,1), 'y*')
plot(dn(i_red), thrust(i_red,1), 'r*')

figure(4)
subplot(4,1,1)
hold on
plot(dur(i_grn), ISP(i_grn,1), 'g*')
plot(dur(i_ylw), ISP(i_ylw,1), 'y*')
plot(dur(i_red), ISP(i_red,1), 'r*')

figure(5)
subplot(4,1,1)
hold on
plot(valve_t(i_grn,1), ISP(i_grn,1), 'g*')
plot(valve_t(i_ylw,1), ISP(i_ylw,1), 'y*')
plot(valve_t(i_red,1), ISP(i_red,1), 'r*')

% % Calculate slope pre and post new FP for Gordon
% ok_pre_fp = man_angle'<2.5 & min(dc,[],2)==0 & max(dc,[],2)>0 & dur>120 & d.t_from_per'>3600 & (t<time('2009:273'))';
% ok_post_fp = man_angle'<2.5 & min(dc,[],2)==0 & max(dc,[],2)>0 & dur>120 & d.t_from_per'>3600 & (t>time('2009:300'))' & (t<time('2012:356'))';
% 
% for i=1:4
%     ok_pre_fp2 = ok_pre_fp & cnt10(:,i) & ISP(:,i)>150;
%     ok_post_fp2 = ok_post_fp & cnt10(:,i);
%     P_pre_fp(i,:) = polyfit(dn(ok_pre_fp2), ISP(ok_pre_fp2, i), 1);
%     P_post_fp(i,:) = polyfit(dn(ok_post_fp2), ISP(ok_post_fp2, i), 1);
%     figure(1)
%     subplot(4,1,i)
%     plot(dn(ok_pre_fp2), P_pre_fp(i,1)*dn(ok_pre_fp2) + P_pre_fp(i,2), 'r-')
%     plot(dn(ok_post_fp2), P_post_fp(i,1)*dn(ok_post_fp2) + P_post_fp(i,2), 'r-')    
% end
% 
% disp('Slopes pre-FP:')
% disp(P_pre_fp(:,1))
% disp(' ')
% disp('Slopes post-FP:')
% disp(P_post_fp(:,1))
% 
% disp('Angles pre-FP:')
% disp(atan(P_pre_fp(:,1))*180/pi)
% disp(' ')
% disp('Angles post-FP:')
% disp(atan(P_post_fp(:,1))*180/pi)
% 
% a_pre_fp = atan(P_pre_fp(:,1))*180/pi;
% a_post_fp = atan(P_post_fp(:,1))*180/pi;
% 
% disp('Rotation:')
% disp(a_post_fp - a_pre_fp)