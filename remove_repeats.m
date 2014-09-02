i=find([diff(d.s.time)>0 1]);


d.mode          = d.mode(i,:) ;        
d.vde           = d.vde(i,:)   ;        
d.fuel_left     = d.fuel_left(i,:);     
d.flow_rate	= d.flow_rate(i,:) ; 
d.thrust	= d.thrust(i,:)  	  ;
d.ISP		= d.ISP(i,:)  	   ;
d.t_from_per	= d.t_from_per(i)   ;
d.warm_starts	= d.warm_starts(i,:)   ;

d.s.time 	= d.s.time(i);   	
d.s.counts 	= d.s.counts(i,:);  
d.s.mom		= d.s.mom(i,:);  	
d.s.temp 	= d.s.temp(i,:);   	
d.s.pres 	= d.s.pres(i,:);   	
d.s.quat 	= d.s.quat(i,:);   	
d.s.lines	= d.s.lines(i,:);  	
d.s.dea_t	= d.s.dea_t(i,:);  	
d.s.v1t		= d.s.v1t(i,:);  	
d.s.v2t		= d.s.v2t(i,:);  	
d.s.v3t		= d.s.v3t(i,:);  	
d.s.v4t		= d.s.v4t(i,:);  	
d.s.sa_ang	= d.s.sa_ang(i,:);  
			
d.e.time 	= d.e.time(i);   		
d.e.counts 	= d.e.counts(i,:);		
d.e.mom		= d.e.mom(i,:);  
d.e.temp 	= d.e.temp(i,:);  
d.e.pres 	= d.e.pres(i,:);  
d.e.quat 	= d.e.quat(i,:);  
d.e.lines	= d.e.lines(i,:); 
d.e.dea_t	= d.e.dea_t(i,:); 
d.e.v1t		= d.e.v1t(i,:);  
d.e.v2t		= d.e.v2t(i,:);  
d.e.v3t		= d.e.v3t(i,:);  
d.e.v4t		= d.e.v4t(i,:);  
d.e.sa_ang	= d.e.sa_ang(i,:);