clear
close all
% Script to segment cells and count spots from a single image
%% Variables that can be changed
LB = 20; % Pixel Lower Boundary
amp = strel('sphere',4);
LMaxFinder = vision.LocalMaximaFinder('MaximumNumLocalMaxima',4,'NeighborhoodSize',[5,5],'IndexDataType','double','ThresholdSource','Input port');
%% A) Getting the Cell Outline
FileList = dir(fullfile(cd, '**','*.npy'));
BF_file2 = table2array(struct2table(struct('folder', {FileList(1:end).folder})));
BF_file= natsortfiles(table2array(struct2table(struct('name', {FileList(1:end).name}))));
a=BF_file2 + "/" + BF_file;
aa= uigetfile('*.vsi', 'Pick Fluorescent Image', 'Multiselect', 'on');
%% stuff to check and delete if unnecessary
SpotData=[];
DI=[];
Spo=[];
%%
for JJ= 1:height(a)
    Spotdata=[];
    c=imbinarize(readNPY(a{JJ,1}));
    RD=bfopen(aa{1,JJ});
    C=double(RD{1,1}{1,1});
    [si,ze]=size(C);
    f =(bwareaopen(c,LB));
    f(1,:) = 1;
    f(end:end,:) = 1;
    f(:,1) = 1;
    f(:,end) = 1;
    f=imclearborder(f,8);
    f2 = bwconncomp(f);
    stats = regionprops(f2,'BoundingBox','PixelList');
    l=length(stats);
    for L=1:l
        List = stats(L).BoundingBox;
        List(1,1:2) = List(1,1:2) -5;
        List(1,3:4) = List(1,3:4) +10;
        stats(L).BoundingBox=List;
        m = accumarray(fliplr(stats(L).PixelList),true,[si,ze],@any,false);
        m=imcrop(m,List);
        C2=imcrop(C,List);
        single=imdilate(m,amp);
        seg=C2.*single;
        stats2 = regionprops(single,seg,'MeanIntensity','Area','PixelList','PixelValues','MajorAxisLength','MinorAxisLength','MinIntensity','Centroid','Orientation');
        if height(stats2) > 1
           [~, I]= max([stats2.Area]);
           stats2=stats2(I);
        end
        ObjCell{L,1}=seg;
        ObjCell{L,2}= [stats2.MajorAxisLength, stats2.MinorAxisLength, stats2.MeanIntensity, stats2.Area, stats2.MinIntensity, stats(L).BoundingBox, {stats2.PixelList}, {stats2.PixelValues}, {stats2.Centroid}, stats2.Orientation];
    end
    if JJ == 1
        tested = 1;
        while tested == 1
            user_input_tracks = inputdlg({'Threshold','SNR'},'User Input',[1 50; 1 50],{'15','50'});
            thresh = str2double(user_input_tracks{1});
            S =str2double(user_input_tracks{2});
            [ObjCell,Spotdata]=ImagePrinter(ObjCell,C,LMaxFinder,S,thresh,JJ);
            user_input2 = inputdlg ('Is the threshold and SNR good?','Cell Processing',[1 50],{'N'});
            if user_input2{1,1} == 'N' || user_input2 {1,1} == 'n'
                close all
                tested= 1;
            else
                tested =1+1;
            end
        end
        [ObjCell,Spotdata]=ImageModifier(ObjCell,C,l,JJ,Spotdata);
    else
        [ObjCell,Spotdata]=ImagePrinter(ObjCell,C,LMaxFinder,S,thresh,JJ);
        [ObjCell,Spotdata]=ImageModifier(ObjCell,C,l,JJ,Spotdata);
        
    end
    SpotData=vertcat(SpotData,Spotdata);
    [rs,sp]=spotaverage(ObjCell);
    [rs2,dist]=spotlocation(ObjCell);
    result.Average=rs.Average;
    result.Tabulations=rs.Tabulations;
    result.Data=ObjCell;
    result.Spot_Info=Spotdata;
    result.Distance_and_Intensity=rs2.Distance_and_Intensity;
    DI=vertcat(DI,dist);
    Spo=vertcat(Spo,sp);
    save_name_spots = strrep(aa{1,JJ}, '.vsi', '_Results.mat');
    save (save_name_spots, 'result')
    clear ObjCell
end
a1=tabulate(Spo);
a2=array2table(a1,'VariableNames',{'Value','Count','Percent'});
Total_Average = [length(Spo) mean(Spo) std(Spo)]
Total_Intensity = [length(Spo) mean(DI(:,5)) std(DI(:,5))]
d1=zeros(0,5);
d2=zeros(0,5);
d3=zeros(1,5)
d4=zeros(0,5);
d1=DI(any(DI(:,2)==1,2),:);
d_i1 = [length(d1) mean(d1(:,5)) std(d1(:,5))];
d2=DI(any(DI(:,2)==2,2),:);
d_i2 = [length(d2) mean(d2(:,5)) std(d2(:,5))];
d3=DI(any(DI(:,2)==6,2),:);
d_i3 = [length(d3) mean(d3(:,5)) std(d3(:,5))];
d4=DI(any(DI(:,2)==4,2),:);
d_i4 = [length(d4) mean(d4(:,5)) std(d4(:,5))];
l1=vertcat(-DI(:,4),DI(:,4));
l2=vertcat(DI(:,4),DI(:,4));
figure; line(-DI(:,4),DI(:,4))
hold on
line(DI(:,4),DI(:,4))
scatter(d1(:,3),d1(:,4),'black')
scatter(d2(:,3),d2(:,4),'red')
scatter(d3(:,3),d3(:,4),'blue')
scatter(d4(:,3),d4(:,4),'green')
hold off
saveas(gcf,'SpotLocation.pdf')
ints=[{d1(:,5)},{d2(:,5)},{d3(:,5)},{d4(:,5)},{DI(:,5)}];
violin(ints);
saveas(gcf,'SpotIntensity.pdf')
Results.Intensities=ints;
Results.Data=DI;
Results.Spots=Spo;
Results.Total_Average=Total_Average;
Results.Total_Intensity=Total_Intensity;
figure
bar(a2.Value,a2.Percent);
hold on
ylabel('%')
xlabel('Foci per Cell')
hold off
saveas(gcf,'FociPerCell.pdf')
save_name_spots = strrep(aa{1,1}, '.vsi', '_Total_Results.mat');
save (save_name_spots, 'Results')