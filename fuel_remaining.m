function dump_stats=fuel_remaining(dump_stats)

%%FUEL_REMAINING: calculate fuel remaining using pv=nrt equations

% 04/22/08   K. Gage   Removed incorrect factor of 0.5 from calculation of worst case years remaining


%first some constants
v_sys      = 2382;          %system volume [in**3]   
rho_N2H2   = 0.036511;      %density of hydrazine [lbm/in**3]   %this could be refined
                                                                %to vary with temp, but it makes a tiny difference
                                                                %in the end calculation  
mgas       = 0.1;           %mass of helium [lbm]     
Rgas       = 4632;          % Gas constant for helium [in-lbf/lbmol-R]  


%use end of dump average temperature (in rankine)
temp=mean(dump_stats.e.temp,2)+459.67;
p=dump_stats.e.pres;

% find max possible temp (cal curve change at 70.04)
max_temp=zeros(size(dump_stats.e.temp));
i=dump_stats.e.temp>70.04;
max_temp(i)=dump_stats.e.temp(i)+0.687;
max_temp(~i)=dump_stats.e.temp(~i)+0.643;
max_temp=mean(max_temp,2)+459.67  ;

%find min possible temp
min_temp=zeros(size(dump_stats.e.temp));
min_temp(i)=dump_stats.e.temp(i)-0.687;
min_temp(~i)=dump_stats.e.temp(~i)-0.643;
min_temp=mean(min_temp,2)+459.67  ;


%max and min pressure
min_p=p-1.6;
max_p=p+1.6;

% fuel left calculation
Fuel_Left = rho_N2H2*(v_sys-((mgas*Rgas*temp)./p));

Max_Fuel_Left = rho_N2H2*(v_sys-((mgas*Rgas*max_temp)./max_p));
Min_Fuel_Left = rho_N2H2*(v_sys-((mgas*Rgas*min_temp)./min_p));


%find years left

ri=find(dump_stats.s.time>time(clock)-86400*365) ;  %index to last year  of dumps
f_use=(Fuel_Left(ri(1)-1)-Fuel_Left(end));% fuel use last r year
yof=num2str(floor(Fuel_Left(end)/f_use));


if f_use<Fuel_Left(end)/100  % attempt to avoid displaying innane numbers caused by
    f_use= [' < ' num2str(Fuel_Left(end)/100,2)];  % low fuel use and big errors
    yof=' > 100';
else
    f_use=num2str(f_use);
    
end

ysl=(dump_stats.s.time-time(1999204))/(86400*365);           %years since launch

yof_wc= Min_Fuel_Left(end)./(Max_Fuel_Left(ri(1)-1)-Min_Fuel_Left(end));
if yof_wc>100
    yof_wc=' > 100';
else
    yof_wc=num2str(floor(yof_wc));
end


% recent fit
ysl=ysl';
pred=ysl(ri(1)):.25:20';
fuel_poly = polyfit(ysl(ri),Fuel_Left(ri),1); 
fuel_fit = polyval(fuel_poly,ysl);
fuel_pred=polyval(fuel_poly,pred);


%plot
figure(2);
clf;
plot(ysl,Fuel_Left,'k');
hold on;
plot(ysl,Max_Fuel_Left,'k:');
hold on;
plot(ysl,Min_Fuel_Left,'k:');

v=axis;  v(3)=0; axis(v);
ylim([51 61])
ylabel('MUPS Fuel Remaining [lbm]')
xlabel('time since launch [years]');
title('MUPS Fuel Remaining (MUPS tank only)');
grid;
text(ysl(end),Fuel_Left(end)-.2,num2str(Fuel_Left(end),3)) % -.1 is to place label below line
text(.1,52.5,['Years remaining at recent rate: ' yof])
text(.1,52.2,['Years remaining at worst case recent rate: ' yof_wc])

text(.1,51.5,'Estimated 120 lbm of additional fuel available from the IPS tank')
print -dpng -r80 -noui -zbuffer fuel_remaining.png

dump_stats.fuel_left=Fuel_Left;
hold on;
plot(ysl(ri),Fuel_Left(ri),'b*',ysl(ri),fuel_fit(ri),pred,fuel_pred)
