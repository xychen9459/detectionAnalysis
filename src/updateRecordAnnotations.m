function rec = updateRecordAnnotations(rec, annotationpath, cls)

% rec = updateRecordAnnotations(rec, annotationpath, cls)

[data, labels] = readGtData(sprintf(annotationpath, cls));

anni = 0;
for r = 1:numel(rec)	% for each image
  for o = 1:numel(rec(r).objects)   % for each object
    if strcmp(rec(r).objects(o).class, cls)
      if ~rec(r).objects(o).difficult   % don't use difficult gt
        anni = anni + 1;
        
        bbox = rec(r).objects(o).bbox;
        if (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1)~=data(anni, end-1)
          % bbox area size in VOC annotation and 'data' are not equal
          keyboard;
        end
        
        occ = data(anni, 3);
        if strcmp(cls, 'diningtable')
          parts = data(anni, 4:5);  % parts \in {p1, p2}
          view = data(anni, 6:7);   % parts \in {v1, v2}
        else
          parts = data(anni, 4:end-7);    % parts \in {p1, p2, p3, p4(, p5, p6)}
          view = data(anni, end-6:end-2); % parts \in {v1, v2, v3, v4, v5}
        end
                
        rec(r).objects(o).details = getDetailStructure(cls, occ, view, parts, bbox);

      end
    end
  end
end

function d = getDetailStructure(cls, occ, view, parts, bb)

d = struct('occ_level', [], 'side_visible', [], 'part_visible', [], ...
  'bbox_area', [], 'bbox_aspectratio', []);

% occlusion level
d.occ_level = occ+1; % = {1: none, 2:low, 3:medium, 4:high}

% viewpoints(side) visibility
if strcmp(cls, 'diningtable')
  d.side_visible = struct('side', view(1), 'top', view(2));
elseif strcmp(cls, 'bicycle')
  d.side_visible = struct('bottom', view(1), 'front', view(2), ...
    'rear', view(3), 'top', view(4), 'side', view(5));
else  
  d.side_visible = struct('bottom', view(1), 'front', view(2), ...
    'rear', view(3), 'side', view(4), 'top', view(5));
end

%{
%   if strcmp(cls, 'aeroplane') || strcmp(cls, 'chair') || strcmp(cls, 'boat')
%   d.side_visible = struct('bottom', view(1), 'front', view(2), ...
%     'top', view(3), 'side', view(4), 'rear', view(5));
% elseif strcmp(cls, 'cat') || strcmp(cls, 'bird') || strcmp(cls, 'bicycle')
%   d.side_visible = struct('bottom', view(1), 'front', view(2), ...
%     'rear', view(3), 'side', view(4), 'top', view(5));
% end
%}

% bbox geometry info
d.bbox_area = (bb(3)-bb(1)+1)*(bb(4)-bb(2)+1);
d.bbox_aspectratio = (bb(3)-bb(1)+1)./(bb(4)-bb(2)+1);

% part visibility
switch cls
  case 'aeroplane'
    pname = {'body', 'head', 'tail', 'wing'};
  case 'bicycle'
    pname = {'body', 'handlebars', 'seat', 'wheel'};
  case 'boat'
    pname = {'body', 'cabin', 'mast', 'paddle', 'sail', 'window'};
  case 'bird'
    pname = {'body', 'face', 'beak', 'leg', 'tail', 'wing'};
  case 'cat'
    pname = {'body', 'ear', 'face', 'leg', 'tail'};
  case 'chair'
    pname = {'backrest', 'cushion', 'handrest', 'leg'};
  case 'diningtable'
    pname = {'tableleg', 'tabletop'};
  otherwise 
    error('unknown class');
end
for k = 1:numel(pname)
  d.part_visible.(pname{k}) = parts(k);
end

% verify part visible info
np = 0;   % np: amount of visible parts
partnames = fieldnames(d.part_visible);
for k = 1:numel(partnames)
  np = np+d.part_visible.(partnames{k});
end
if np~=sum(parts)
  error('part missassignment')
end
