function createAnimation(videoName, centerTime, margin)

setenv('DYLD_LIBRARY_PATH',['/usr/local/lib/:' getenv('DYLD_LIBRARY_PATH')]);

tmpFolder = ['my_video/' videoName '/tmp/'];
mkdir(tmpFolder);
files = '';
for i=centerTime-margin:centerTime+margin
    files = [files sprintf('my_video/%s/%02d.jpg ',videoName,i)];
end
cmdCp = ['cp ' files tmpFolder];
cmdConv = ['convert -delay 50 -loop 0 ' tmpFolder '*.jpg my_video/' videoName '/ani_' int2str(centerTime) '_' int2str(margin) '.gif'];
unix(cmdCp);
unix(cmdConv)
rmdir(tmpFolder,'s');