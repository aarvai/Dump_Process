

fid=fopen('NPM_dumps.txt','w+');

for m=1:length(i)
    n=i(m);
    fprintf(fid,'%s\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f',char(d.s.time(n)),d.s.mom(n,:),d.e.mom(n,:),dc(n,:));
    fprintf(fid,'\n');
end
