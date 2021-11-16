function [res,a]=spotaverage(ObjCell)
    a=cell2mat(ObjCell(:,3));
    a1=mean(a);
    a2=std(a);
    a3=tabulate(a);
    res=struct();
    Average = [a1,a2]
    res.Average=[a1,a2];
    res.Tabulations=a3;
end
