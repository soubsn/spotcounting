function [pos2,spotdata]=spotdetect_gauss(im,radius,LMaxFinder,S,thresh,l2,JJ,vpix)
pos2=[];
spotdata=[];
%figure; imshow(im,[])
r=radius+1;
r1=floor(r/2);
g1=1/(1+sqrt(2))*(radius);
g2=sqrt(2)*g1;
xx=im2double(im);
xx1 = imgaussfilt(xx,g1);
xx2 = imgaussfilt(xx,g2);
xx3=xx1-xx2;
m1=xx3>0;
m2=xx3(m1);
med=mean(m2);
pos = LMaxFinder(xx3,thresh);
for l=1:height(pos)
    if pos(l,2)<3||pos(l,1)<3||pos(l,2)>(height(im)-3)||pos(l,1)>(width(im)-3)
        continue
    elseif ismember(pos(l,1:2),vpix,'rows') == 0
        continue
    end
    t=xx((pos(l,2)-r1):(pos(l,2)+r1),(pos(l,1)-r1):(pos(l,1)+r1));
    [res]=GaussianSurf(t);
    p=[res.x0-3, res.y0-3];
    pos(l,1:2)=pos(l,1:2)+p;
    Iin=sum(t,'all');
    Iout=med*numel(t);
    s = std2(t);
    snr=(Iin-Iout)/s;
    pos(l,3)=snr;
    diffe=res.a/res.b;
    add=sum(t,'all');
    if S < snr
        pos2=vertcat(pos2,pos(l,:));
        spotd=[pos(l,1) pos(l,2) res.a res.b diffe res.sigma res.sse res.r2 l l2 JJ add];
        spotdata=vertcat(spotdata,spotd);
    end
end
% figure; imshow(xx3,[])
% hold on
%plot(pos2(:,1),pos2(:,2),'ro','MarkerSize',30)
end