%Main program 
%Authors
%Muhammad Bilal
%Bashir ud Din
clear all; clc;
r= 0.05;
sig = 0.3;
strike = 10;
T = 1;
Smax = 30;
discretpoints = [40:40:2400]; % Vector for storing different number of Discretization Points.
discretpointsT = [30:30:2400];
nr = length(discretpoints);
dt = zeros(nr,1); % Stores the step size corresponding to the number of discretization points in time.
dx = zeros(nr,1); % St ores  the step size corresponding to the number of discretization points in stock.
spotprice = 15;% Spot price for testing different delta T and delta S




% Loop for different time & space discretization
Error = size(length(discretpointsT));
Vspot = size(length(discretpointsT));
C = BLScallpricetest(spotprice,r,sig,strike,T); % Black Scholes price at spot value for testing
%C = mean(C);
fprintf('\nBS and FDM Valuations for different delta x, for S = %f, t=0 \n',spotprice)
fprintf('delta X   deltat    BS Price             CN Price           Error\n')

for i = 1:nr
    % Crank Nicolson Price
    [S,U,time,V,dt(i),dx(i)] = CNpricetest(r,sig,strike,Smax,T,discretpointsT(i),discretpoints(i));
    S = S';
    opt = V(end,:)'; % Option price at grid points at price at t=0
    % Spline Interpolation at our required stock value, for comparison
    Vspot(i) = spline(S,opt,spotprice); % Option price for a particular stock value at t = 0;
    Error(i) = abs(((C- Vspot(i))/C)); %  error between CN at spotprice and BS at spotprice.
    fprintf('%f  %f    %d        %d        %d\n',dx(i),dt(i),C,Vspot(i),Error(i))
end
 
    temp = C * ones(length(dx), 1);
%     grid on;
    plot(dx,Vspot,dx,temp);
   set(gca, 'XDir','reverse')
xlim([ 0 0.025])
    title(' Black Scholes and Crank Nicholson Price for different step sizes')
    ylabel('Prices')
    legend('Crank Nicholson','Black Scholes',[50 60 10 20])
    xlabel('discretization steps')


% Option Price Calculation for 3D Plot
[S,U,time,V,delt,delx] = CNpricetest(r,sig,strike,Smax,T,299,299);
 figure;
 % 3D Plot
  
mesh(S,time,V);
title('3D Plot of Time, Stock Price, and European Call with Strike 10 for n') 
 
  
 
 xlabel('Stock Price')
 ylabel('Time')
 zlabel('Call Option Price')



%C = BLScallprice(15,r,sig,strike,T);