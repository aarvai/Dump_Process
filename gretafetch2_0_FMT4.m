function out = gretafetch(filename,t1,t2)
%gretafetch:  Imports GRETA data over a given time span.
%
%   OUT = gretafetch(DECFILE,TI,TF) Imports data for time
%   span TI-TF using the GRETA defined .dec file DECFILE.
%   The times can span multiple days or parts of days.
%   TI and TF must be objects of type TIME, and DECFILE
%   must be a string with the name of a valid GRETA .dec
%   XLIST file.  This function will only work on systems
%   that have access to GRETA.
%
%   Users should be extremely careful using this function
%   to retrieve large time spans of data, as the output
%   can get very large, particulary if ANY of the MSIDs
%   in the .dec file have a high data rate.
%
%   gretafetch works by finding a list of all available
%   files VCDU*.ztlm that cover the given time span, 
%   running the .dec file on each of them, reading
%   them with gretaread, and then merging the outputs.  
%
%   The output is a structure with the following fields:
%     
%      OUT.time is an object of class time giving the time
%      of each output point produced by the dec file(s).
%     
%      OUT.msids is a structure with the data for each MSID
%      produced by the dec file.  This structure has one
%      field for each of the MSIDS output by GRETA.  The
%      fieldnames are MSID_<MSID>.
%
%   Each of the fields in OUT.msids is also a structure.
%   If the output containts misd <MSID>, then the structure
%   will contain the following:
%
%      OUT.MSID_<MSID>.values is a vector of the non-stale
%      values produced by the dec file, or a cell array
%      of strings if the msid is text.
%
%      OUT.MSID_<MSID>.index is a logical array of type
%      uint8 than can be used to identify the time that
%      each of the non-stale values appears. The times
%      associated with the non stale values are thus
%      OUT.time(OUT.MSID_<MSID>.index), and the number
%      of values length(OUT.MSID_<MSID>.values) is equal
%      to sum(OUT.MSID_<MSID>.index)   
%
%   Example: 
%   %import maneuver data from GRETA 
%   %over a given time span
%   t1 = time('2001:002:05:15');
%   t2 = time('2001:002:05:40');
%   data = gretafetch('A_MNVR_EXTRACTOR',t1,t2); 
%
%   %plot this data
%   idx = data.msids.MSID_AOATTQT1.index;
%   val = data.msids.MSID_AOATTQT1.values;
%   plot(data.time(idx),val);
%   xlabel('Time');
%   title('AOATTQT1');
%   timeZoom;
%
%   See also: gretaread, gretamerge, time

%-------------------------------------
% Rev#    Date       Who     Purpose
% ----  --------  ---------  ---------
%  000  06/01/02  P.Goulart  Original
%
%-------------------------------------

%make sure that the filename has the right extension
[dum,filename] = fileparts(filename);
filename = [filename,'.dec'];

%make sure the inputs are the right types
t1 = time(t1);
t2 = time(t2);



%construct the command string and read the file


    [dum,outfile] = fileparts(tempname);
    cmdstr  = ['decom98 -d ' filename ' -m 4 -f ztlm_autoselect@' char(t1,'greta') '-' char(t2,'greta') ' -a ' outfile];
    fprintf(1,'%s\n',cmdstr);
    system(cmdstr);    
    %get the full path to the output file
    outfile  = fullfile(getenv('AXAFUSER'),'output',outfile); 
    if(exist(outfile))
         out = gretaread(outfile);
        delete(outfile);
    end
 

 
