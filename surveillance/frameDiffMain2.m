function [diffFrames,ddiffFrames] = frameDiffMain2(filename,abandonTime,thFrames,thBound)

% setting up
dirPrefix = './media/';
vinfo = VideoReader([dirPrefix filename]);
iFrames = 1 : floor(vinfo.FrameRate) : floor(vinfo.FrameRate)*vinfo.Duration;
nFrames = length(iFrames);
frames = zeros(vinfo.Height, vinfo.Width, nFrames);
diffFrames = zeros(size(frames,1),size(frames,2),size(frames,3)-1);
diffFrames_pr = zeros(size(frames,1),size(frames,2),size(frames,3)-abandonTime);
ddiffFrames = zeros(size(frames,1),size(frames,2),size(frames,3)-abandonTime);
deleteFigures = [];
alertTimes = [];

diffName = ['diff_' filename '.tif'];
ddiffName = ['ddiff_' filename '.tif'];

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

for i=2:nFrames
    j=i-1;
    str = fprintf('Processing frames... %d / %d', j, nFrames-1);
    diffFrames(:,:,i-1) = abs(bgFrame-frames(:,:,i))>thFrames;
    
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
            else % Trigger for alert
                newBounds = [newBounds bounds(l)];
                deleteFigures = [deleteFigures; struct('fig',ddiffFrame(top:bottom,left:right), 'top',top, 'left',left)];
                alertTimes = [alertTimes,i];
            end
        end
        
        ddiffFrames(:,:,k) = drawBoundOnImage(ddiffFrame,newBounds,0);
    end
    fprintf(repmat('\b', 1, str));
end
fprintf('Processing frames... done.\n');


str = fprintf('Saving diffFrames...');
imwrite(diffFrames(:,:,1),[dirPrefix diffName]);
for i=2:size(diffFrames,3)
    imwrite(diffFrames(:,:,i),[dirPrefix diffName],'WriteMode','append');
end
fprintf(' done.\n');

str = fprintf('Saving ddiffFrames...');
imwrite(ddiffFrames(:,:,1),[dirPrefix ddiffName]);
for i=2:size(ddiffFrames,3)
    imwrite(ddiffFrames(:,:,i),[dirPrefix ddiffName],'WriteMode','append');
end
fprintf(' done.\n');

alertTimes

end