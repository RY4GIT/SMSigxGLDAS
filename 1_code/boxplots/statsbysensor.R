library('hydroGOF')
library('SimDesign')
library('ggplot2')
library(TSstudio)
library(tidyverse) 
library(lubridate) 
library(ggpmisc)
library(stringr)
library(ggpmisc)
SCAN <- read.csv(file="P:/soilmoisture_ry/boxplots/weighted/SCAN.csv")
USCRN <- read.csv(file="P:/soilmoisture_ry/boxplots/weighted/USCRN.csv")
OZNET <- read.csv(file="P:/soilmoisture_ry/boxplots/weighted/depth_3cm_arid.csv")


rmse <- OZNET %>%
  group_by(ID) %>% 
  summarise(r = rmse(gldas, insitu))
bias <- OZNET %>%
  group_by(ID) %>% 
  summarise(r = bias(gldas, insitu))
ubrmse <- OZNET %>%
  group_by(ID) %>% 
  summarise(r = sqrt((rmse(gldas,insitu))^2-(bias(gldas, insitu))^2))
correlate <- OZNET %>%
  group_by(ID) %>% 
  summarise(r = cor(gldas, insitu))


r <- merge(rmse,bias,by=c('ID'),all.x=T)
r1 <- merge(r,ubrmse,by=c('ID'),all.x=T)
r2 <- merge(r1,correlate,by=c('ID'),all.x=T)
write.csv(r2,"P:/soilmoisture_ry/boxplots/weighted/OZNET3_stats.csv" )

