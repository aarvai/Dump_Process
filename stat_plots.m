% stat plots script file

load dump_stats_all_t

dc=d.e.counts-d.s.counts;
dur=d.e.time-d.s.time;
dur=dur';
st=[d.s.v1t(:,1), d.s.v2t(:,1), d.s.v3t(:,1), d.s.v4t(:,1)];
et=[d.e.v1t(:,1), d.e.v2t(:,1), d.e.v3t(:,1), d.e.v4t(:,1)];
dt=et-st;

% duration plot

plot(d.s.time,dur)
title('Dump Durations')
xlabel('Date')
ylabel('Duration (sec)')
grid
print -dpng -r80 -noui -zbuffer Dump_durations.png

% per thruster plots 

for n=1:4
    
    i=find(dc(:,n)>100 & dur>120);
    
    figure(n*10+1)
    plot(dc(i,n)/100,dt(i,n),'k+');
    title(['Change in temperature vs. Ontime A' num2str(n)])
    xlabel('ontime (sec)')
    ylabel('Degrees')
    grid
    print('-dpng', '-r80', '-noui', '-zbuffer', strcat('A', num2str(n), '_TEMPvONTIME.png'));
    
    figure(n*10+2)
    plot(dur(i),dt(i,n),'k+');
    title(['Change in temperature vs. dump duration A' num2str(n)])
    xlabel('Duration (sec)')
    ylabel('Degrees')
    grid
    print('-dpng', '-r80', '-noui', '-zbuffer', ['A' num2str(n) '_TEMPvDURATION.png'])
    
    figure(n*10+3)
    plot(d.s.time(i),100*dt(i,n)./dc(i,n));
    title(['Change in temperature per second of ontime A' num2str(n)])
    xlabel('Date')
    ylabel('Degrees/sec')
    grid
    print('-dpng', '-r80', '-noui', '-zbuffer', ['A' num2str(n) '_TempPerOntime.png'])
    
    figure(n*10+4)
    plot(d.s.time(i),dt(i,n)./dur(i));
    title(['Change in temperature per second of duration A' num2str(n)])
    xlabel('Date')
    ylabel('Degrees/sec')
    grid
    print('-dpng', '-r80', '-noui', '-zbuffer', ['A' num2str(n) '_TempPerDuration.png'])
   
    figure(n*10+5)
    plot(d.s.time(i),st(i,n),'b*',d.s.time(i),et(i,n),'m+');
    title(['Dump Temperatures  A' num2str(n)])
    xlabel('Date')
    ylabel('Degrees')
    legend('start temp','end temp',4)
    grid
    print('-dpng', '-r80', '-noui', '-zbuffer', ['A' num2str(n) '_DumpTemps.png'])
    
    figure(n*10+6)
    plot(d.s.time(i),dc(i,n)/100,'k*-',d.s.time(i),dc(i,n)/100,'k+:');
    title(['Ontime per Dump A' num2str(n)])
    xlabel('Date')
    ylabel('Ontime (sec)')
    grid
    print('-dpng', '-r80', '-noui', '-zbuffer', ['A' num2str(n) '_OntimePerDump.png'])
    
end
    
    
    
    
    
    
    
    
    
    
    
    
    