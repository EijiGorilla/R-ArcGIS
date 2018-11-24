tool_exec=function(in_params,out_params)
{
  library(tcltk)
  library(lattice)
  library(plyr)
  library(openxlsx)
  
  # Specifiy Input and Output parameters
  Inventory=in_params[[1]]
  LandCover=in_params[[2]]
  WD=in_params[[3]]
  BEF=in_params[[4]]
  BCEF=in_params[[5]]
  RS=in_params[[6]]
  CF=in_params[[7]]
  
  result=out_params[[1]]
  
  ## 1- Area of Forest and Woodland:----
  
  # Open summarized GIS Database
  d=arc.open(LandCover)
  GIS=arc.select(d,fields="*")
  colnames(GIS)=c("n","class","frequency","Area_Ha")

  # Convert m2 to '000 ha
  FArea=(GIS$Area_Ha[GIS$class=="Typical Forest"]+GIS$Area_Ha[GIS$class=="Riparian Forest"])/1000
  WArea=(GIS$Area_Ha[GIS$class=="Woodland"])/1000

  # Calculate total area by summing above:
  TotalArea=FArea+WArea+OtherArea+WaterArea
  
  ## 2- Total Growing Stock:----
  # 2-1. Read Inventory dataset and Prepare Data:----
  X=list()
  for(i in seq(length(nf))){
    
    B=read.xlsx(nf[i],1)
    
    # Remove irrelevant information after tree volume:
    vol=grep("T_Vol",names(B))
    B=B[,c(1:vol)]
    
    # Remove dead stems (i.e., Forest.type = 45 or 46):----
    B=B[B$Damage.Code1!=45 & B$Damage.Code1!=46,]
    
    # Remove forest types "Others" as these plots are not used for biomass calculation
    B=B[!is.na(B$Forest.Type),]
    
    # Keep only variables needed for biomass estimation:
    B=B[,c(1,5,6,14,17:19,30)]
    
    # Accumulate all NFI tables:
    X=rbind(X,assign(paste0("B"),data.frame(B)))
  }
  
  # Rename variables
  colnames(X)=c("date","unitID","plot","type","sp","dbh_cat","dbh","vol")
  
  
  # 2-2. Mean volume of ha of unitID:----
  
  X1$unitID=factor(X1$unitID)
  X1$plot=factor(X1$plot)
  X1$dbh_cat=factor(X1$dbh_cat)
  X1$type=factor(X1$type)
  
  # 2-2-1. Total volume of each DBH Cat.:----
  xx=ddply(X1,.(unitID,type,plot,dbh_cat),function(x) sum(x$vol,na.rm=TRUE))
  
  # 2-2-2. Volume per ha of Each DBH Category:----
  xx$radius=6
  xx$radius[xx$dbh_cat=="Medium"]=12
  xx$radius[xx$dbh_cat=="Big"]=20
  xx$m2=3.14*((xx$radius)^2)
  xx$VolperHa=xx$V1*(10000/xx$m2)
  
  # 2-2-3. Total volume per ha of Each UNIT ID, and Each Plot:----
  xx=ddply(xx,.(unitID,type,plot),function(x) sum(x$VolperHa,na.rm=TRUE))
  
  
  # 2-2-4. Identify land cover type that dominates unitID:----
  c=ddply(xx,.(unitID),function(x) count(x$type))

  # Make sure data contain no missing unitID
  if(length(which(is.na(c$unitID)))==0){
    c=c } else {c=c[-which(is.na(c$unitID))]}
  
  temp=list()
  for(i in unique(c$unitID)){
      v=c[c$unitID==i,]
      v1=v$x[which.max(v$freq)]
      nn=data.frame(unitID=i,type=v1)
      temp=rbind(temp,assign(paste0("nn"),data.frame(nn)))
  }
  
  
  # 2-2-5. Mean Volume per ha of unitID:----
  xx=ddply(xx,.(unitID),function(x) mean(x$V1,na.rm=TRUE))
  
  # 2-3. Add identified forest type for each unitID to volume data:----
  xx1=merge(xx,temp,by="unitID")
  
  # 2-4. Mean volume per ha of forest tyep:----
  xx1_mean=ddply(xx1,.(type),function(x) mean(x$V1))
  xx1_sd=ddply(xx1,.(type),function(x) sd(x$V1))
  xx1_n=ddply(xx1,.(type),function(x) count(x$type))
  
  f=data.frame(xx1_mean,sd=xx1_sd$V1,n=xx1_n$freq)
  f$se=f$sd/sqrt(f$n)
  
  # 2-5. Calculate Total Forest Growing Stock (million m3):----
  GS_F=f$V1[f$type=="Forest"]*FArea/1000
  GS_W=f$V1[f$type=="Woodland"]*WArea/1000
  
  GS_Total=GS_F+GS_W
  
  ## 3. Forest Biomass:---- 
  
  # 3-1. Above- and Below-ground biomass (milllion tonnes):----
  AGB_BCEF=GS_Total*BCEF
  BGB_BCEF=AGB_BCEF*RS
  
  # 3-2. Carbon in AGB/BGB (million tonnes):----
  AGB_C=AGB_BCEF*CF
  BGB_C=BGB_BCEF*CF
  
  ## 4. Generate a Table that contains all information:---
  T=data.frame(Forest_Area=FArea,
               Woodland_Area=WArea,
               OtherLand_Area=OtherArea,
               WaterBody=WaterArea,
               TotalArea=TotalArea,
               GrowingStock=GS_Total,
               AGB=AGB_BCEF,
               BGB=BGB_BCEF,
               AGB_Carbon=AGB_C,
               BGB_Carbon=BGB_C)
  
  
  
  ## 5. Export results:----
  arc.write(result,T)
  
  return(out_params)
  
}