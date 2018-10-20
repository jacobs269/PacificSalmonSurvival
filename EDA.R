library(tidyverse)
library(ggmap)

dat <- read.csv("data/pinkdata.csv")

###BEGIN REPETITION [Some setup for visualizations]

dat <- dat %>% 
  mutate(even = ifelse(BY%%2==0,"even","odd")) %>%
  mutate(stockPop = str_c(Stock,even,sep="_"))


###This inefficient function gets the recruitment from the previous iteration of spawning
grabRecruit <- function(mainDat) {
  recruitCountsLag1 <- c()
  for (i in 1:nrow(mainDat)) {
    nextPop <- mainDat[i,]
    lastPop <- mainDat %>% filter(t==(nextPop$t-2),
                                  stockPop==nextPop$stockPop)
    if (lastPop %>% nrow() == 0) {
      recruitCountsLag1 <- c(recruitCountsLag1,NA)
    }
    else {
      recruitCountsLag1 <- c(recruitCountsLag1,lastPop$R)
    }
  }
  return (recruitCountsLag1)
}

dat$lastR <- grabRecruit(dat)
dat <- dat %>% mutate(survRate = S/lastR)

##END REPETITION

##helper dataset setup
stockSummary <- dat %>% group_by(Stock) %>%
  summarise(medLat = median(Latitude,na.rm=TRUE),medLong = median(Longitude,na.rm=TRUE), medAlongShoreDist = median(AlongShore_Distance,na.rm=TRUE),meanSurvRate = mean(survRate,na.rm=TRUE))

regionSummary <- dat %>% group_by(Region) %>%
  summarise(medLat = median(Latitude,na.rm=TRUE),medLong = median(Longitude,na.rm=TRUE), medAlongShoreDist = median(AlongShore_Distance,na.rm=TRUE))

##Plot one: Map Plot
box <- make_bbox(lon = -stockSummary$medLong, lat = stockSummary$medLat,f=.5)
MAP <- get_map(location = box, maptype = "satellite", source = "google")
mapViz <- ggmap(MAP) + 
  geom_point(data = stockSummary, aes(x = -medLong, y = medLat,size=meanSurvRate,color="yellow"))+guides(color=FALSE)+scale_size_continuous(name="Mean Stock Life Cycle Survival Rate")+ggtitle("Figure 1: Exploring Stocks by their Mean Life Cycle Survival Rates")+guides(size=FALSE)+labs(subtitle="Stocks are sized according to Mean Life Cycle Survival Rate")
mapViz


##Figure 2: Non attrition rate by stock-year-spawn
f2 <- ggplot(data=dat,aes(x=survRate))+geom_histogram()+xlim(0,1)+xlab("Life Cycle Survival Rate")+ylab("Count")+ggtitle("Figure 2: Life Cycle Survival Rate for Stock Breeding")
f2

##It looks like most of the non-attrition center towards the middle of the distribution

##Figure 3: Non attrition rate for stocks broken down by region
f3 <- ggplot(data=dat,aes(x=survRate))+geom_histogram()+xlim(0,1)+xlab("Life Cycle Survival Rate")+ylab("Count")+ggtitle("Figure 3: Life Cycle Survival Rate for Stock Breeding Broken Down By Region")+facet_wrap(~Region)
f3

#It looks all of the non-attrition rates are very high for Yakukat. Also, it looks like there are pockets of "normally distributed" looking groups, probably some division by stock

##Figure 4: Non attrition rate for stocks broken down by region, with color for stock
f4 <- ggplot(data=dat,aes(x=survRate,fill=stockPop))+geom_histogram()+xlim(0,1)+xlab("Life Cycle Survival Rate")+ylab("Count")+ggtitle("Figure 4: Life Cycle Survival Rate for Stock Breeding Broken Down by Region with Color for Stock Population")+facet_wrap(~Region)+guides(fill=FALSE)
f4


f <- dat %>% 
  group_by(AlongShore_Distance) %>%
  summarise(avgAttrition=mean(survRate,na.rm=TRUE))

##Figure 5: Relationship between along shore distance, and the rate of non-attrition
f5 <- ggplot(data=f,aes(x=as.factor(AlongShore_Distance),y=avgAttrition))+geom_bar(stat="identity")+ylim(0,1)+xlab("Along Shore Distance")+ylab("average Life Cycle Survival Rate")+ggtitle("Figure 5: Along Shore Distance vs Life Cycle Survival Rate")
f5











