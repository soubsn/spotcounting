function [ObjCell,Spotdata]=ImagePrinter(ObjCell,C,LMaxFinder,S,thresh,JJ)
Spotdata=[];
times = ceil(height(ObjCell)/10);
ha = tight_subplot(times,10,[.001 .001],[.001 .001],[.001 .001]);
for x= 1:height(ObjCell)
    label=string(x);
    im=imcrop(C,ObjCell{x, 2}{1, 6});
    seg=ObjCell{x, 1};
    seg(seg==0)=ObjCell{x, 2}{1, 5};
    ObjCell{x,7}=sum(ObjCell{x, 2}{:, 8});
    vpix=ObjCell{x, 2}{1, 7};
    [pos,spotdata]=spotdetect_gauss(im,3,LMaxFinder,S,thresh,x,JJ,vpix);
    [J,~]= size(pos);
    pos2=[];
    if isempty(pos) == 0
        pos2(:,1) = pos(:,1)+ ObjCell{x, 2}{1, 6}(1,1);
        pos2(:,2) = pos(:,2)+ ObjCell{x, 2}{1, 6}(1,2);
        spotdata(:,1)=spotdata(:,1)+ ObjCell{x, 2}{1, 6}(1,1);
        spotdata(:,2)=spotdata(:,2)+ ObjCell{x, 2}{1, 6}(1,2);
        ObjCell{x,3}= J;
        ObjCell{x,5}= pos2;
        ObjCell{x,4}= pos;
        ObjCell{x,6}= spotdata(:,12);
        ObjCell{x,7}= sum(spotdata(:,12));
        ObjCell{x,8}= spotdata;
    else
        pos2=[];
        ObjCell{x,3}= 0;
        ObjCell{x,4}= 0;
        ObjCell{x,5}= 0;
        ObjCell{x,6}= 0;
        ObjCell{x,7}= 0;
        ObjCell{x,8}= 0;
    end
    axes(ha(x));
    imshow(seg,[]);
    hold all %To show each individual cell and its spotcount\
    if isempty(pos)
        text(3,3,label,'Color','r')
        continue
    end
    plot(pos(:,1),pos(:,2),'ro','MarkerSize',5) %To show each individual cell and its spotcount
    text(3,3,label,'Color','r')
    hold off %To show each individual cell and its spotcount
    clear pos J pos2
    Spotdata=vertcat(Spotdata,spotdata);
end
end