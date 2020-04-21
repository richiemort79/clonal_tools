{//ClonalTools - R.Mort (2008). These tools count and measures the number of positive and 
//negative stripes dissected by a selection and perform the 1/(1-p)
//calculation described by Roach in 'The Theory of Random Clumping' (Methuen 1968).


//Circular Clonal Analysis - define edge of ROI with marquee tool. Circle is 80% diamter of ROI.

macro "Circular Clonal Analysis Action Tool - C000D00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D13D14D15D16D18D19D1aD1bD1cD1dD1fD20D24D25D2aD2fD30D31D36D38D39D3dD3eD3fD40D41D42D45D46D48D49D4dD4eD4fD50D51D52D54D56D58D59D5bD5dD5eD5fD60D61D63D64D65D67D68D6aD6bD6cD6fD70D71D73D74D75D79D7aD7bD7fD80D81D83D84D88D8aD8bD8cD8eD8fD90D91D93D94D97D98D9aD9bD9cD9eD9fDa0Da1Da2Da7Da8DadDaeDafDb0Db1Db6Db7Db8Db9DbdDbeDbfDc0Dc6Dc7Dc8Dc9DcfDd0Dd3Dd4Dd5DdaDdbDdfDe0De3De4De5De6De7De8De9DeaDebDecDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffCf00D26D27D28D29D34D35D3aD3bD43D4cD53D5cD62D6dD72D7dD82D8dD92D9dDa3DacDb3DbcDc4Dc5DcaDcbDd6Dd7Dd8Dd9CfffD11D12D17D1eD21D22D23D2bD2cD2dD2eD32D33D37D3cD44D47D4aD4bD55D57D5aD66D69D6eD76D77D78D7cD7eD85D86D87D89D95D96D99Da4Da5Da6Da9DaaDabDb2Db4Db5DbaDbbDc1Dc2Dc3DccDcdDceDd1Dd2DdcDddDdeDe1De2DedDee" {
    


ImageID = getTitle();

Dialog.create("Scale factor");
Dialog.addNumber("Scale (0-1):", 0.8);
Dialog.show();
Scale = Dialog.getNumber();

s = Scale*10;

run("Crop");
width = getWidth();
height = getHeight();      

w = width*Scale
h = height*Scale
x = width*((1-Scale)/2)
y = height*((1-Scale)/2)

{

makeOval(x, y, w, h);
run("Enlarge...", "enlarge+15");
setKeyDown("alt");
makeOval(x, y, w, h);
run("Enlarge...", "enlarge-15");

run("Copy");
//close();
newImage("PatchPlot", "RGB Black", width, height, 1);
run("Paste");
run("Make Binary");
run("BinaryFilterReconstruct ", "erosions=4 white");
run("BinaryFilterReconstruct ", "erosions=4");
run("Median...", "radius=2");

}

makeOval(x, y, w, h);

getSelectionCoordinates(x,y);

//make polyline
makeSelection("polyline", x, y);

//Image is now binary so threshold value (z) is
z=255/2

//draws the patch counter table

  requires("1.38m");
  title1 = "Patch Counter Table";
  title2 = "["+title1+"]";
  f = title2;
  if (isOpen(title1))
     print(f, "\\Clear");
  else {
     if (getVersion>="1.41g")
        run("Table...", "name="+title2+" width=600 height=800");
     else
        run("New... ", "name="+title2+" type=Table width=250 height=600");
  }


  print(f, "\\Headings:SamplePoint\tIntensity\tThreshold\tPositiveWdth\tNegativeWdth\tTotalPosStripes\tTotalNegStripes");

//counts total width of positive and negative stripes

x=0;
y=0;

profile = getProfile();
for (i=0; i<profile.length; i++) {

 if (profile[i]==0){
  // don't count

}
else{
  // count
  x++;
}

if (profile[i]==255){
  // don't count

}
else{
  // count
  y++;
}


//counts the total number of stripes

previous=-1;
stripes=0;
stripesC=0;
stripesNeg=0;
stripesPos=0;
stripesNegC=0;
stripesPosC=0;


//then check the current pixel:

g=getProfile();
for (j=0; j<profile.length; j++) 

if (previous==g[j]){
  // same as before, so do not count

}
else{
  // new stripe
  previous=g[j]; // change flag of current stripe
  stripes++;

if(previous==0){
stripesPos++;
}
else{}

if(previous==255){
stripesNeg++;
}
else{}
} 

if(stripesPos>stripesNeg) {
stripesPosC = stripesNeg; 
stripesNegC = stripesNeg;
}
else
{
stripesNegC = stripesPos; 
stripesPosC = stripesPos;
}

stripesC = stripesNegC + stripesPosC;

   print(f,i+"\t"+profile[i]+"\t"+(z)+"\t"+(y)+"\t"+(x)+"\t"+(stripesPosC)+"\t"+(stripesNegC));
}

//draws the summary table

  requires("1.38m");
  title1 = "Summary Table";
  title2 = "["+title1+"]";
  f = title2;
  if (isOpen(title1)){
}
else {
     if (getVersion>="1.41g")
        run("Table...", "name="+title2+" width=1000 height=300");
     else
        run("New... ", "name="+title2+" type=Table width=250 height=600");

  print(f, "\\Headings:ImageID\tThreshold\tPositiveWdth\tNegativeWdth\tPercPositive\tPosStripes\tNegStripes\tTotalStripes\t1/1-p\tCorStripes");

}

//calculates all variables and 1/(1-p)

stripes =stripes;
stripesPos = stripesPos;
stripesNeg = stripesNeg;
lengthNeg = x;
lengthPos = y;
totlength = (x+y);

propPos = y/(x+y);
propNeg = x/(x+y);

PercPositive = 100*propPos;

u = 1/(1-propPos);
q = 1/(1-propNeg);


meanstrwdthPos = (y)/stripesPos;
meanstrwdthNeg = (x)/stripesNeg; 
cstrwidthPos = meanstrwdthPos/u;
cstrwidthNeg = meanstrwdthNeg/q;
corstripes = (x+y)/cstrwidthPos; 


print(f,ImageID+"\t"+(z)+"\t"+(x)+"\t"+(y)+"\t"+(PercPositive)+"\t"+(stripesPosC)+"\t"+(stripesNegC)+"\t"+(stripesC)+"\t"+(u)+"\t"+(corstripes));

beep();

}

//Polygon Clonal Analysis - clonal analyisis of any polygon selection

macro "Polygon Clonal Analysis Action Tool - C000D00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D11D13D14D15D16D17D18D19D1aD1bD1cD1dD1eD1fD20D23D27D2aD2bD2cD2dD2eD2fD30D32D33D38D3aD3dD3eD3fD40D41D46D48D4dD4eD4fD50D51D56D57D5dD5eD5fD60D61D63D64D65D67D6fD70D71D74D75D76D78D79D7aD7dD7eD7fD80D81D82D84D88D89D8cD8dD8eD8fD90D91D92D93D97D9bD9cD9dD9eD9fDa0Da1Da2Da3Da7Da8DabDacDadDaeDafDb0Db1Db2DbcDbdDbeDbfDc0Dc1Dc2Dc7Dc8Dc9DccDcdDceDcfDd0Dd1Dd2Dd5Dd6Dd7Dd8Dd9DdaDddDdeDdfDe0De1De3De4De6De7De8De9DeaDebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffCf00D24D25D26D34D36D37D42D43D44D47D4aD4bD4cD52D58D59D5aD5cD62D6cD72D73D7bD7cD83D8aD8bD94D9aDa4DaaDb3Db6Db7Db8Db9DbbDc3Dc5Dc6DcaDcbDd3Dd4CfffD12D21D22D28D29D31D35D39D3bD3cD45D49D53D54D55D5bD66D68D69D6aD6bD6dD6eD77D85D86D87D95D96D98D99Da5Da6Da9Db4Db5DbaDc4DdbDdcDe2De5" {

ImageID = getTitle();

{
//Dialog.create("Reduce Selection");
//Dialog.addNumber("Pixels:", 60);
//Dialog.show();
//Pixels = Dialog.getNumber();

//P = Pixels;

width = getWidth();
height = getHeight();

run("Enlarge...", "enlarge=-60");
getSelectionCoordinates(x,y);

makeSelection("polygon", x, y);
run("Enlarge...", "enlarge=60");
setKeyDown("alt");
makeSelection("polygon", x, y);
run("Enlarge...", "enlarge=-60");

run("Copy");
//close();
newImage("PatchPlot", "RGB Black", width, height, 1);
run("Restore Selection");
run("Paste");
run("Make Binary");
run("BinaryFilterReconstruct ", "erosions=4 white");
run("BinaryFilterReconstruct ", "erosions=4");
run("Median...", "radius=2");
}

//make polyline
makeSelection("polygon", x, y);
run("Enlarge...", "enlarge=30");
getSelectionCoordinates(x,y);
makeSelection("polyline", x, y);

//Image is now binary so threshold value (z) is
z=255/2

//draws the patch counter table

  requires("1.38m");
  title1 = "Patch Counter Table";
  title2 = "["+title1+"]";
  f = title2;
  if (isOpen(title1))
     print(f, "\\Clear");
  else {
     if (getVersion>="1.41g")
        run("Table...", "name="+title2+" width=600 height=800");
     else
        run("New... ", "name="+title2+" type=Table width=250 height=600");
  }


  print(f, "\\Headings:SamplePoint\tIntensity\tThreshold\tPositiveWdth\tNegativeWdth\tTotalPosStripes\tTotalNegStripes");

//counts total width of positive and negative stripes

x=0;
y=0;

profile = getProfile();
for (i=0; i<profile.length; i++) {

 if (profile[i]==0){
  // don't count

}
else{
  // count
  x++;
}

if (profile[i]==255){
  // don't count

}
else{
  // count
  y++;
}


//counts the total number of stripes

previous=-1;
stripes=0;
stripesC=0;
stripesNeg=0;
stripesPos=0;
stripesNegC=0;
stripesPosC=0;


//then check the current pixel:

g=getProfile();
for (j=0; j<profile.length; j++) 

if (previous==g[j]){
  // same as before, so do not count

}
else{
  // new stripe
  previous=g[j]; // change flag of current stripe
  stripes++;

if(previous==0){
stripesPos++;
}
else{}

if(previous==255){
stripesNeg++;
}
else{}
}

if(stripesPos>stripesNeg) {
stripesPosC = stripesNeg; 
stripesNegC = stripesNeg;
}
else
{
stripesNegC = stripesPos; 
stripesPosC = stripesPos;
}

stripesC = stripesNegC + stripesPosC;

   print(f,i+"\t"+profile[i]+"\t"+(z)+"\t"+(y)+"\t"+(x)+"\t"+(stripesPosC)+"\t"+(stripesNegC));
}

//draws the summary table

  requires("1.38m");
  title1 = "Summary Table";
  title2 = "["+title1+"]";
  f = title2;
  if (isOpen(title1)){
}
else {
     if (getVersion>="1.41g")
        run("Table...", "name="+title2+" width=1000 height=300");
     else
        run("New... ", "name="+title2+" type=Table width=250 height=600");

  print(f, "\\Headings:ImageID\tThreshold\tPositiveWdth\tNegativeWdth\tPercPositive\tPosStripes\tNegStripes\tTotalStripes\t1/1-p\tCorStripes");

}

//calculates all variables and 1/(1-p)

stripes =stripes;
stripesPos = stripesPos;
stripesNeg = stripesNeg;
lengthNeg = x;
lengthPos = y;
totlength = (x+y);

propPos = y/(x+y);
propNeg = x/(x+y);

PercPositive = 100*propPos;

u = 1/(1-propPos);
q = 1/(1-propNeg);


meanstrwdthPos = (y)/stripesPos;
meanstrwdthNeg = (x)/stripesNeg; 
cstrwidthPos = meanstrwdthPos/u;
cstrwidthNeg = meanstrwdthNeg/q;
corstripes = (x+y)/cstrwidthPos; 


print(f,ImageID+"\t"+(z)+"\t"+(x)+"\t"+(y)+"\t"+(PercPositive)+"\t"+(stripesPosC)+"\t"+(stripesNegC)+"\t"+(stripesC)+"\t"+(u)+"\t"+(corstripes));

beep();

}

//Linear Clonal Analysis - clonal analyisis of any linear selection
//use the marquee tool to draw an ROI - a line is drawn in the centre of the roi
//parralel to its longest axis

macro "Linear Clonal Analysis Action Tool - C000D00D01D02D03D04D05D06D07D08D0bD0cD0dD0eD0fD10D14D15D16D17D18D1bD1cD1dD1fD20D25D26D27D28D2fD30D36D37D3aD3fD40D41D42D4aD4bD4cD4fD50D51D52D53D54D5aD5bD5cD5dD5fD60D61D62D63D64D65D6aD6bD6cD6dD6fD70D72D73D74D75D76D7bD7cD7dD7eD7fD80D84D85D86D8cD8dD8eD8fD90D91D92D99D9aD9bD9cD9dD9eD9fDa0Da1Da2Da9DaaDabDacDadDaeDafDb0Db1Db2Db3Db4DbcDbdDbeDbfDc0Dc1Dc2Dc3Dc4Dc5DceDcfDd0Dd2Dd3Dd4Dd5DdfDe0De3De4De5DefDf0Df1Df2Df3Df4Df7Df8Df9DfaDfbDfcDfdDfeDffCf00D09D0aD19D1aD29D2aD38D39D48D49D58D59D68D69D77D78D87D88D97D98Da7Da8Db6Db7Dc6Dc7Dd6Dd7De6De7Df5Df6CfffD11D12D13D1eD21D22D23D24D2bD2cD2dD2eD31D32D33D34D35D3bD3cD3dD3eD43D44D45D46D47D4dD4eD55D56D57D5eD66D67D6eD71D79D7aD81D82D83D89D8aD8bD93D94D95D96Da3Da4Da5Da6Db5Db8Db9DbaDbbDc8Dc9DcaDcbDccDcdDd1Dd8Dd9DdaDdbDdcDddDdeDe1De2De8De9DeaDebDecDedDee" {

ImageID = getTitle();

width = getWidth();
height = getHeight();

Dialog.create("Please Set Scale");
Dialog.addNumber("Distance in Pixels:", 1);
Dialog.addNumber("Actual Distance:", 1);
Dialog.show();

pixels = Dialog.getNumber;
distance = Dialog.getNumber;;

scale = distance/pixels;
//print(scale);

{
run("Copy");
//close();
newImage("PatchPlot", "RGB Black", width, height, 1);
run("Restore Selection");
run("Paste");
run("Make Binary");
run("BinaryFilterReconstruct ", "erosions=4 white");
run("BinaryFilterReconstruct ", "erosions=4");
run("Median...", "radius=2");
}

run("Restore Selection");
getSelectionBounds(x, y, width, height);

{
a=x
b=y+(height/2)
c=x+width
d=y+(height/2)

a1=x+(width/2)
b1=y
c1=x+(width/2)
d1=y+height
}

if(width>height)
{
makeLine(a, b, c, d);
}
else
{
makeLine(a1, b1, c1, d1);
}


//make polyline
getSelectionCoordinates(x,y);
makeSelection("polyline", x, y);


//Image is now binary so threshold value (z) is
z=255/2;

//draws the patch counter table

  requires("1.38m");
  title1 = "Patch Counter Table";
  title2 = "["+title1+"]";
  f = title2;
  if (isOpen(title1))
     print(f, "\\Clear");
  else {
     if (getVersion>="1.41g")
        run("Table...", "name="+title2+" width=600 height=800");
     else
        run("New... ", "name="+title2+" type=Table width=250 height=600");
  }


  print(f, "\\Headings:SamplePoint\tIntensity\tThreshold\tPositiveWdth\tNegativeWdth\tTotalPosStripes\tTotalNegStripes");

//counts total width of positive and negative stripes

x=0;
y=0;

profile = getProfile();
for (i=0; i<profile.length; i++) {

 if (profile[i]==0){
  // don't count

}
else{
  // count
  x++;
}

if (profile[i]==255){
  // don't count

}
else{
  // count
  y++;
}


//counts the total number of stripes

previous=-1;
stripes=0;
stripesC=0;
stripesNeg=0;
stripesPos=0;
stripesNegC=0;
stripesPosC=0;


//then check the current pixel:

g=getProfile();
for (j=0; j<profile.length; j++) 

if (previous==g[j]){
  // same as before, so do not count

}
else{
  // new stripe
  previous=g[j]; // change flag of current stripe
  stripes++;

if(previous==0){
stripesPos++;
}
else{}

if(previous==255){
stripesNeg++;
}
else{}
}

if(stripesPos>stripesNeg) {
stripesPosC = stripesNeg; 
stripesNegC = stripesNeg;
}
else
{
stripesNegC = stripesPos; 
stripesPosC = stripesPos;
}

stripesC = stripesNegC + stripesPosC;

   print(f,i+"\t"+profile[i]+"\t"+(z)+"\t"+(y)+"\t"+(x)+"\t"+(stripesPosC)+"\t"+(stripesNegC));
}

//draws the summary table

  requires("1.38m");
  title1 = "Summary Table";
  title2 = "["+title1+"]";
  f = title2;
  if (isOpen(title1)){
}
else {
     if (getVersion>="1.41g")
        run("Table...", "name="+title2+" width=1000 height=300");
     else
        run("New... ", "name="+title2+" type=Table width=250 height=600");

  print(f, "\\Headings:ImageID\tThreshold\tPositiveWdth\tNegativeWdth\tPercPositive\tPosStripes\tNegStripes\tTotalStripes\t1/1-p(pos)\t1/1-p(neg)\tCorPatchWdth(pos)\tCorPatchWdth(neg)");

}

lengthPos = y*scale;
lengthNeg = x*scale;
totlength = (x+y);

propPos = y/(x+y);
propNeg = x/(x+y);

PercPositive = 100*propPos;

u = 1/(1-propPos);
q = 1/(1-propNeg);

meanstrwdthPos = (y)/stripesPos;
meanstrwdthNeg = (x)/stripesNeg; 
cstrwidthPos = meanstrwdthPos/u;
cstrwidthNeg = meanstrwdthNeg/q;
corstripesP = (x+y)/cstrwidthPos; 
corstripesN = (x+y)/cstrwidthNeg; 
corstripesT = corstripesP + corstripesN;
corPatchLengthPos = lengthPos/corstripesP;
corPatchLengthNeg = lengthNeg/corstripesN;

print(f,ImageID+"\t"+(z)+"\t"+(lengthPos)+"\t"+(lengthNeg)+"\t"+(PercPositive)+"\t"+(stripesPos)+"\t"+(stripesNeg)+"\t"+(stripes)+"\t"+(u)+"\t"+(q)+"\t"+(corPatchLengthPos)+"\t"+(corPatchLengthNeg));

beep();

}

macro "Circular Batch Clonal Analysis Action Tool - C000D00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dD1eD1fD20D21D2dD2eD2fD30D31D34D35D36D37D38D39D3aD3bD3eD3fD40D41D45D46D48D49D4aD4bD4eD4fD50D51D55D56D5bD5eD5fD60D61D62D65D66D67D6eD6fD70D71D72D77D78D7eD7fD80D81D82D88D89D8eD8fD90D91D92D98D99D9aD9bD9eD9fDa0Da1Da2Da4Da5Da6DaaDabDaeDafDb0Db1Db2Db4Db5Db6Db7Db8Db9DbaDbbDbeDbfDc0Dc1Dc2DceDcfDd0Dd1Dd2Dd3DdeDdfDe0De1De2De3De4De5De6De7De8De9DeaDebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffCf00D3dD4dD5dD6dD7dD8dD9dDadDbdDcdDd4Dd5Dd6Dd7Dd8Dd9DdaDdbDdcDddCfffD22D23D24D25D26D27D28D29D2aD2bD2cD32D33D3cD42D43D44D47D4cD52D53D54D57D58D59D5aD5cD63D64D68D69D6aD6bD6cD73D74D75D76D79D7aD7bD7cD83D84D85D86D87D8aD8bD8cD93D94D95D96D97D9cDa3Da7Da8Da9DacDb3DbcDc3Dc4Dc5Dc6Dc7Dc8Dc9DcaDcbDcc"{

// "BatchCLonalFolders"
//
//This macro batch processes all the files in a folder and any
//subfolders in that folder. In this example, files must be in .tif
//format and pre-cropped

   requires("1.33s"); 
   dir = getDirectory("Choose a Directory ");
   setBatchMode(true);
stime=getTime();
completed = 0;
   count = 0;

Scale=0;

Dialog.create("Scale factor");
Dialog.addNumber("Scale (0-1):", 0.8);
Dialog.show();
Scale = Dialog.getNumber();

   countFiles(dir);
   n = 0;
   processFiles(dir);
   //print(count+" files processed");
   
   function countFiles(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              countFiles(""+dir+list[i]);
          else
              count++;
      }
  }

   function processFiles(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              processFiles(""+dir+list[i]);
          else {
             showProgress(n++, count);
             path = dir+list[i];
             processFile(path);
          }
      }
  }

  function processFile(path) {
       if (endsWith(path, ".tif")) {
           open(path);
           ImageID = getTitle();

s = Scale*10;

width = getWidth();
height = getHeight();      

w = width*Scale;
h = height*Scale;
x = width*((1-Scale)/2);
y = height*((1-Scale)/2);

{

makeOval(x, y, w, h);
run("Enlarge...", "enlarge+15");
setKeyDown("alt");
makeOval(x, y, w, h);
run("Enlarge...", "enlarge-15");

run("Copy");
//close();
newImage("PatchPlot", "RGB Black", width, height, 1);
run("Paste");
run("Make Binary");
run("BinaryFilterReconstruct ", "erosions=4 white");
run("BinaryFilterReconstruct ", "erosions=4");
run("Median...", "radius=2");

}

makeOval(x, y, w, h);

getSelectionCoordinates(x,y);

//make polyline
makeSelection("polyline", x, y);

//Image is now binary so threshold value (z) is
z=255/2;

//counts total width of positive and negative stripes

x=0;
y=0;

profile = getProfile();
for (i=0; i<profile.length; i++) {

 if (profile[i]==0){
  // don't count

}
else{
  // count
  x++;
}

if (profile[i]==255){
  // don't count

}
else{
  // count
  y++;
}


//counts the total number of stripes

previous=-1;
stripes=0;
stripesC=0;
stripesNeg=0;
stripesPos=0;
stripesNegC=0;
stripesPosC=0;


//then check the current pixel:

g=getProfile();
for (j=0; j<profile.length; j++) 

if (previous==g[j]){
  // same as before, so do not count

}
else{
  // new stripe
  previous=g[j]; // change flag of current stripe
  stripes++;

if(previous==0){
stripesPos++;
}
else{}

if(previous==255){
stripesNeg++;
}
else{}
} 

if(stripesPos>stripesNeg) {
stripesPosC = stripesNeg; 
stripesNegC = stripesNeg;
}
else
{
stripesNegC = stripesPos; 
stripesPosC = stripesPos;
}

stripesC = stripesNegC + stripesPosC;

}

//draws the summary table

  requires("1.38m");
  title1 = "Summary Table";
  title2 = "["+title1+"]";
  f = title2;
  if (isOpen(title1)){
}
else {
     if (getVersion>="1.41g")
        run("Table...", "name="+title2+" width=1000 height=300");
     else
        run("New... ", "name="+title2+" type=Table width=250 height=600");

  print(f, "\\Headings:ImageID\tThreshold\tPositiveWdth\tNegativeWdth\tPercPositive\tPosStripes\tNegStripes\tTotalStripes\t1/1-p\tCorStripes");

}

//calculates all variables and 1/(1-p)

stripes =stripes;
stripesPos = stripesPos;
stripesNeg = stripesNeg;
lengthNeg = x;
lengthPos = y;
totlength = (x+y);

propPos = y/(x+y);
propNeg = x/(x+y);

PercPositive = 100*propPos;

u = 1/(1-propPos);
q = 1/(1-propNeg);


meanstrwdthPos = (y)/stripesPos;
meanstrwdthNeg = (x)/stripesNeg; 
cstrwidthPos = meanstrwdthPos/u;
cstrwidthNeg = meanstrwdthNeg/q;
corstripes = (x+y)/cstrwidthPos; 


print(f,ImageID+"\t"+(z)+"\t"+(x)+"\t"+(y)+"\t"+(PercPositive)+"\t"+(stripesPosC)+"\t"+(stripesNegC)+"\t"+(stripesC)+"\t"+(u)+"\t"+(corstripes));

completed++;
           close();

      }
{
ftime=getTime();
etime=(ftime-stime)/60000;

if (completed == count){
print("Analysis complete: "+completed+" images analysed in "+etime+" minutes.");
}
else{}

}

{//NeuuronDist - R.Mort (2008).

macro "Rotate Right Action Tool - C000D00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dD1eD1fD20D21D22D23D24D25D26D27D28D29D2aD2bD2cD2dD2eD2fD30D31D32D33D34D35D36D3bD3cD3dD3eD3fD40D41D42D43D44D45D48D49D4aD4cD4dD4eD4fD50D51D52D53D54D58D59D5aD5bD5dD5eD5fD60D61D62D63D64D67D68D69D6aD6bD6dD6eD6fD70D71D72D73D77D78D79D7aD7bD7cD7eD7fD80D81D82D83D87D88D89D8aD8bD8cD8eD8fD90D91D92D93D97D98D99D9aD9bD9cD9eD9fDa0Da1Da9DaaDabDacDadDaeDafDb0Db1Db2Db8Db9DbaDbbDbcDbdDbeDbfDc0Dc1Dc2Dc3Dc7Dc8Dc9DcaDcbDccDcdDceDcfDd0Dd1Dd2Dd3Dd4Dd6Dd7Dd8Dd9DdaDdbDdcDddDdeDdfDe0De1De2De3De4De5De6De7De8De9DeaDebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffCfffD37D38D39D3aD46D47D4bD55D56D57D5cD65D66D6cD74D75D76D7dD84D85D86D8dD94D95D96D9dDa2Da3Da4Da5Da6Da7Da8Db3Db4Db5Db6Db7Dc4Dc5Dc6Dd5" {

run("Arbitrarily...", "angle=7.5 grid=0 interpolate=true");

run("Grid Overlay", "tile=512 tile=512 color=Cyan");


}

macro "Rotate Left Action Tool- C000D00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dD1eD1fD20D21D22D23D24D26D27D28D29D2aD2bD2cD2dD2eD2fD30D31D32D33D37D38D39D3aD3bD3cD3dD3eD3fD40D41D42D48D49D4aD4bD4cD4dD4eD4fD50D51D59D5aD5bD5cD5dD5eD5fD60D61D62D63D67D68D69D6aD6bD6cD6eD6fD70D71D72D73D77D78D79D7aD7bD7cD7eD7fD80D81D82D83D87D88D89D8aD8bD8cD8eD8fD90D91D92D93D94D97D98D99D9aD9bD9dD9eD9fDa0Da1Da2Da3Da4Da8Da9DaaDabDadDaeDafDb0Db1Db2Db3Db4Db5Db8Db9DbaDbcDbdDbeDbfDc0Dc1Dc2Dc3Dc4Dc5Dc6DcbDccDcdDceDcfDd0Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd8Dd9DdaDdbDdcDddDdeDdfDe0De1De2De3De4De5De6De7De8De9DeaDebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffCfffD25D34D35D36D43D44D45D46D47D52D53D54D55D56D57D58D64D65D66D6dD74D75D76D7dD84D85D86D8dD95D96D9cDa5Da6Da7DacDb6Db7DbbDc7Dc8Dc9Dca" {

run("Arbitrarily...", "angle=-7.5 grid=0 interpolate=true");

run("Grid Overlay", "tile=512 tile=512 color=Cyan");


}

macro "Explant Border Action Tool - C000D00D01D02D03D04D05D06D07D08D0aD0bD0cD0dD0eD0fD10D11D12D15D16D17D18D1aD1bD1cD1dD1eD1fD20D21D26D27D28D2aD2bD2cD2dD2eD2fD30D37D38D3aD3bD3cD3dD3eD3fD40D47D48D4aD4bD4cD4dD4eD4fD50D51D58D5aD5bD5cD5dD5eD5fD60D61D68D6aD6bD6cD6dD6eD6fD70D71D72D78D7aD7bD7cD7dD7eD7fD80D81D82D83D88D8aD8bD8cD8dD8eD8fD90D91D92D93D94D95D96D97D98D9aD9bD9cD9dD9eD9fDb0Db1Db2Db3Db4Db5Db6Db7Db8DbaDbbDbcDbdDbeDbfDc0Dc1Dc2Dc3Dc4Dc5Dc6Dc7Dc8DcaDcbDceDcfDd0Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd8DdaDdeDdfDe0De1De2De3De4De5De6De7De8DeaDefDf0Df1Df2Df3Df4Df5Df6Df7Df8DfaDfbDfcDfdDfeDffCf00D23D32D33D34D35D42D43D44D45D53D54D55D56D63D64D65D66D74D75D76DccDcdDdbDdcDddDebDecDedDeeC0ffD09D19D29D39D49D59D69D79D89D99Da0Da1Da2Da3Da4Da5Da6Da7Da8Da9DaaDabDacDadDaeDafDb9Dc9Dd9De9Df9Cff0D13D14D22D24D25D31D36D41D46D52D57D62D67D73D77D84D85D86D87" {

run("Make Composite");
Stack.setActiveChannels("001");
//Stack.setActiveChannels("100");
setTool(2);
//run("Grid Overlay", "tile=512 tile=512 color=Red");
showMessage("Please define the edge of the explant");


}

macro "Neuron Distibution Action Tool - C000D00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D12D13D14D16D17D18D19D1aD1bD1cD1dD1eD1fD20D21D22D23D24D25D27D28D29D2aD2bD2cD2eD2fD30D31D33D34D35D39D3aD3bD3dD3eD3fD40D41D45D46D47D49D4aD4cD4dD4eD4fD50D51D52D53D56D57D59D5aD5cD5dD5eD5fD60D62D63D64D69D6cD6dD6eD6fD70D71D72D73D74D7bD7cD7dD7eD7fD80D81D82D83D89D8aD8bD8cD8eD8fD90D91D92D99D9aD9bD9cD9dD9eD9fDa0Da1Da4Da5Da8Da9DacDadDaeDafDb0Db2Db3Db4Db5Db7Db8DbdDbeDbfDc0Dc1Dc2Dc3Dc4Dc7Dc8DcdDceDcfDd0Dd1Dd2Dd3Dd5Dd6Dd7Dd8DdcDddDdeDdfDe0De1De2De3De4De5De6De7De8De9DeaDebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffCf00D66D67D75D76D77D78D85D86D87D88D95D96D97D98Da6Da7DaaDabDb9DbaDbbDbcDc9DcaDcbDccDd9DdaDdbC0f0D11D15D26D2dD32D36D37D38D3cD42D43D44D48D4bD54D55D58D5bD61D65D68D6aD6bD79D7aD84D8dD93D94Da2Da3Db1Db6Dc5Dc6Dd4" {
if (selectionType==-1)
exit("Selection required please define using the border tool");
//if (Image!=composite)
//exit("Composite image required have you used the border tool?");

ImageID = getTitle();

getSelectionCoordinates(x,y);

Stack.setActiveChannels("100");
Stack.setActiveChannels("110");
Stack.setActiveChannels("111");

run("Stack to RGB");

width = getWidth();
height = getHeight();

run("Copy");
close();
newImage("Neurite", "RGB Black", width, height, 1);
run("Paste");

run("Split Channels");
selectWindow("Neurite (red)");
close();
selectWindow("Neurite (blue)");
close();
selectWindow("Neurite (green)");

run("Restore Selection");
run("Enlarge...", "enlarge=40");
getSelectionCoordinates(x,y);

run("Make Binary");
//run("BinaryFilterReconstruct ", "erosions=1 white");
//run("BinaryFilterReconstruct ", "erosions=1");

run("Restore Selection");
makeSelection("polyline", x, y);

//Image is now binary so threshold value (z) is
z=255/2;

//Calculate the distibution of neurons

{
e = 0;
f = 0;
g = 0;
firstqx = 0;
firstqy = 0;
secondqx = 0;
secondqy = 0;
thirdqx = 0;
thirdqy = 0;
fourthqx = 0;
fourthqy = 0;

profile = getProfile();

e = profile.length*0.25;
f = profile.length*0.5;
g = profile.length*0.75;

//Calculate secondq
{
for (i=0; i<e; i++)

{

 if (profile[i]==255){
  // don't count

}
else{
  // count
  secondqx++;
}

if (profile[i]==0){
  // don't count

}
else{
  // count
  secondqy++;

}

secondqPercPos = (secondqy/(secondqx+secondqy))*100;
}}

//Calculate thirdq
{
for (j=e; j<f; j++)

{

 if (profile[j]==255){
  // don't count

}
else{
  // count
  thirdqx++;
}

if (profile[j]==0){
  // don't count

}
else{
  // count
  thirdqy++;

}

thirdqPercPos = (thirdqy/(thirdqx+thirdqy))*100;
}}

//Calcu;ate fourthq
{
for (k=f; k<g; k++)

{

 if (profile[k]==255){
  // don't count

}
else{
  // count
  fourthqx++;
}

if (profile[k]==0){
  // don't count

}
else{
  // count
  fourthqy++;

}

fourthqPercPos = (fourthqy/(fourthqx+fourthqy))*100;
}}

//Calculate firstq
{
for (l=g; l<profile.length; l++)

{

 if (profile[l]==255){
  // don't count

}
else{
  // count
  firstqx++;
}

if (profile[l]==0){
  // don't count

}
else{
  // count
  firstqy++;

}

firstqPercPos = (firstqy/(firstqx+firstqy))*100;
}}

//draws the summary table

  requires("1.38m");
  title1 = "Neurite Summary Table";
  title2 = "["+title1+"]";
  f = title2;
  if (isOpen(title1)){
}
else {
     if (getVersion>="1.41g")
        run("Table...", "name="+title2+" width=1000 height=300");
     else
        run("New... ", "name="+title2+" type=Table width=250 height=600");

  print(f, "\\Headings:ImageID\tThreshold\tPercPositive0-90\tPercPositive90-180\tPercPositive180-270\tPercPositive270-360");

}

print(f,ImageID+"\t"+(z)+"\t"+(firstqPercPos)+"\t"+(secondqPercPos)+"\t"+(thirdqPercPos)+"\t"+(fourthqPercPos));

beep();

}}

  }
