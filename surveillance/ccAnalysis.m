% 文字は1,背景は0とする
function [cnt, L] = ccAnalysis(I)
L = zeros(size(I));
I(1,:) = 0; I(size(I,1),:) = 0;
I(:,1) = 0; I(:,size(I,2)) = 0;
C = 1;
for i=2:size(I,1)-1
    for j=2:size(I,2)-1
        if I(i,j)==1
            if I(i-1,j)==0 & L(i,j)==0% & L(i-1,j)~=-1
                % 外周探索
                [I,L] = traceContour(I,L,'external',[i,j],C);
                if L(i,j)~=-2  % isolated pixelだったときにはCをインクリメントしない
                    C = C+1;
                end
            elseif I(i+1,j)==0 & L(i+1,j)~=-1
                % 内周探索
                if L(i,j)>0
                    [I,L] = traceContour(I,L,'internal',[i,j],L(i,j));
                else % L=0
                    [I,L] = traceContour(I,L,'internal',[i,j],L(i,j-1));
                end
            elseif L(i,j-1)>0 & L(i,j)==0
                % 左隣のラベルをコピー
                L(i,j) = L(i,j-1);
            end
        end
    end
end
cnt = C-1;
end

function [I,L] = traceContour(I,L,type,sp,C)
di = [ 1  1  1  0 -1 -1 -1  0 ];
dj = [ 1  0 -1 -1 -1  0  1  1 ];
switch type
    case 'external'
        idx=7;
    case 'internal'
        idx=3;
end
np = sp;

while C>0
    %fprintf('%d,%d\n', np(1), np(2));
    flg=1;
    L(np(1),np(2))=C;
    white_cnt=0;
    for i=1:8
        ni = np(1)+di(idx);
        nj = np(2)+dj(idx);
        %fprintf('(%d,%d)\n', ni, nj);
        if isequal(np,sp) & L(ni,nj)>0
            continue;
        end
        if I(ni,nj)==1 % もし隣接しているピクセルが文字なら
            np=[ni nj];
            idx = mymod(idx+6,8);
            flg=0;
            break;
        else
            L(ni,nj) = -1;
            white_cnt = white_cnt + 1;
        end
        idx = mymod(idx+1,8);
    end
    if isequal(np,sp) & flg==1
        if white_cnt==8  % isolated pixelだったときはcomponentとして数えない
            L(sp(1),sp(2)) = -2;
        end
        break;
    end
    start_flg=0;
end
end

% Local function
% 1始まりのインデックス巡回を考えるのがめんどくさかったので
function y = mymod(x,m)
if mod(x,m)==0
    y=m;
else
    y=mod(x,m);
end
end