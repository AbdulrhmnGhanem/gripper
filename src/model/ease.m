% easeInOutQuint equations
% https://easings.net/#easeInOutQuint


t = 0:0.01:0.5;  % this is used to simulate the ticks, 
x = t;
currentPosition = 70;
finalPosition = 120
change =  finalPosition - currentPosition;
duration = 0.5;


t = t / duration * 2;
y = zeros (size (t));
% instead of masking, e,g, t(t < 1), in vhdl you will use if condition
y(t < 1) = change / 2 .* t(t < 1) .^ 5 + currentPosition;
y(t >= 1) = change /2 .* ((t(t >= 1) - 2) .^ 5 + 2) + currentPosition;
plot(x, y)