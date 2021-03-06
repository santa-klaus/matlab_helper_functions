%% calculate_volt_strength_ind
% by Paul Imgart, last change
% Function to calculate RMS over a sliding window from variable time step 
% data, e.g. simulation data
% 
% The RMS for time step t1 is calculated considering all samples within
% t1-window_length<t<=t1.
% This is done for all t1>t_init+window_length, where t_init is the first
% time stamp of the measurements.
%
% Inputs:
% mode: 'timeseries' (expects a timeseries object of data)
%   or 'simple' (takes a timestamp and a measurements vector)
% window_length: Step width over which the RMS should be computed
% For 'timeseries' mode:
%   sig: Timeseries with the signal and timesteps
% For 'simple' mode:
%   t_stamp: Time stamps in s
%   sig: Signal
%
%
% Outputs:
% Depending on the number of queried outputs. If one output is queried the
% data is supplied as timeseries object, if two outputs are queried data is
% supplied as time stamp and rms data vector.
%
%
% Include downsampling function?

function [varargout] = calculate_RMS(varargin)

mode = varargin{1};

if strcmp(mode,'timeseries')
    for k=2:length(varargin)
        if k==2
            window_length = varargin{k};
            
        elseif k==3
            sig = varargin{k};
            
            sig_data = sig.Data;
            t_stamp = sig.Time;
            
        else
            error('Unexpected amount of inputs in calculate_RMS. Wrong mode selected?')
            
        end
        
    end
    
elseif strcmp(mode,'simple')
    for k=2:length(varargin)
        
        if k==2            
            window_length = varargin{k};
            
        elseif k==3
            t_stamp = varargin{k};
            
        elseif k==4            
            sig_data = varargin{k};
            
        else           
            error('Unexpected amount of inputs in calculate_RMS. Wrong mode selected?')
            
        end
        
    end
    
else    
    error('Unknown mode in calculate_RMS')
    
end

% Find last time stamp that is smaller or equal to the window
% length+initial time stamp
start = find(t_stamp>=(window_length+t_stamp(1)),1)-1;
% Initialize the data vector in the correct length
rms_data = zeros(length(sig_data)-start,1);

for k=1:length(rms_data)  
    % Find first time stamp that is less(!) than window_length away from the
    % current
    fi = find(t_stamp-(t_stamp(k+start)-window_length)>=1e-9,1);
    
    % compute RMS
    rms_data(k) = sqrt(1/(k+start-fi+1)*sum(sig_data(fi:k+start).^2));
    disp(k+start-fi+1)


end

% Compose outputs
if nargout==1
    % Create timeseries
    rms_sig = timeseries(rms_data,t_stamp(start+1:end));        
    
    varargout = {rms_sig};
    
elseif nargout==2
    varargout = {t_stamp(start+1:end);rms_data};
    
else
    error('Too many outputs requested from calculate_RMS')
    
end

end
    