rng(18) ;

A = randi(100,10,15) ;

I = [1,3,3,5,9,10] ;
J = [3,3,3,8,9,13] ;

B = zeros(size(A)) ;

ind = sub2ind(size(A),I,J);

B(ind) = 1 ;