
function [ObjCell,Spotdata]=ImageModifier(ObjCell,C,l,JJ,Spotdata)
r1=2;
user_input2 = inputdlg ('Do all the cells good?','Cell Processing',[1 50],{'N'});
if user_input2{1,1} == 'Y' || user_input2 {1,1} == 'y'
    close all
else
    list=string([1:l]);
    resy=listdlg('ListString',list);
    l1=length(resy);
    close all
    for l2=1:l1
        l3=resy(l2);
        label=string(l3);
        image=imcrop(C,ObjCell{l3, 2}{1, 6});
        seg=ObjCell{l3, 1};
        seg(seg==0)=ObjCell{l3, 2}{1, 5};
        figure
        imshow(seg,[])%HM modify magnification
        text(3,3,label,'Color','r')
        title('click a spot and hold alt key to select multiple spots, push any key when finished')
        datacursormode on
        pause
        dcm_obj = datacursormode(1);
        info_struct = getCursorInfo(dcm_obj);
        close all
        if isempty(info_struct)
           ObjCell{l3,4}= 0;
           ObjCell{l3,3}= 0;
           ObjCell{l3,5}= 0;
           ObjCell{l3,6}= 0;
           ObjCell{l3,7}= 0;
           ObjCell{l3,8}= 0;
           [R,~] = find( Spotdata(:,10)==l3);
           Spotdata(R,:)=[];
           continue
        end
        %Loop over spots chosen and pull out co-ordinates
        sspot=[];
        for q=1:size(info_struct,2)
            Spot_coords=info_struct(q).Position;
            t=image((Spot_coords(1,2)-r1):(Spot_coords(1,2)+r1),(Spot_coords(1,1)-r1):(Spot_coords(1,1)+r1));
            [res]=GaussianSurf(t);
            dif=res.a/res.b;
            add=sum(t,'all');
            p=[res.x0-3, res.y0-3];
            Spot_coords=Spot_coords+p;
            y_est(q,1)=Spot_coords(1);
            x_est(q,1)=Spot_coords(2);
            y_estimate(q,1)=Spot_coords(1)+ ObjCell{l3, 2}{1, 6}(1,1);
            x_estimate(q,1)=Spot_coords(2)+ ObjCell{l3, 2}{1, 6}(1,2);
            spotdata=[x_estimate(q,1) y_estimate(q,1) res.a res.b dif res.sigma res.sse res.r2 q l3 JJ add];
            sspot=vertcat(sspot,spotdata);
        end
        poss=[x_estimate y_estimate];
        poss2=[x_est y_est];
        ObjCell{l3,8}=sspot;
        ObjCell{l3,6}= sspot(:,12);
        ObjCell{l3,7}= sum(sspot(:,12));
        ObjCell{l3,4}= poss2;
        ObjCell{l3,5}= poss;
        [JJJ,~]= size(poss);
        ObjCell{l3,3}= JJJ;        
        [R,~] = find( Spotdata(:,10)==l3);
        if isempty(R)
            te=max(unique(find(Spotdata(:,10)<l3)));
            if isempty(te)
                Spotdata=vertcat(sspot,Spotdata);
            else
            Spotdata=vertcat(Spotdata(1:(te),:),sspot,Spotdata((te+1):end,:));
            end
        else
        Spotdata=vertcat(Spotdata(1:(R(1)-1),:),sspot,Spotdata((R(end)+1):end,:));
        end
        clear poss JJJ info_struct x_estimate y_estimate y_est x_est
    end
end
end