%% export_data_table
% Export data as a LaTeX/pgfplots readable tabseparated table
% by Paul Imgart, last change: 21.03.2019
%
% Function call:
% export_data_table(filename,header,varargin)
%
% Inputs:
% - filename:
%       Full path to file which will be created to save the data. '.dat' is
%       added as file extension automatically.
% - header:
%       Cell array, each cell containing the header for one of the
%       variables. Can be empty. If a variable has more than one column,
%       more than one header should be supplied.
% - varargin:
%       Data to be exported. All variables should have the same length and
%       be supplied separated as a comma

function export_data_table(filename,header,varargin)

%% Create file
file = fopen([filename '.dat'],'w');

%% Write header, if specified
if ~isempty(header)
    for k=1:length(header)-1
        fprintf(file,'%s\t',header{k});
    end

    fprintf(file,'%s\n',header{k+1});
    
end

%% Write variables
% For each row
for k=1:size(varargin{1},1)
    % Write all but the last variable
    for l=1:length(varargin)-1
        % Add each column of the current variable
        for m=1:size(varargin{l},2)
            fprintf(file,'%g\t',varargin{l}(k,m));
        end
    end
    % Write the last variable (extra to replace \t by \n)
    % Write all but the last column of the last variable
    for m=1:size(varargin{end},2)-1
        fprintf(file,'%g\t',varargin{end}(k,m));
    end
    % Write last column of last variable
    fprintf(file,'%g\n',varargin{end}(k,end));

end

fclose(file);