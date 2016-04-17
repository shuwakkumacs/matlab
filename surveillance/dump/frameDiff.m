function diffFrames = frameDiff(frames,refreshRate,threshold)

numFrames = size(frames,3);
bgFrame = frames(:,:,1);
diffFrames = zeros(size(frames,1),size(frames,2),size(frames,3)-1);

for i=2:numFrames
    diffFrames(:,:,i-1) = (abs(bgFrame-frames(:,:,i))>threshold);
    if mod((i),refreshRate)==1 & refreshRate~=0
        bgFrame = frames(:,:,i);
    end
end

end