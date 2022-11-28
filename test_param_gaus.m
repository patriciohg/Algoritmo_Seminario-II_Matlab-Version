function [a,sigma_f,mu] = test_param_gaus(img)

Nx = size(img,1);
Ny = size(img,2);

x=[0:10:260];
y = hist(reshape(img,Nx*Ny,1),x);

mu = mean(mean(img));
a = max(y);

sigma = [5:1:50];
diff = nan(length(sigma),1);




for nn = 1:length(sigma)


    gaus = a*exp( -(x-mu).^2/(2*sigma(nn)^2)) ;
    diff(nn)  = sum((y - gaus).^2);

%     subplot(1,2,1)
%     plot(x,y,'or')
%     hold on;plot(x,gaus,'b')
% 
%     hold off
%     subplot(1,2,2)
%     plot(sigma,diff,'-o')
%     pause(0.5)


end

[m , b ] = min(diff);

sigma_f= sigma(b);



% figure;
% subplot(1,2,1)
% plot(x,y,'or')
% gaus = a*exp( -(x-mu).^2/(2*sigma(b)^2)) ;
% 
% hold on;plot(x,gaus,'b')
% 
% subplot(1,2,2)
%  plot(sigma,diff,'-o')
%  hold on
% plot(sigma(b),m,'xk','Markersize',20)
