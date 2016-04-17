function img = drawBoundOnImage(img,bounds,border)

for i=1:numel(bounds)
    top = bounds(i).top;
    bottom = bounds(i).bottom;
    left = bounds(i).left;
    right = bounds(i).right;
    
    img(top:bottom,[left:left+border right-border:right]) = 1;
    img([top:top+border bottom-border:bottom],left:right) = 1;
end

end