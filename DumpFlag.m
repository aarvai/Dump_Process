% dump flag extract
%
%  Extracts the dump flags switches for the mission
%
% log:
%   03-12-02  -- w.simmons -- original version
%
%


%open output file
out_filename = strcat('Dump_Flag-output-', date, '.txt');
out_fid = fopen(out_filename,'a');

%set home directory
home_dir = '/home/pcad/';


% loop through and execute the decom98
[m,n] =size(VCDU_List) ;  
for vcdu_number = 1:m

   current_vcdu = VCDU_List(vcdu_number);
   
   %execute decom98 on the file.
   command = ['decom98 -d P_DUMPFLAG.dec -m 3 -f ztlm@' ...
           char(current_vcdu) ' -n ' char(current_vcdu) ' -a DEFAULT']
   unix(command);
