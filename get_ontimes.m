st=time(clock);

data=gretafetch('MUPS_ONTIMES.dec',time(1999219), time(1999250))

st
time(clock)
% get ontimes for MUPS-A

a.time=data.time(data.msids.MSID_AON.index);
a.on=data.msids.MSID_AON.values;

% remove start of day flips

temp=char(a.time);
day=time(temp(:,1:8));

i=abs(a.time-day)>70;

a.time=a.time(i);
a.on=a.on(i);

% remove anything less than 5 seconds


ontimes.a.start=a.time(a.on==1);
ontimes.a.stop=a.time(a.on==0);

% get ontimes for MUPS-B

b.time=data.time(data.msids.MSID_BON.index);
b.on=data.msids.MSID_BON.values;

% remove start of day flips

temp=char(b.time);
day=time(temp(:,1:8));

i=b.time-day>120;

b.time=b.time(i);
b.on=b.on(i);


ontimes.b.start=b.time(b.on==1);
ontimes.b.stop=b.time(b.on==0);