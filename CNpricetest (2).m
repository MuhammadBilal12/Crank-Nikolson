 
%calculating value of option using Crank-nikplson
function [S,U,time,V,dt,dx] = CNprice(r,sig,strike,Smax,T,n,j)

% n and j are the number of required discretization points for Time and Stock respectively

k = 2*r/(sig^2); % Transformation variable
alpha = -0.5*(k-1); % Transformation variable
beta = -0.25*((1+k)^2);  % Transformation variable
xmin = -10; % Lower value for x
xmax = log(Smax/strike); % Upper value for x calculated using S max.
%xmax = 2;
taumin = 0; % Lower value for transformed time "Tau".
taumax = 0.5*sig^2*T; % Upper value for Tau
dx = (xmax-xmin)/j; % Step size for x
x = [xmin:dx:xmax]; % Vector which stores values for x
dt = (taumax-taumin)/n; % Step size for tau

tau = [taumin:dt:taumax]; % Vector which stores values for tau

lambda = (dt/(dx^2)); % For use in matrices
initcond = @(x)(max((exp(0.5*(k+1)*x)-exp(0.5*(k-1)*x)),0)); % Function to calculate initial condition
bndryleft = 0; % Left boundary value

% Function to calculate right boundary values.
% bndryright = @(t)(exp(0.5*(k-1)*xmax + 0.25*((k+1)^2)*t)-exp(0.5*(k+1)*xmax + 0.5*((k-1)^2)*t));
% bndryright=@(t) exp(0.5*(k+1)*xmax + 0.25*((k+1)^2)*t');
%bndryright=@(t) (exp(0.5*(k+1)*xmax + 0.5*((k+1)^2)*t)-exp(0.5*(k+1)*xmax + 0.5*((k-1)^2)*t));

bndryright= @(t)(exp(0.5*(k-1)*xmax+0.25*((k+1)^2)*t).*max((exp(xmax)-exp(-r*(2*t/(sig^2)))),0));
%bndryright = @(t)exp(((0.25*(k-1).^2)+k)*t).* max(exp(0.5*(k+1)*x)-exp(0.5*(k-1)*x),0);

%bndryright = exp(0.5*(k+1)*xmax + 0.25*((k+1)^2)*tau')-exp(0.5*(k-1)*xmax + 0.25*((k-1)^2)*tau');
% Set up matrices for Crank Nicholson Scheme
A = sparse(j-1,j-1);
B = sparse(j-1,j-1);
for i = 1:j-1
    A(i,i) = 1+lambda; % Matrix for LHS solution vector U(t+1) time step t+1
    B(i,i) = 1-lambda; % Matrix for RHS solution vector U(t) at time step t
    if i+1<=j-1
        A(i,i+1) = -lambda/2;
        A(i+1,i) = -lambda/2;
        B(i,i+1) = lambda/2;
        B(i+1,i) = lambda/2;
    end
end

U = zeros(n+1,j+1); % Matrix which stores the heat eq solution
U(:,1) = 0; U(:,end) = (bndryright(tau))';% Set first and last column to boundary conditions
U(1,:) = initcond(x); % Set first row to initial condition


bndryvec = zeros(j-1,1); % initialize boundary vector
% size(bndryvec)
for t = 2:n+1
    
        bndryvec(j-1,1) = (lambda/2).*(bndryright(tau(t-1)) + bndryright(tau(t))); % Make boundary vector at each step

        c = B*(U(t-1,2:end-1))' + bndryvec; % c = B*U(t) + b
        U(t,2:end-1) = A\c; % Solve linear system for A*U(t+1) = c
        
end

  

% Back Transformations
S = strike*exp(x); % Stock price corresponding to x
time = T-(2/sig^2)*tau; % Time corresponding to Tau
V = zeros(n+1,j+1); % Option Price corresponding to solution of heat eq U
for jj = 1:length(tau)
    V(jj,:)=strike*(U(jj,:)).*exp(alpha*x + beta*tau(jj));
   
end


