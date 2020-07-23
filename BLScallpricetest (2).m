
function [C] = BLScallprice(S,r,sig,strike,T)
C = zeros(length(S),1); % Initialize vector to store the option price.

for ii = 1:length(S)
d1 = (log(S(ii)./strike) + (r + 0.5*sig^2)*T)/(sig*sqrt(T));
d2 = d1 - sig*sqrt(T);
N1 = 0.5*(1+erf(d1./sqrt(2))); % CDF Normal Distribution
N2 = 0.5*(1+erf(d2./sqrt(2)));
C(ii,1) = S(ii).*N1-strike*exp(-r*T).*N2; % Final price using Black Scholes
end