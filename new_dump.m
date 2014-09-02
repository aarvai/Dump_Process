function [dump_stats]=new_dump(dump_stats,st,et)

% function to update momentum dump structure

%pad times to be sure to get everything

fst=st-33;
fet=et+33;

d=gretafetch_nf('P_MOM_DUMP_STATS_X.dec',fst,fet)



st=dump_stats.s.time;
sc=dump_stats.s.counts;
sm=dump_stats.s.mom;
stemp=dump_stats.s.temp;
sp=dump_stats.s.pres;
sq=dump_stats.s.quat;

et=dump_stats.e.time;
ec=dump_stats.e.counts;
em=dump_stats.e.mom;
etemp=dump_stats.e.temp;
ep=dump_stats.e.pres;
eq=dump_stats.e.quat;


mode=dump_stats.mode;
vde=dump_stats.vde;


i=find(d.msids.MSID_DUMPFLAG.values>0) ; % use to get more accurate times

st=[st, d.time(i(1))];

et=[et, d.time(i(end))];

sc=[sc; d.msids.MSID_AOTHRST1.values(1), d.msids.MSID_AOTHRST2.values(1), d.msids.MSID_AOTHRST3.values(1), d.msids.MSID_AOTHRST4.values(1)];

ec=[ec; d.msids.MSID_AOTHRST1.values(end), d.msids.MSID_AOTHRST2.values(end), d.msids.MSID_AOTHRST3.values(end), d.msids.MSID_AOTHRST4.values(end)];


sm=[sm; mean(d.msids.MSID_AOSYMOM1.values(i(1)-2:i(1))), mean(d.msids.MSID_AOSYMOM2.values(i(1)-2:i(1))), mean(d.msids.MSID_AOSYMOM3.values(i(1)-2:i(1)))];

em=[em; mean(d.msids.MSID_AOSYMOM1.values(i(end):i(end)+2)), mean(d.msids.MSID_AOSYMOM2.values(i(end):i(end)+2)), mean(d.msids.MSID_AOSYMOM3.values(i(end):i(end)+2))];

sq=[sq; d.msids.MSID_AOATTQT1.values(i(1)), d.msids.MSID_AOATTQT2.values(i(1)), d.msids.MSID_AOATTQT3.values(i(1)), d.msids.MSID_AOATTQT4.values(i(1))] ;

eq=[eq; d.msids.MSID_AOATTQT1.values(i(end)), d.msids.MSID_AOATTQT2.values(i(end)), d.msids.MSID_AOATTQT3.values(i(end)), d.msids.MSID_AOATTQT4.values(i(end))] ;

stemp=[stemp; d.msids.MSID_PMTANK1T.values(1),  d.msids.MSID_PMTANK2T.values(1), d.msids.MSID_PMTANK3T.values(1)];

etemp=[etemp; d.msids.MSID_PMTANK1T.values(end),  d.msids.MSID_PMTANK2T.values(end), d.msids.MSID_PMTANK3T.values(end)];

sp=[sp; d.msids.MSID_PMTANKP.values(1)];

ep=[ep; d.msids.MSID_PMTANKP.values(end)];

mode=[mode; d.msids.MSID_PCADMD2.values(1)];

vde=[vde; d.msids.MSID_VDESEL2.values(1)];

dump_stats.s.time=st;
dump_stats.s.counts=sc;
dump_stats.s.mom=sm;
dump_stats.s.temp=stemp;
dump_stats.s.pres=sp;
dump_stats.s.quat=sq;

dump_stats.e.time=et;
dump_stats.e.counts=ec;
dump_stats.e.mom=em;
dump_stats.e.temp=etemp;
dump_stats.e.pres=ep;
dump_stats.e.quat=eq;


dump_stats.mode=mode;
dump_stats.vde=vde;

dump_stats.e.v1t=[dump_stats.e.v1t; d.msids.MSID_PM1THV1T.values(i(end)) d.msids.MSID_PM1THV2T.values(i(end))];

dump_stats.e.v2t=[dump_stats.e.v2t; d.msids.MSID_PM2THV1T.values(i(end)) d.msids.MSID_PM2THV2T.values(i(end))];

dump_stats.e.v3t=[dump_stats.e.v3t; d.msids.MSID_PM3THV1T.values(i(end)) d.msids.MSID_PM3THV2T.values(i(end))];

dump_stats.e.v4t=[dump_stats.e.v4t; d.msids.MSID_PM4THV1T.values(i(end)) d.msids.MSID_PM4THV2T.values(i(end))];

dump_stats.s.v1t=[dump_stats.s.v1t; d.msids.MSID_PM1THV1T.values(i(1)) d.msids.MSID_PM1THV2T.values(i(1))];

dump_stats.s.v2t=[dump_stats.s.v2t; d.msids.MSID_PM2THV1T.values(i(1)) d.msids.MSID_PM2THV2T.values(i(1))];

dump_stats.s.v3t=[dump_stats.s.v3t; d.msids.MSID_PM3THV1T.values(i(1)) d.msids.MSID_PM3THV2T.values(i(1))];

dump_stats.s.v4t=[dump_stats.s.v4t; d.msids.MSID_PM4THV1T.values(i(1)) d.msids.MSID_PM4THV2T.values(i(1))];

d=dump_stats
d.s.lines=[];
d.s.dea_t=[];
d.e.lines=[];
d.e.dea_t=[];


t=gretafetch('PLINE_XLIST.dec', fst, fet);

d.s.lines=[d.s.lines; t.msids.MSID_PLINE01T.values(1) t.msids.MSID_PLINE02T.values(1) t.msids.MSID_PLINE03T.values(1) t.msids.MSID_PLINE04T.values(1) t.msids.MSID_PLINE05T.values(1) t.msids.MSID_PLINE06T.values(1) t.msids.MSID_PLINE07T.values(1) t.msids.MSID_PLINE08T.values(1) t.msids.MSID_PLINE09T.values(1) t.msids.MSID_PLINE10T.values(1) t.msids.MSID_PLINE11T.values(1) t.msids.MSID_PLINE12T.values(1) t.msids.MSID_PLINE13T.values(1) t.msids.MSID_PLINE14T.values(1) t.msids.MSID_PLINE15T.values(1) t.msids.MSID_PLINE16T.values(1)];

d.e.lines=[d.e.lines; t.msids.MSID_PLINE01T.values(end) t.msids.MSID_PLINE02T.values(end) t.msids.MSID_PLINE03T.values(end) t.msids.MSID_PLINE04T.values(end) t.msids.MSID_PLINE05T.values(end) t.msids.MSID_PLINE06T.values(end) t.msids.MSID_PLINE07T.values(end) t.msids.MSID_PLINE08T.values(end) t.msids.MSID_PLINE09T.values(end) t.msids.MSID_PLINE10T.values(end) t.msids.MSID_PLINE11T.values(end) t.msids.MSID_PLINE12T.values(end) t.msids.MSID_PLINE13T.values(end) t.msids.MSID_PLINE14T.values(end) t.msids.MSID_PLINE15T.values(end) t.msids.MSID_PLINE16T.values(end)];


d.s.dea_t=[d.s.dea_t; t.msids.MSID_TPC_DEA.values(1)] ;

d.e.dea_t=[d.e.dea_t; t.msids.MSID_TPC_DEA.values(end) ] ;


dump_stats=d
%save dump_stats d
