% function y = nm_dist(size)
Mu = [0  0]';%均值，也就是数据的中心，控制生成点的总体位置
Sigma = [1 0 ; 0 1];
p = mvnrnd( [0,0]', [1, 0; 0, 1], 100000);
plot( p(1:2000,1), p(1:2000,2), 'b.', Mu(1), Mu(2), 'r*', 'MarkerSize', 4 );

x=find( max(abs(p),[],2) <= 0.5 );
x = p(x,:);
size(x)
figure(2);
plot(x(1:2000,1),x(1:2000,2),'b.',Mu(1),Mu(2),'r*','MarkerSize',4);
% csvwrite('bounded_normal_dist.csv', p(x,:));
