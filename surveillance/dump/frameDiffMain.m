function [diffFrames,ddiffFrames] = frameDiffMain(filename,abandonTime,refreshRate,threshold)

vinfo = VideoReader(filename);
iFrames = 1 : floor(vinfo.FrameRate) : floor(vinfo.FrameRate)*vinfo.Duration;
nFrames = length(iFrames);

frames = zeros(vinfo.Height, vinfo.Width, nFrames);




i=1;
for iFrame = iFrames
    str = fprintf('Reading frames... %d / %d', i, nFrames);
    frame = read(vinfo,iFrame);
    frames(:,:,i) = rgb2gray(frame);
    i=i+1;
    fprintf(repmat('\b', 1, str));
end
fprintf('Reading frames... finished.\n');




diffFrames = mat2gray(frameDiff(frames,refreshRate,threshold));
for i=1:size(diffFrames,3)
    str = fprintf('Processing Erosion&Dilation... %d / %d', i, size(diffFrames,3));
    diffFrame = diffFrames(:,:,i);
    SE = strel('square', 3);
    diffFrame = imerode(diffFrame,SE);
    diffFrame = imdilate(diffFrame,SE);
    diffFrames(:,:,i) = diffFrame;
    fprintf(repmat('\b', 1, str));
end
fprintf('Processing Erosion&Dilation... finished.\n');

ddiffFrames = zeros(size(frames,1),size(frames,2),size(frames,3)-abandonTime);
% for i=abandonTime:size(diffFrames,3)
%     str = fprintf('Detecting static foregrounds... %d / %d', i, size(diffFrames,3));
%     ddiffFrames(:,:,i-(abandonTime-1)) = diffFrames(:,:,i-(abandonTime-1));
%     for j=abandonTime-3:-1:0
%         ddiffFrames(:,:,i-(abandonTime-1)) = ddiffFrames(:,:,i-(abandonTime-1))&diffFrames(:,:,i-j);
%     end
%     fprintf(repmat('\b', 1, str));
% end
for i = 1 : size(ddiffFrames,3)
    str = fprintf('Detecting static foregrounds... %d / %d', i, size(ddiffFrames,3));
    ddiffFrame = diffFrames(:,:,i);
    for j=1:abandonTime-1
        ddiffFrame = ddiffFrame & diffFrames(:,:,i+j);
    end
    ddiffFrames(:,:,i) = ddiffFrame;
    fprintf(repmat('\b', 1, str));
end
fprintf('Detecting static foregrounds... finished.\n');



diffName = ['diff_' filename '.tif'];
ddiffName = ['ddiff_' filename '.tif'];

fprintf('Saving diffFrames...\n');
imwrite(diffFrames(:,:,1),diffName);
for i=2:size(diffFrames,3)
    imwrite(diffFrames(:,:,i),diffName,'WriteMode','append');
end

fprintf('Saving ddiffFrames...\n');
imwrite(ddiffFrames(:,:,1),ddiffName);
for i=2:size(ddiffFrames,3)
    imwrite(ddiffFrames(:,:,i),ddiffName,'WriteMode','append');
end




end