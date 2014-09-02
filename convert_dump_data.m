% convert dump History.mat into dump_stats.mat

% a script so load Dump_History into your workspace then run

d=Dump_History;

st=time;
et=time;
sc=[];
ec=[];
sm=[];
em=[];
stemp=[];
etemp=[];
sp=[];
ep=[];
mode=[];
vde=[];


for n=1:length(Dump_History)
    
    if d(n).MSID_DUMPFLAG.s>2 | d(n).MSID_DUMPFLAG.m>2 | d(n).MSID_DUMPFLAG.e>2
        
        % bogus dump, skip and do nothing
        
    else
    
st=[st, d(n).TIME.s];

et=[et, d(n).TIME.e];

sc=[sc; d(n).MSID_AOTHRST1.s, d(n).MSID_AOTHRST2.s, d(n).MSID_AOTHRST3.s, d(n).MSID_AOTHRST4.s];

ec=[ec; d(n).MSID_AOTHRST1.e, d(n).MSID_AOTHRST2.e, d(n).MSID_AOTHRST3.e, d(n).MSID_AOTHRST4.e];

sm=[sm; d(n).MSID_AOSYMOM1.s, d(n).MSID_AOSYMOM2.s, d(n).MSID_AOSYMOM3.s];

em=[em; d(n).MSID_AOSYMOM1.e, d(n).MSID_AOSYMOM2.e, d(n).MSID_AOSYMOM3.e];

stemp=[stemp; d(n).MSID_PMTANK1T.s,  d(n).MSID_PMTANK2T.s, d(n).MSID_PMTANK3T.s];

etemp=[etemp; d(n).MSID_PMTANK1T.e,  d(n).MSID_PMTANK2T.e, d(n).MSID_PMTANK3T.e];

sp=[sp; d(n).MSID_PMTANKP.s];

ep=[ep; d(n).MSID_PMTANKP.e];

mode=[mode; d(n).MSID_PCADMD2.s];

vde=[vde; d(n).MSID_VDESEL2.s];

end % end if/else

end % end for loop

dump_stats.s.time=st;
dump_stats.s.counts=sc;
dump_stats.s.mom=sm;
dump_stats.s.temp=stemp;
dump_stats.s.pres=sp;

dump_stats.e.time=et;
dump_stats.e.counts=ec;
dump_stats.e.mom=em;
dump_stats.e.temp=etemp;
dump_stats.e.pres=ep;

dump_stats.mode=mode;
dump_stats.vde=vde;
