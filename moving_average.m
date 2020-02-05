%% Moving average
% by Paul Imgart, last change 30.01.2020
% Compute average of w samples of signal x and place it at position ceil(w/2)
% x: measurements, should be evenly spaced
% w: window length for the moving average in number of samples, should be uneven


function y = moving_average(x, w)

if mod(w,2)~=1
    error('Choose an uneven windowlength for the moving average!')
else
   k = ones(1, w) / w;
   y = conv(x, k, 'same');
end