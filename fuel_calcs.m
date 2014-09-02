function dump_stats=fuel_calcs_b(dump_stats)

% FUEL_CALCS: calculate fuel flow rate and fuel remaining extrapolating from
% fuel remaining derived from pressure readings prior to 2009:200

% Combines fuel_remaining.m and flow_rate.m functions

%first some constants
v_sys      = 2382;          %system volume [in**3]   
rho_N2H2   = 0.036511;      %density of hydrazine [lbm/in**3]   %this could be refined
                                                                %to vary with temp, but it makes a tiny difference
                                                                %in the end calculation  
mgas       = 0.1;           %mass of helium [lbm]     
Rgas       = 4632;          %Gas constant for helium [in-lbf/lbmol-R]  

%Only calculate fuel remaining from pressure readings prior to 2009:200
%(pressure readings invalid after this date due to transducer failure)

k=find(dump_stats.s.time<time(2009200));

%use end of dump average temperature (in rankine)
temp=mean(dump_stats.e.temp,2)+459.67;
p=dump_stats.e.pres;

% find max possible temp (cal curve change at 70.048)
max_temp=zeros(size(dump_stats.e.temp(k,:)));
delta_temp=zeros(size(dump_stats.e.temp(k,:)));
i=dump_stats.e.temp(k,:)>70.04;
delta_temp(i)=0.344;
delta_temp(~i)=0.322;
max_temp = dump_stats.e.temp(k,:) + delta_temp;
max_temp_avg=mean(max_temp,2)+459.67  ;

%find min possible temp
min_temp=zeros(size(dump_stats.e.temp(k,:)));
delta_temp=zeros(size(dump_stats.e.temp(k,:)));
i=dump_stats.e.temp(k,:)>70.05;
delta_temp(i)=-0.344;
delta_temp(~i)=-0.322;
min_temp = dump_stats.e.temp(k,:) + delta_temp;
min_temp_avg=mean(min_temp,2)+459.67  ;


%max and min pressure
min_p=p-0.8;
max_p=p+0.8;

% fuel left calculation
Fuel_Left = rho_N2H2*(v_sys-((mgas*Rgas*temp(k))./p(k)));

Max_Fuel_Left = rho_N2H2*(v_sys-((mgas*Rgas*min_temp_avg(k))./max_p(k)));
Min_Fuel_Left = rho_N2H2*(v_sys-((mgas*Rgas*max_temp_avg(k))./min_p(k)));


% thruster counts at start of each dump
sc=dump_stats.s.counts;

%thruster counts at end of each dump
ec=dump_stats.e.counts;

%on times
on_time = (ec-sc)/100;  %convert to sec from counts
on_time_per_start = sum(on_time,2);  %sum of all 8 thrusters [sec]
cumulative_on_time = cumsum(on_time_per_start);  %sum of all 8 thrusters for whole mission [sec]


% Calculate curve fit to smooth data from 1999:225 to 2009:200 
% (fuel remaining vs cumulative on time)

k2 = find(dump_stats.s.time>time(1999225) & dump_stats.s.time<time(2009200));

fuel_poly = polyfit(cumulative_on_time(k2),Fuel_Left(k2),2);  %2nd order least squares fit of fuel vs. total on-time
fuel_fit = polyval(fuel_poly,cumulative_on_time);

%Calculate fuel flow rate

flow_rate = -1* diff(fuel_fit)./diff(cumulative_on_time); %[lbm/sec]
flow_rate = [NaN; flow_rate];   %need to add one NaN to make vector long enough]

% Calculate curve fit to data from 1999:225 to 2009:200
% (fuel flow rate vs pressure)

flow_poly = polyfit(p(k2),flow_rate(k2),2);  %2nd order least squares fit of flow rate vs. tank pressure

%For dumps after 2000:200
%  Estimate pressure based on prior dump's fuel remaining and measured temperature
%  Extrapolate fuel flow rate
%  Calculate fuel remaining after dump from fuel rate and on time

%  Force initial fuel remaining to best estimate (curve fit)

Fuel_Left(k(end))=fuel_fit(k(end));

for j = (k(end)+1):length(dump_stats.s.time)
    p(j)=(mgas*Rgas*temp(j))/(v_sys-(Fuel_Left(j-1)/rho_N2H2));
    flow_rate(j)=polyval(flow_poly,p(j));
    Fuel_Left(j)=Fuel_Left(j-1)-(flow_rate(j)*on_time_per_start(j));
end


%find years left

ri=find(dump_stats.s.time>time(clock)-86400*365) ;  %index to last year of dumps
f_use=(Fuel_Left(ri(1)-1)-Fuel_Left(end));% fuel used over last year
yof=num2str(floor(Fuel_Left(end)/f_use));


if f_use<Fuel_Left(end)/100  % attempt to avoid displaying innane numbers caused by
    f_use= [' < ' num2str(Fuel_Left(end)/100,2)];  % low fuel use and big errors
    yof=' > 100';
else
    f_use=num2str(f_use);
    
end

%yof_wc= Min_Fuel_Left(end)./(Max_Fuel_Left(ri(1)-1)-Min_Fuel_Left(end));
%if yof_wc>100
%    yof_wc=' > 100';
%else
%    yof_wc=num2str(floor(yof_wc));
%end


% years since launch for each dump (start time - launch time)/(sec per year)
ysl=(dump_stats.s.time-time(1999204))/(86400*365);

% recent fit
ysl=ysl';
pred=ysl(ri(1)):.25:20';
fuel_poly_now = polyfit(ysl(ri),Fuel_Left(ri),1); 
fuel_fit_now = polyval(fuel_poly,ysl);
fuel_pred=polyval(fuel_poly_now,pred);


%plot
figure(2);
clf;
plot(ysl,Fuel_Left,'k');
hold on;
plot(ysl(k),Max_Fuel_Left,'k:');
hold on;
plot(ysl(k),Min_Fuel_Left,'k:');

ylim([0 65])
ylabel('MUPS Fuel Remaining [lbm]')
xlabel('time since launch [years]');
title('MUPS Fuel Remaining (MUPS tank only)');
grid;
text(ysl(end),Fuel_Left(end)-.2,num2str(Fuel_Left(end),3)) % -.1 is to place label below line
text(.1,17,['Years remaining at recent rate: ' yof])
%text(.1,52.2,['Years remaining at worst case recent rate: ' yof_wc])

text(.1,13,'Estimated 120 lbm of additional fuel available from the IPS tank')
print -dpng -r80 -noui -zbuffer fuel_remaining.png
saveas(gcf,'fuel_remaining','fig')

dump_stats.fuel_left=Fuel_Left;

hold on;
plot(ysl(ri),Fuel_Left(ri),'b*',ysl(ri),fuel_fit_now(ri),pred,fuel_pred)

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
%plot(ysl,dump_stats.e.pres);
plot(ysl,p);
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
saveas(gcf,'fig3','fig')

dump_stats.e.pres=p;
dump_stats.flow_rate=flow_rate;

