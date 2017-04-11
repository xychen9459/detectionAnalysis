function [rec, objcount] = PASreadAllRecords(recname, settype)

% [rec, objcount] = PASreadAllRecords(recname, settype)
%
% read annotations in PASCAL dataset
%
% rec: a struct array recording annotations, numel(rec) = numel(images)
% objcount: a matrix recording amount of objects for each class, 
%           dim = {numel(images) * numel(classes)}

VOCinit;

if ~exist('settype', 'var') || isempty(settype)
  settype = 'main';
end

if strcmp(settype, 'main')
  % /path/to/VOCdevkit/VOC2007/ImageSets/Main/<recname>.txt
  ids = textread(sprintf(VOCopts.imgsetpath, recname), '%s');
  %fid = fopen(sprintf(VOCopts.imgsetpath,recname));
elseif strcmp(settype, 'seg')
  % /path/to/VOCdevkit/VOC2007/ImageSets/Segmentation/<recname>.txt
  ids = textread(sprintf(VOCopts.seg.imgsetpath, recname), '%s');
  %fid = fopen(sprintf(VOCopts.seg.imgsetpath,recname));
end
% C=textscan(fid,'%s %d');
% ids = C{1};
% gt = C{2};
% fclose(fid);

objcount = zeros(numel(ids), numel(VOCopts.classes), 'uint8');
for i=1:numel(ids)    
    % read annotation
    rec(i) =PASreadrecord(sprintf(VOCopts.annopath,ids{i}));
    if i == 1
        rec(numel(ids)) = rec(i);
    end
    
    for k = 1:numel(rec(i).objects)
        c = strcmp(rec(i).objects(k).class, VOCopts.classes);
        objcount(i, c) = objcount(i, c) + 1;
    end
    
end
