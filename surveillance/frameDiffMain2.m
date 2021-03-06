function [diffFrames,ddiffFrames] = frameDiffMain2(filename,abandonTime,thGraySc,thBound,ext)

if nargin==4
    ext='mov';
end

% setting up
dirPrefix = './my_video/';
vinfo = VideoReader([dirPrefix filename '.' ext]);
iFrames = 1 : floor(vinfo.FrameRate) : floor(vinfo.FrameRate)*vinfo.Duration;
nFrames = length(iFrames);
frames = zeros(vinfo.Height, vinfo.Width, nFrames);
diffFrames = zeros(size(frames,1),size(frames,2),size(frames,3)-1);
ddiffFrames = zeros(size(frames,1),size(frames,2),size(frames,3)-abandonTime);
deleteFigures = [];

diffName = ['diff_' filename];
ddiffName = ['ddiff_' filename];

% Read Frames
i=1;
for iFrame = iFrames
    str = fprintf('Reading frames... %d / %d', i, nFrames);
    frame = read(vinfo,iFrame);
    frames(:,:,i) = rgb2gray(frame);
    i=i+1;
    fprintf(repmat('\b', 1, str));
end
fprintf('Reading frames... done.\n');
bgFrame = frames(:,:,1);
alertTimes = zeros(1,nFrames);

for i=2:nFrames
    j=i-1;
    str = fprintf('Processing frames... %d / %d', j, nFrames-1);
    diffFrames(:,:,i-1) = abs(bgFrame-frames(:,:,i))>thGraySc;
    
    % Erosion & Dilation
    diffFrame = diffFrames(:,:,j);
    SE = strel('square', 3);
    diffFrame = imerode(diffFrame,SE);
    diffFrame = imdilate(diffFrame,SE);
    diffFrames(:,:,j) = diffFrame;

    if j >= abandonTime
        k = i-abandonTime;
        % Static Foreground Detection
        ddiffFrame = diffFrames(:,:,j);
        for l=1:abandonTime-1
            ddiffFrame = ddiffFrame & diffFrames(:,:,j-l);
        end
        
        % sth to do when abandoned object found
%         for l=1:numel(deleteFigures)
%             fig = deleteFigures(l);
%             vEdge = [fig.top:fig.top+size(fig.fig,1)-1];
%             hEdge = [fig.left:fig.left+size(fig.fig,2)-1];
%             orgFig = ddiffFrame(vEdge,hEdge);
%             ddiffFrame(vEdge,hEdge) = orgFig&~fig.fig;
%         end
        [cnt,L] = ccAnalysis(ddiffFrame);
        bounds = detectBoundsByCC(cnt,L);
        newBounds = [];
        for l=1:numel(bounds)
            top = bounds(l).top;
            bottom = bounds(l).bottom;
            left = bounds(l).left;
            right = bounds(l).right;
            if (bottom-top)*(right-left) < thBound
                ddiffFrame(top:bottom,left:right)=0;
            elseif bounds(l).top~=10000 % Trigger for alert
                newBounds = [newBounds bounds(l)];
                deleteFigures = [deleteFigures; struct('fig',ddiffFrame(top:bottom,left:right), 'top',top, 'left',left)];
                alertTimes(i) = 1;
            end
        end
        
        ddiffFrames(:,:,k) = drawBoundOnImage(ddiffFrame,newBounds,0);
    end
    fprintf(repmat('\b', 1, str));
end
fprintf('Processing frames... done.\n');


fprintf('Saving diffFrames...');
dTifName = [dirPrefix diffName '_' int2str(abandonTime) '_' int2str(thGraySc) '_' int2str(thBound) '.tif'];
imwrite(diffFrames(:,:,1),dTifName);
for i=2:size(diffFrames,3)
    imwrite(diffFrames(:,:,i),dTifName,'WriteMode','append');
end
fprintf(' done.\n');

fprintf('Saving ddiffFrames...');
ddTifName = [dirPrefix ddiffName '_' int2str(abandonTime) '_' int2str(thGraySc) '_' int2str(thBound) '.tif'];
imwrite(ddiffFrames(:,:,1),ddTifName);
for i=2:size(ddiffFrames,3)
    imwrite(ddiffFrames(:,:,i),ddTifName,'WriteMode','append');
end
fprintf(' done.\n');

alertTimes

end