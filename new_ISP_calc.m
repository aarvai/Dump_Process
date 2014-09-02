function [dump_stats]=ISP_calc_b(dump_stats)


% check perigee times
%for n=1:length(d.s.time)
    
 %   d.t_from_per(n)=min(abs(t-d.s.time(n)))
 %end


%construct momentum arm matrix for the MUPS thrusters


% continue to construct this instead of passing in mom_arm so that 
% center of mass can be upated when needed

mups_locations = [ 486.0 -42.2 -71.0;
    486.0  42.2 -71.0;
    486.0  42.2  71.0;
    486.0 -42.2  71.0];

chandra_cg     = [377.1 -0.2 1.1];

mups_from_cg   = (mups_locations - chandra_cg([1 1 1 1],:))./12; %convert to feet

thrust_vector_row = [ 0 1/2 sqrt(3)/2];

thrust_vectors = [ thrust_vector_row ; thrust_vector_row; thrust_vector_row; thrust_vector_row];

thrust_vectors = thrust_vectors .* [0 -1 1; 0 1 1; 0 1 -1; 0 -1 -1];

mom_arm = cross(mups_from_cg,thrust_vectors,2)';

vde = dump_stats.vde;

%  get delta counts

dc=dump_stats.e.counts-dump_stats.s.counts;

%convert to seconds

dt=dc/100 ;  %[sec]

%get the quaternion of rotation between the two quats
q_between = q_mult(q_inv(dump_stats.e.quat'),dump_stats.s.quat');
%the manuever angle is 2 * arccos(q4)
man_angle = abs(2*(acos(q_between(4,:)))) * 180/pi;

%  get NPM dumps that use 3 or fewer thrusters 

%  use man angle over mode to ensure inertial dumps
%  min count delta ==0 gives 3 or fewer thruster dumps and filters non-logical dumps
%  remove dumps under 2 minutes

% this is the easiest place to do this, it has nothing to do with ISP

dump_stats.mode=2*ones(length(dump_stats.s.time),1);
npm=man_angle'<0.5;
dump_stats.mode(npm)=1;


%ii=man_angle'<2.5 & min(dc,[],2)==0 & max(dc,[],2)>0 & (dump_stats.e.time-dump_stats.s.time)'>120 & dump_stats.t_from_per'>3600;
ii=man_angle'<2.5 & min(dc,[],2)==0 & max(dc,[],2)>0 & (dump_stats.e.time-dump_stats.s.time)'>120 ;


i=find(ii');

for n=1:length(i)    
    d=i(n);
    
    %  rotate counts into direction of thrust
    if vde(d) == 1
        dt_d = dt(d,5:8);
    else dt_d = dt(d,1:4);
    end
    A=mom_arm*diag(dt_d);
    
    %  get delta momentum
    
    mom=dump_stats.e.mom(d,:)-dump_stats.s.mom(d,:);
    
    
    %  get thrust
    
    T=A\mom';
    
    %   get ISP
    
    ISP=T./dump_stats.flow_rate(d);
    
    %update structure
    if vde(d) == 1
        dump_stats.thrust(d,5:8)=T';
        dump_stats.ISP(d,5:8)=ISP';
    else
        dump_stats.thrust(d,1:4)=T';
        dump_stats.ISP(d,1:4)=ISP';
    end
    
end

if length(dump_stats.thrust) < length(dump_stats.s.time);
    for n = length(dump_stats.thrust)+1:length(dump_stats.s.time);
        dump_stats.thrust(n,:)=zeros(1,8);
        dump_stats.ISP(n,:)=zeros(1,8);
    end
end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot MUPS-A
% sort by thruster use
[~,si]=sort(dc(:,1:4),2);


% set up plot characteristics
pc=['k.';'c.';'m+';'b*'];

%for each thruster (n) plot by use (u) 1=least, 4=most
for n=1:4
    
    for u=1:4
        ui=si(:,u)==n & ii & vde==0;
        dn_a=cumsum(ii & vde==0);
        figure(10);
        orient tall
        subplot(4,1,n);
        hold on;
        plot(dn_a(ui),dump_stats.thrust(ui,n),pc(u,:));
        grid on;
        ylim([0, 0.4]);
        ylabel(['Thrust A', num2str(n), ' (lbf)']);
        
        
        figure(11);
        orient tall
        subplot(4,1,n);
        hold on;
        plot(dn_a(ui),dump_stats.ISP(ui,n),pc(u,:));
        ylim([0, 300]);
        ylabel(['ISP A', num2str(n) ,' (sec)']);
        grid on;
        
        figure(12)
        orient tall
        subplot(4,1,n);
        hold on;
        plot(dump_stats.e.time(ui)-dump_stats.s.time(ui),dump_stats.ISP(ui,n),pc(u,:));
        ylim([0, 300]);
        ylabel(['ISP A', num2str(n) ,' (sec)']);
        grid on;
        
        figure(13)
        vlvtmp=[dump_stats.s.v1t(:,1) dump_stats.s.v2t(:,1) dump_stats.s.v3t(:,1) dump_stats.s.v4t(:,1)];
        orient tall
        subplot(4,1,n);
        hold on;
        plot(vlvtmp(ui,n),dump_stats.ISP(ui,n),pc(u,:));
        ylim([0, 300]);
        xlim([50 180])
        ylabel(['ISP A', num2str(n) ,' (sec)']);
        grid on;
        
        figure(14)
        orient tall
        subplot(4,1,n);
        hold on;
        plot(dn_a(ui),vlvtmp(ui,n),pc(u,:));
        ylim([50 200]);
        ylabel(['A', num2str(n), ' Valve Temp (deg F)']);
        grid on;        

    end
end

% put on tiny fake plot just so the legend can be outside the 4 axes

figure(10)
xlabel('MUPS-A NPM Dump Number')
pt=subplot('position',[.75 0.95 .2 .05]);
plot(1,1,'b*', 1,1,'m+',1,1,'c.',1,1,'k.');
set(pt,'Visible','off');
legend('dominant thruster','2nd most dominant thruster', 'fringe thruster','least used thruster (nominally 0)');
text(-6,1,{'Estimated Thrust', '(uses inertial dumps >2min)'},'FontWeight','bold')          
print -dpng -r80 -noui -zbuffer Thrust_A.png
saveas(gcf,'Thrust_A.fig')

figure(11)
xlabel('MUPS-A NPM Dump Number')
pt=subplot('position',[.75 0.95 .2 .05]);
plot(1,1,'b*', 1,1,'m+',1,1,'c.',1,1,'k.');
set(pt,'Visible','off');
legend('dominant thruster','2nd most dominant thruster', 'fringe thruster','least used thruster (nominally 0)');
text(-6,1,{'Estimated ISP', '(uses inertial dumps >2min)'},'FontWeight','bold')          
print -dpng -r80 -noui -zbuffer ISP_A.png   
saveas(gcf,'ISP_A.fig')

figure(12)
xlabel('MUPS-A Dump Duration (sec)')
pt=subplot('position',[.75 0.95 .2 .05]);
plot(1,1,'b*', 1,1,'m+',1,1,'c.',1,1,'k.');
set(pt,'Visible','off');
legend('dominant thruster','2nd most dominant thruster', 'fringe thruster','least used thruster (nominally 0)');
text(-6,1,{'Estimated ISP vs. Dump Duration', '(uses inertial dumps >2min)'},'FontWeight','bold')          
print -dpng -r80 -noui -zbuffer ISPvDur_A.png   
saveas(gcf,'ISPvDur_A.fig')

figure(13)
xlabel('Starting Valve Temperature (degrees)')
pt=subplot('position',[.75 0.95 .2 .05]);
plot(1,1,'b*', 1,1,'m+',1,1,'c.',1,1,'k.');
set(pt,'Visible','off');
legend('dominant thruster','2nd most dominant thruster', 'fringe thruster','least used thruster (nominally 0)');
text(-6,1,{'Estimated ISP v. Starting Valve Temp', '(uses inertial dumps >2min)'},'FontWeight','bold')          
print -dpng -r80 -noui -zbuffer ISPvTemp_A.png  
saveas(gcf,'ISPvTemp_A.fig') 

figure(14)
xlabel('MUPS-A NPM Dump Number')
pt=subplot('position',[.75 0.95 .2 .05]);
plot(1,1,'b*', 1,1,'m+',1,1,'c.',1,1,'k.');
set(pt,'Visible','off');
legend('dominant thruster','2nd most dominant thruster', 'fringe thruster','least used thruster (nominally 0)');
text(-6,1,{'Starting Valve Temp', '(uses inertial dumps >2min)'},'FontWeight','bold')          
print -dpng -r80 -noui -zbuffer Temps_A.png   
saveas(gcf,'Temps_A.fig')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot MUPS-B
close('all')
% sort by thruster use
[~,si]=sort(dc(:,5:8),2);


% set up plot characteristics
pc=['k.';'c.';'m+';'b*'];

%for each thruster (n) plot by use (u) 1=least, 4=most
for n=1:4
    
    for u=1:4
        ui=si(:,u)==n & ii & vde == 1;
        dn_b=cumsum(ii & vde == 1);
        figure(10);
        orient tall
        subplot(4,1,n);
        hold on;
        plot(dn_b(ui),dump_stats.thrust(ui,n+4),pc(u,:));
        grid on;
        ylim([0, 0.4]);
        ylabel(['Thrust B', num2str(n), ' (lbf)']);
        
        
        figure(11);
        orient tall
        subplot(4,1,n);
        hold on;
        plot(dn_b(ui),dump_stats.ISP(ui,n+4),pc(u,:));
        ylim([0, 300]);
        ylabel(['ISP B', num2str(n) ,' (sec)']);
        grid on;
        
        figure(12)
        orient tall
        subplot(4,1,n);
        hold on;
        plot(dump_stats.e.time(ui)-dump_stats.s.time(ui),dump_stats.ISP(ui,n+4),pc(u,:));
        ylim([0, 300]);
        ylabel(['ISP B', num2str(n) ,' (sec)']);
        grid on;
        
        figure(13)
        vlvtmp=[dump_stats.s.v1t(:,1) dump_stats.s.v2t(:,1) dump_stats.s.v3t(:,1) dump_stats.s.v4t(:,1)];
        orient tall
        subplot(4,1,n);
        hold on;
        plot(vlvtmp(ui,n),dump_stats.ISP(ui,n+4),pc(u,:));
        ylim([0, 300]);
        xlim([50 180])
        ylabel(['ISP B', num2str(n) ,' (sec)']);
        grid on;
        
        figure(14)
        orient tall
        subplot(4,1,n);
        hold on;
        plot(dn_b(ui),vlvtmp(ui,n),pc(u,:));
        ylim([50 200]);
        ylabel(['B', num2str(n), ' Valve Temp (deg F)']);
        grid on;        

    end
end

% put on tiny fake plot just so the legend can be outside the 4 axes

figure(10)
xlabel('MUPS-B NPM Dump Number')
pt=subplot('position',[.75 0.95 .2 .05]);
plot(1,1,'b*', 1,1,'m+',1,1,'c.',1,1,'k.');
set(pt,'Visible','off');
legend('dominant thruster','2nd most dominant thruster', 'fringe thruster','least used thruster (nominally 0)');
text(-6,1,{'Estimated Thrust', '(uses inertial dumps >2min)'},'FontWeight','bold')          
print -dpng -r80 -noui -zbuffer Thrust_B.png
saveas(gcf,'Thrust_B.fig')

figure(11)
xlabel('MUPS-B NPM Dump Number')
pt=subplot('position',[.75 0.95 .2 .05]);
plot(1,1,'b*', 1,1,'m+',1,1,'c.',1,1,'k.');
set(pt,'Visible','off');
legend('dominant thruster','2nd most dominant thruster', 'fringe thruster','least used thruster (nominally 0)');
text(-6,1,{'Estimated ISP', '(uses inertial dumps >2min)'},'FontWeight','bold')          
print -dpng -r80 -noui -zbuffer ISP_B.png   
saveas(gcf,'ISP_B.fig')

figure(12)
xlabel('MUPS-B Dump Duration (sec)')
pt=subplot('position',[.75 0.95 .2 .05]);
plot(1,1,'b*', 1,1,'m+',1,1,'c.',1,1,'k.');
set(pt,'Visible','off');
legend('dominant thruster','2nd most dominant thruster', 'fringe thruster','least used thruster (nominally 0)');
text(-6,1,{'Estimated ISP vs. Dump Duration', '(uses inertial dumps >2min)'},'FontWeight','bold')          
print -dpng -r80 -noui -zbuffer ISPvDur_B.png   
saveas(gcf,'ISPvDur_B.fig')

figure(13)
xlabel('Starting Valve Temperature (degrees)')
pt=subplot('position',[.75 0.95 .2 .05]);
plot(1,1,'b*', 1,1,'m+',1,1,'c.',1,1,'k.');
set(pt,'Visible','off');
legend('dominant thruster','2nd most dominant thruster', 'fringe thruster','least used thruster (nominally 0)');
text(-6,1,{'Estimated ISP v. Starting Valve Temp', '(uses inertial dumps >2min)'},'FontWeight','bold')          
print -dpng -r80 -noui -zbuffer ISPvTemp_B.png  
saveas(gcf,'ISPvTemp_B.fig') 

figure(14)
xlabel('MUPS-B NPM Dump Number')
pt=subplot('position',[.75 0.95 .2 .05]);
plot(1,1,'b*', 1,1,'m+',1,1,'c.',1,1,'k.');
set(pt,'Visible','off');
legend('dominant thruster','2nd most dominant thruster', 'fringe thruster','least used thruster (nominally 0)');
text(-6,1,{'Starting Valve Temp', '(uses inertial dumps >2min)'},'FontWeight','bold')          
print -dpng -r80 -noui -zbuffer Temps_B.png   
saveas(gcf,'Temps_B.fig')














