function [mom_dumps] = get_dump_data(mom_dumps)

% GET DUMP DATA:  Uses greta and P_POSTMOMDUMP3 to get momentum dump data
%
% INPUT:  Mission momentum dump structure(mom_dumps), with new dump times added by find_dump_times
%
% OUTPUT:  Updated version of mom_dumps

% add check for dump flag>3 then don't add that dump

% add averaging of initial and final momentum




% check for new dumps - if none  - exit
if isempty(mom_dumps.new_dumps)
    break
end


a=length(mom_dumps.s.time);

for n=1:length(mom_dumps.new_dumps.start)
    
    fprintf('Collecting data for dump starting at %s ',char(mom_dumps.new_dumps.start(n)));
    
    % run greta backing up from estimated start and going past end
    
    D=gretafetch('P_POST_MOMDUMP3',mom_dumps.new_dumps.start(n)-180, mom_dumps.new_dumps.stop(n)+110);
    
    % refine dump times getting beginning, middle and end
    
    t=D.time(D.msids.MSID_DUMPFLAG.index);
    
    di=find(D.msids.MSID_DUMPFLAG.values>0);
    
    if max(D.msids.MSID_DUMPFLAG.values)>2
        fprintf('The dump starting at %s has a bad dump flag.',char(t(1)));
    end
    
    %get start, middle and end times
    
    ti=t(di(1));
    tm=t(floor(median(di)));
    tf=t(di(end));
    
    %check for constant dump 
    
    if max(diff(di))>1
        fprintf('The dump starting at %s has a gap in the dump flag.  Check for a second dump processed.',char(t(1)));
        
        ii=find(diff(di)>1);
        if length(ii)>1
            fprintf('I tried, but I cannot process it, too many gaps')
            ii=[];
        end
            % starting mid-dump?  if yes exclude start
            if D.msids.MSID_DUMPFLAG.values(1)>0
                ti=t(di(ii));
                
                % ending mid-dump?  if yes exclude end
            elseif D.msids.MSID_DUMPFLAG.values(end)>0
                tf=t(di(ii));
            else
                fprintf('I tried, but I cannot process it, oddly placed gaps')
            end
        end
      
            
            
            mom_dumps.s.time=[mom_dumps.s.time ti];
            
            mom_dumps.m.time=[mom_dumps.m.time tm];
            
            mom_dumps.e.time=[mom_dumps.e.time tf];
            
            
            
            % get values of the msids at these times
            
            fn = fieldnames(D.msids);
            
            for f = 1:length(fn)
                
                msid = char(fn(f));
                
                md = getfield(D.msids,msid); % this msid data
                mt = getfield(D,'time',{md.index}); % this msid time
                
                % get value at or before start time and save it to mom_dumps
                i=find(mt<=ti);
                mom_dumps=setfield(mom_dumps,'s',msid,{a+n},md.values(i(end)));
                
                % get value at or before middle time and save it to mom_dumps
                i=find(mt<=tm);
                mom_dumps=setfield(mom_dumps,'m',msid,{a+n},md.values(i(end)));
                
                % get value at or after end time and save it to mom_dumps
                i=find(mt>=tf);
                
                mom_dumps=setfield(mom_dumps,'e',msid,{a+n},md.values(i(1)));
                
            end  % end msid set loop
            
            save mom_dumps mom_dumps
            
        end  % end  dump loop
        
        
        
        
        
        
        
        
        
        
        
        
        
        % clear the new dumps field
        mom_dumps.new_dumps=[];