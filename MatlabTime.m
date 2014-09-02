function mat_t=MatlabTime(t)
%this function will convert Chandra's time class to Matlab time class

t=double(t);  %convert chandra time into seconds rel to 1990:001
mat_t0=datenum([1990,1,1,0,0,0]);  %matlab value for 1990:001
for i=1:length(t)
    mat_t(i)=mat_t0+datenum([0,0,0,0,0,t(i)]); %add delta t to matlab t0
end
