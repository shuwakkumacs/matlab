function extractShots(videoName,ext)

if nargin==1
    ext = 'mov';
end

% setting up
dirPrefix = './my_video/';
folderName = [dirPrefix videoName];
if ~exist(folderName)
    mkdir(folderName);
else
    fprint('!!!folder already exists!!!');
end
vinfo = VideoReader([folderName  '.' ext]);
iFrames = 1 : floor(vinfo.FrameRate) : floor(vinfo.FrameRate)*vinfo.Duration;
nFrames = length(iFrames);

% Read Frames
i=1;
for iFrame = iFrames
    str = fprintf('Extracting frames... %d / %d', i, nFrames);
    frame = read(vinfo,iFrame);
    writeName = sprintf('%s/%02d.jpg', folderName, i-1);
    imwrite(frame, writeName);
    i=i+1;
    fprintf(repmat('\b', 1, str));
end
fprintf('Extracting frames... done.\n');