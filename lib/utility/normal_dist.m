% function y = nm_dist(size)
Mu = [0  0]';%均值，也就是数据的中心，控制生成点的总体位置
Sigma = [0.05 0 ; 0 0.05];
p = mvnrnd( Mu, Sigma, 10000);
plot( p(:,1), p(:,2), 'b.', Mu(1), Mu(2), 'r*', 'MarkerSize', 4 );
csvwrite('normal_dist_0.01_0.01.csv', p);


x=find( max(abs(p),[],2) <= 0.5 );
x = p(x,:);
size(x)
figure(2);
plot(x(:,1),x(:,2),'b.',Mu(1),Mu(2),'r*','MarkerSize',4);
% csvwrite('bounded_normal_dist.csv', p(x,:));
