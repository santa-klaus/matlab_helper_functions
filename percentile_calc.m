%% plot_percentiles
% by Paul Imgart, last change 20.03.2019
% Function to discretize data in different bins and calculate percentiles 
%  according to nearest rank method (i.e. no interpolation is used, only 
%  provided data points are used).
% x-th percentile means: No more than x percent of the data is strictly 
%  less than the value and at least P percent of the data is less than or 
%  equal to that value.
%
% Input parameter:
%   x_data: Vector with the x data points
%   y_data: Vector with the corresponding y data points
%   bin_num: Number of bins to separate the x data uniformly
%   percentiles: Row vector containing the percentiles, e.g. [5 50 95]
% Optional:
%   'thresholds': Ignore data above and/or below these x-values. 
%       Deactivate specific threshold by NaN, e.g. [0.1 NaN] ignores all 
%       values below 0.1 but does not have an upper threshold.
%   'min_count': Issue a warning if bins have less than the specified
%       number of datapoints.
%
%
% Output parameter:
%   bin_centers: Vector containing the x-values around which the data bins
%       are centered
%   percentiles_data: Matrix containing for each of the queried percentiles
%       the y values of each bin. Dimension [bin_num x length(percentiles)]
%   bin_counts: Number of data points per bin.
%   
%
%
% % Example function call:
%   [bin_centers, percentiles_data, bin_counts] = percentile_calc(x_data,...
%       y_data, 100,[5 50 95], 'thresholds', [1e3 5e6], 'min_count', 10)
% 
% Example plot for 3 percentiles: 
%   plot(bin_centers,percentiles_data(:,1),bin_centers,percentiles_data(:,2),...
%       bin_centers,percentiles_data(:,3))

function [bin_centers, percentiles_data, bin_counts] = ...
    percentile_calc(x_data, y_data, bin_num, percentiles, varargin)

thresholds = NaN(1,2); % will be overwritten if thresholds are specified
min_count = NaN; % will be overwritten if a minimum number of data points in each bin is specified

%% Parameter parsing
for k=1:2:length(varargin)
    
    if strcmpi(varargin{k},'thresholds')
        
        thresholds = varargin{k+1};
        
    elseif strcmpi(varargin{k},'min_count')
        
        min_count = varargin{k+1};
        
    end
    
end

%% Bin generation
% Sort data according to x values
[x_data_sorted,x_sort_ind] = sort(x_data);
y_data_sorted = y_data(x_sort_ind);

% Cut off lower threshold
cutoff_ind = [1 length(x_data)];
if ~isnan(thresholds(1))
   
    cutoff_ind(1) = find(x_data_sorted>=thresholds(1),1);
    
end
% Cut off upper threshold
if ~isnan(thresholds(2))
    
    cutoff_ind(2) = find(x_data_sorted<=thresholds(2),1,'last');
    
end
x_data_sorted = x_data_sorted(cutoff_ind(1):cutoff_ind(2));

% Bin generation (don't use histcounts' bin generation because of wide
% margins added at the borders)
bin_edges = x_data_sorted(1):...
    (x_data_sorted(end)-x_data_sorted(1))/bin_num:x_data_sorted(end);

% Sort data in bins
[bin_counts,~,bin_ind] = histcounts(x_data_sorted,bin_edges);

%% Issue warnings for underfilled bins
if ~isnan(min_count)
    
    low_bins = find(bin_counts<min_count);
    
    for k=low_bins
        
        warning(['The bin between ' num2str(bin_edges(k)) ' and ' num2str(bin_edges(k+1)) ...
            ' contains only ' num2str(bin_counts(k)) ' datapoints.'])
        
    end
    
end

%% Compute percentiles per bin
percentiles_data = nan(bin_num,length(percentiles));

% sort y_data into bins
y_data_bin = cell(bin_num,1);
for k=1:bin_num
   
    y_data_bin(k) = {y_data_sorted(bin_ind==k)};
    
end

% Sort y data in the bin
y_data_bin = cellfun(@sort,y_data_bin,'UniformOutput',false);


% Compute percentile indices
perc_ind = ceil(repmat(bin_counts',1,length(percentiles)).*percentiles/100);

for k = 1:bin_num
    
    if bin_counts(k)==0
        % If no datapoints are in the current bin fill with NaN
        percentiles_data(k,:) = NaN(1,length(percentiles));
        
    else
    
    % Select percentile data
    percentiles_data(k,:) = y_data_bin{k}(perc_ind(k,:));
    
    end
    
end

% Compute centers of the bins
bin_centers = bin_edges(1:end-1) + diff(bin_edges)/2;
