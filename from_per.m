

for n=1:length(d.s.time)
    
    d.t_from_per(n)=min(abs(t-d.s.time(n)))
end