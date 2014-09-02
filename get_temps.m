d=dump_stats
d.s.lines=[];
d.s.dea_t=[];
d.e.lines=[];
d.e.dea_t=[];

for n=1:length(d.s.time)
    
    
    t=gretafetch('PLINE_XLIST.dec', d.s.time(n)-100, d.e.time(n));
    
    d.s.lines=[d.s.lines; t.msids.MSID_PLINE01T.values(1) t.msids.MSID_PLINE02T.values(1) t.msids.MSID_PLINE03T.values(1) t.msids.MSID_PLINE04T.values(1) t.msids.MSID_PLINE05T.values(1) t.msids.MSID_PLINE06T.values(1) t.msids.MSID_PLINE07T.values(1) t.msids.MSID_PLINE08T.values(1) t.msids.MSID_PLINE09T.values(1) t.msids.MSID_PLINE10T.values(1) t.msids.MSID_PLINE11T.values(1) t.msids.MSID_PLINE12T.values(1) t.msids.MSID_PLINE13T.values(1) t.msids.MSID_PLINE14T.values(1) t.msids.MSID_PLINE15T.values(1) t.msids.MSID_PLINE16T.values(1)];
    
    d.e.lines=[d.e.lines; t.msids.MSID_PLINE01T.values(end) t.msids.MSID_PLINE02T.values(end) t.msids.MSID_PLINE03T.values(end) t.msids.MSID_PLINE04T.values(end) t.msids.MSID_PLINE05T.values(end) t.msids.MSID_PLINE06T.values(end) t.msids.MSID_PLINE07T.values(end) t.msids.MSID_PLINE08T.values(end) t.msids.MSID_PLINE09T.values(end) t.msids.MSID_PLINE10T.values(end) t.msids.MSID_PLINE11T.values(end) t.msids.MSID_PLINE12T.values(end) t.msids.MSID_PLINE13T.values(end) t.msids.MSID_PLINE14T.values(end) t.msids.MSID_PLINE15T.values(end) t.msids.MSID_PLINE16T.values(end)];
   
    
    
    d.s.dea_t=[d.s.dea_t; t.msids.MSID_TPC_DEA.values(1)] ;
    
    d.e.dea_t=[d.e.dea_t; t.msids.MSID_TPC_DEA.values(end) ] ;
    
    save dump_stats_all_t d
    
end