function [d]=collect_stats_b(d,st,et)


%initialize structure if no existing data

if length(fieldnames(d.s))<2
    d.s.counts=[];
    d.s.mom=[];
    d.s.avg_mom=[];
    d.s.temp=[];
    d.s.pres=[];
    d.s.quat=[];
    d.s.lines=[];
    d.s.dea_t=[] ;
    d.s.v1t=[];
    d.s.v2t=[];
    d.s.v3t=[];
    d.s.v4t=[];
    d.s.sa_ang=[] ;
    
    d.e.counts=[];
    d.e.mom=[];
    d.e.avg_mom=[];
    d.e.temp=[];
    d.e.pres=[];
    d.e.quat=[];
    d.e.lines=[];
    d.e.dea_t=[] ;
    d.e.v1t=[];
    d.e.v2t=[];
    d.e.v3t=[];
    d.e.v4t=[];  
    d.e.sa_ang=[] ;
    
end

% search start time to end time for new momentum dumps

%if d.s.time(end)>time(st)
 %   warning('You have already colected dump stats for this timeframe')
  %  return
  %end

dt=gretafetch2_0('P_MUPS_ONTIMES',time(st),time(et));
%dt=gretaread('/home/pcad/AXAFUSER/output/P_MUPS_ONTIMES.txt');
starts=time;
stops=time;

if length(dt.msids.MSID_AON.values)>1
    at=dt.time(dt.msids.MSID_AON.index);
    i=find(dt.msids.MSID_AON.values(2:end)==1);
    ii=find(dt.msids.MSID_AON.values(2:end)==0);
    starts= at(i+1);
    stops=at(ii+1);
end

if length(dt.msids.MSID_BON.values)>1
    bt=dt.time(dt.msids.MSID_BON.index); 
    i=find(dt.msids.MSID_BON.values(2:end)==1);
    ii=find(dt.msids.MSID_BON.values(2:end)==0);
    starts= [starts bt(i+1)];
    stops=[stops bt(ii+1)];
end

if length(starts)>0 & length(stops)>0
    starts=sort(starts);
    stops=sort(stops);
    d.s.time=[d.s.time starts];
    d.e.time=[d.e.time stops];
    
else 
    warning('No dump found')
    return
end

for n=length(d.s.counts)+1:length(d.s.time)
    
    %collect start data
    
    getting_start=d.s.time(n)
    
    t=gretafetch('P_MOM_DUMP_STATS_X.dec', d.s.time(n)-65, d.s.time(n));
    
    d.s.mom=[d.s.mom; t.msids.MSID_AOSYMOM1.values(end) t.msids.MSID_AOSYMOM2.values(end) t.msids.MSID_AOSYMOM3.values(end)];
    
    %d.s.avg_mom=[d.s.avg_mom; mean(t.msids.MSID_AOSYMOM1.values) mean(t.msids.MSID_AOSYMOM2.values) mean(t.msids.MSID_AOSYMOM3.values)];
    
    d.s.temp=[d.s.temp; t.msids.MSID_PMTANK1T.values(end) t.msids.MSID_PMTANK2T.values(end) t.msids.MSID_PMTANK3T.values(end) ];
    
    d.s.pres=[d.s.pres; t.msids.MSID_PMTANKP.values(end)];
    
    d.s.quat=[d.s.quat ; t.msids.MSID_AOATTQT1.values(end) t.msids.MSID_AOATTQT2.values(end) t.msids.MSID_AOATTQT3.values(end) t.msids.MSID_AOATTQT4.values(end)]
    
    d.s.lines=[d.s.lines; t.msids.MSID_PLINE01T.values(end) t.msids.MSID_PLINE02T.values(end) t.msids.MSID_PLINE03T.values(end) t.msids.MSID_PLINE04T.values(end) t.msids.MSID_PLINE05T.values(end) t.msids.MSID_PLINE06T.values(end) t.msids.MSID_PLINE07T.values(end) t.msids.MSID_PLINE08T.values(end) t.msids.MSID_PLINE09T.values(end) t.msids.MSID_PLINE10T.values(end) t.msids.MSID_PLINE11T.values(end) t.msids.MSID_PLINE12T.values(end) t.msids.MSID_PLINE13T.values(end) t.msids.MSID_PLINE14T.values(end) t.msids.MSID_PLINE15T.values(end) t.msids.MSID_PLINE16T.values(end)];
    
    d.s.dea_t=[d.s.dea_t; t.msids.MSID_TPC_DEA.values(end)] ;
    
    d.s.v1t=[d.s.v1t; t.msids.MSID_PM1THV1T.values(end) t.msids.MSID_PM1THV2T.values(end)];
    
    d.s.v2t=[d.s.v2t; t.msids.MSID_PM2THV1T.values(end) t.msids.MSID_PM2THV2T.values(end)];
    
    d.s.v3t=[d.s.v3t; t.msids.MSID_PM3THV1T.values(end) t.msids.MSID_PM3THV2T.values(end)];
    
    d.s.v4t=[d.s.v4t; t.msids.MSID_PM4THV1T.values(end) t.msids.MSID_PM4THV2T.values(end)];
    
    d.s.sa_ang=[d.s.sa_ang; t.msids.MSID_AOSARES1.values(end)] ;
    
    d.vde=[d.vde ; t.msids.MSID_VDESEL2.values(1)]
    
    s_counts=[t.msids.MSID_AOTHRST1.values(end-2) t.msids.MSID_AOTHRST2.values(end-2) t.msids.MSID_AOTHRST3.values(end-2) t.msids.MSID_AOTHRST4.values(end-2)];
    
    if d.vde(end) 
        d.s.counts = [d.s.counts; zeros(1,4), s_counts];
    else d.s.counts = [d.s.counts; s_counts, zeros(1,4)];
    end
    
    %collect end data
    
    getting_end=d.e.time(n)
    
    t=gretafetch('P_MOM_DUMP_STATS_X.dec', d.e.time(n), d.e.time(n)+65);
   
    d.e.mom=[d.e.mom; t.msids.MSID_AOSYMOM1.values(1) t.msids.MSID_AOSYMOM2.values(1) t.msids.MSID_AOSYMOM3.values(1)];
    
    %d.e.avg_mom=[d.e.avg_mom; mean(t.msids.MSID_AOSYMOM1.values) mean(t.msids.MSID_AOSYMOM2.values) mean(t.msids.MSID_AOSYMOM3.values)];
    
    d.e.temp=[d.e.temp; t.msids.MSID_PMTANK1T.values(1) t.msids.MSID_PMTANK2T.values(1) t.msids.MSID_PMTANK3T.values(1) ];
    
    d.e.pres=[d.e.pres; t.msids.MSID_PMTANKP.values(1)];
    
    d.e.quat=[d.e.quat ; t.msids.MSID_AOATTQT1.values(1) t.msids.MSID_AOATTQT2.values(1) t.msids.MSID_AOATTQT3.values(1) t.msids.MSID_AOATTQT4.values(1)];
    
    d.e.lines=[d.e.lines; t.msids.MSID_PLINE01T.values(1) t.msids.MSID_PLINE02T.values(1) t.msids.MSID_PLINE03T.values(1) t.msids.MSID_PLINE04T.values(1) t.msids.MSID_PLINE05T.values(1) t.msids.MSID_PLINE06T.values(1) t.msids.MSID_PLINE07T.values(1) t.msids.MSID_PLINE08T.values(1) t.msids.MSID_PLINE09T.values(1) t.msids.MSID_PLINE10T.values(1) t.msids.MSID_PLINE11T.values(1) t.msids.MSID_PLINE12T.values(1) t.msids.MSID_PLINE13T.values(1) t.msids.MSID_PLINE14T.values(1) t.msids.MSID_PLINE15T.values(1) t.msids.MSID_PLINE16T.values(1)];
    
    d.e.dea_t=[d.e.dea_t; t.msids.MSID_TPC_DEA.values(1)] ;
    
    d.e.v1t=[d.e.v1t; t.msids.MSID_PM1THV1T.values(1) t.msids.MSID_PM1THV2T.values(1)];
    
    d.e.v2t=[d.e.v2t; t.msids.MSID_PM2THV1T.values(1) t.msids.MSID_PM2THV2T.values(1)];
    
    d.e.v3t=[d.e.v3t; t.msids.MSID_PM3THV1T.values(1) t.msids.MSID_PM3THV2T.values(1)];
    
    d.e.v4t=[d.e.v4t; t.msids.MSID_PM4THV1T.values(1) t.msids.MSID_PM4THV2T.values(1)];
    
    d.e.sa_ang=[d.e.sa_ang; t.msids.MSID_AOSARES1.values(1)] ;
    
    e_counts=[t.msids.MSID_AOTHRST1.values(3) t.msids.MSID_AOTHRST2.values(3) t.msids.MSID_AOTHRST3.values(3) t.msids.MSID_AOTHRST4.values(3)];
    
    if d.vde(end) 
        d.e.counts = [d.e.counts; zeros(1,4), e_counts];
    else d.e.counts = [d.e.counts; e_counts, zeros(1,4)];
    end
    
end

t=dlmread('per_times.txt');
t=time(t);
for n=1:length(d.s.time)
    
    d.t_from_per(n)=min(abs(t-d.s.time(n)));
end

% save dump_stats d