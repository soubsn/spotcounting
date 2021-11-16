function [res,dist]=spotlocation(ObjCell)
    dist=[];
    for l=1:height(ObjCell)
        if ObjCell{l,4} == 0
            continue
        end
        cen=ObjCell{l, 2}{1, 9};
        len=ObjCell{l, 2}{1, 1};
        spt=ObjCell{l,4}(:,1:2);

        for l2=1:height(spt)
            d=sqrt((spt(l2,1)-cen(1,1))^2 + (spt(l2,2)-cen(1,2))^2);
            if height(ObjCell{l, 1}) > width(ObjCell{l, 1})
                ori= spt(l2,1)-cen(1,1);
                if ori >= 0
                    d=d;
                else
                    d=-d;
                end
            elseif height(ObjCell{l, 1}) < width(ObjCell{l, 1})
                ori= spt(l2,2)-cen(1,2);
                if ori >= 0
                    d=d;
                else
                    d=-d;
                end
            else
                d=d;
            end
                ori= spt(l2,1)-cen(1,1);
            di=[l height(spt) d len ObjCell{l, 8}(l2,end)];
            dist=vertcat(dist,di);
        end
    end
    res.Distance_and_Intensity =dist;
      
end