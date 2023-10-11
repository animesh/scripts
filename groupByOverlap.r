#https://stackoverflow.com/a/37487673
#data####
df<-read.table("proteinGroups.txt",header=T,sep="\t",row.names=NULL)
#group####
library("dplyr")
df$End<-as.Date(df$End,format="%m/%d/%Y")
df$Start<-as.Date(df$Start,format="%m/%d/%Y")
cumsum((df$Start)-lag((df$End), default=as.Date(1)) != 1)
cumsum(as.numeric(df$Start)-lag(as.numeric(df$End), default=1) != 1)
df %>%
  mutate(group = cumsum(Start-lag(End, default=as.Date(1)) != 1)) %>%
  #mutate(group = cumsum(as.numeric(df$Start)-lag(as.numeric(df$End), default=1) != 1)) %>%
  group_by(group, Group, PGID) %>%
  #groupoup_by(ID, SiteID) %>%
  summarise(Start = min(Start),End   = max(End),rankSum     = sum(rankIntensity))
#library(data.table)
#setDT(df)
#df[, group := cumsum(Start - shift(End, fill=1) != 1),][, list(Start=min(Start), End=max(End), rankSum=sum(rankIntensity)), by=.(group, Group, PGID)]
