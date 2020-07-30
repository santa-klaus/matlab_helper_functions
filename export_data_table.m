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
%       columns. Can be empty. If a variable has more than one column,
%       more than one header should be supplied.
% - varargin:
%       Data to be exported. All variables should have the same number of
%       rows and be supplied separated by a comma. Variables can have more
%       than one column. Cell arrays can be used as variables, but should
%       not contain anything else than single-element entries for anything
%       else than strings. E.g. {'a' 'bcd';'cde' 'f'} would be a valid
%       input, {3;[3 4]} not.

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
    for l=1:length(varargin)
        % Add each column of the current variable
        for m=1:size(varargin{l},2)
            if iscell(varargin{l}(k,m))
                curr_entry = varargin{l}{k,m};
            else
                curr_entry = varargin{l}(k,m);
            end
            
            % Add a linebreak for the last column, a tab otherwise
            if l==length(varargin) && m==size(varargin{l},2)
                sep='\n';
            else
                sep='\t';
            end
            
            if ischar(curr_entry) || isstring(curr_entry)
                fprintf(file,['%s' sep],curr_entry);
            else
                fprintf(file,['%g' sep],curr_entry);
            end
        end
    end    
end

fclose(file);