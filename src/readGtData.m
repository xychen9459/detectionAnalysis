function [data, labels] = readGtData(name)

% [data, labels] = readGtData(name)

fid = fopen(name);

% read the first line to extract item label
line = fgetl(fid);
labels = strtokAll(line);

% create data matrix
data = zeros(10E6, numel(labels));  % max number of info is 10E6

n = 0;
while true
    line = fgetl(fid);
    if ~ischar(line), break, end;      % reach EOF
    if isempty(line), continue; end;
    n = n +1;
    data(n, :) = str2num(line);
end
data = data(1:n, :);
fclose(fid);

%--------------------------------------------------------------------------
% Extract info in first line of text file into strs. 
% Each element in strs represents a data item.
%--------------------------------------------------------------------------
function strs = strtokAll(str)
strs = {};
rest = str;
while true
    [first, rest] = strtok(rest);   % extract each item label
    strs{end+1} = first;
    if isempty(rest)
        break;
    end
end

