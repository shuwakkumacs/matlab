function trimVideo(videoName, centerTime, margin)

% setting up
dirPrefix = './my_video/';
folderName = [dirPrefix videoName];
vinfo = VideoReader([folderName  '.mov']);
iFrames = 1 : floor(vinfo.FrameRate) : floor(vinfo.FrameRate)*vinfo.Duration;
nFrames = length(iFrames);

v = VideoWriter(sprintf('%s/tr_%d_%d.mp4',folderName,centerTime,margin),'MPEG-4');
v.FrameRate = 15;
open(v);

% Read Frames
frameSpan = iFrames(centerTime+1-margin):2:iFrames(centerTime+1+margin);
%A = zeros(vinfo.Height,vinfo.Width,3,length(frameSpan));
j=1;
for i=frameSpan
    str = fprintf('Extracting frames... %d / %d', j, length(frameSpan));
    frame = read(vinfo,i);
    %A(:,:,:,j)=frame;
    j=j+1;
    fprintf(repmat('\b', 1, str));
    writeVideo(v,frame);
end
fprintf('Extracting frames... done.\n');