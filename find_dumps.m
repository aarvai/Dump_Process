function [mom_dumps] = find_dumps(mom_dumps)

% FIND_DUMPS:  finds times of momentum dumps
%
% Uses gretafetch and P_DUMPFLAG.dec to extract dumop times
%
% INPUT: mom_dumps structure with known dump times
%
% OUTPUT: mom_dumps with the added field of new_dumps

% set search boundries

%ti=mom_dumps.e.time(end)+60;
ti=time(1999204);
tf = time(clock); 

fprintf('Searching for dumps between %s and %s.\n',char(ti), char(tf));

% run greta

flags = gretafetch('P_DUMPFLAG', ti, tf);

%extract useful information from structure

times=flags.time(flags.msids.MSID_DUMPFLAG.index);
val=flags.msids.MSID_DUMPFLAG.values;
diff=[0; diff(val)];
[m,i]=max(val);

if m>1
    fprintf('\n\nDump flag of %i found at time %s\n\n', m,char(time(i)))
end

if m>2
    fprintf('\n\nDump flag of %i found at time %s\n\n', m,char(time(i)))    
else
    
mom_dumps.new_dumps.start=times(diff==1);
mom_dumps.new_dumps.stop=times(diff==-1);
save in_work mom_dumps
end


