function [bounds,map] = detectBoundsByCC(ccCnt,ccMap)

bounds=[];
for i=1:ccCnt
    bounds = [bounds; struct('top',10000, 'left',10000, 'bottom',-1, 'right',-1, ...
        'time_start','', 'time_end','', 'type','', 'content','')];
end

% initial bounding box
for i=1:size(ccMap,1)
    for j=1:size(ccMap,2)
        idx = ccMap(i,j);
        if idx <= 0
            continue;
        end
        
        if bounds(idx).top > i
            bounds(idx).top = i;
        end
        if bounds(idx).left > j
            bounds(idx).left = j;
        end
        if bounds(idx).bottom < i
            bounds(idx).bottom = i;
        end
        if bounds(idx).right < j
            bounds(idx).right = j;
        end
        
    end
end

%map = showBound(bounds,size(ccMap,1),size(ccMap,2));

end