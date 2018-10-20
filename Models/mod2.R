library(rjags)
library(tidyverse)
library(ggplot2)
library(stringr)
library(gridExtra)

subDat <- readRDS("../data/auxPink.rds") #model data
dat <- read.csv("../data/pinkdata.csv")

###Regional summary information
regionSummary <- dat %>% group_by(Region) %>%
  summarise(medLat = median(Latitude,na.rm=TRUE),medLong = median(Longitude,na.rm=TRUE), medAlongShoreDist = median(AlongShore_Distance,na.rm=TRUE))


##End load relevant data

#####Begin organize data
nRow <- nrow(subDat)
s <- as.integer(subDat$S*1000)
n <- as.integer(subDat$lastR*1000)
region <- as.numeric(subDat$Region)
nReg <- length(unique(region))
time <- subDat$BY
asd <- regionSummary$medAlongShoreDist

####Begin Setting up values for jags
dataList <- list(
  'nRow' = nRow,
  "n" = n,
  "s" = s,
  "region" = region,
  "time" = time,
  "nReg" = nReg,
  "asd" = asd)


parameters <- c(
  "alpha",
  "beta0",
  "beta1",
  "tau2",
  "tau2alpha",
  "beta2"
)

initsValues <- list(
  "alpha" = rep(0,nReg),
  "beta0" = 0,
  "beta1" = 0,
  "tau2" = 1,
  "tau2alpha" = 1,
  "beta2" = 0
)

adaptSteps <- 50000
burnInSteps <- 25000
nChains <- 2
numSavedSteps <- 25000
thinSteps <- 1
nIter <- ceiling((numSavedSteps*thinSteps)/nChains)

jagsModel <- jags.model("../Jags/mod2.txt",
                        data=dataList,
                        inits=initsValues,
                        n.chains=nChains,
                        n.adapt=adaptSteps)

####End Setting up values for jags

###Begin run JAGS
update(jagsModel,n.iter=burnInSteps)
codaSamples <- coda.samples(jagsModel,
                            variable.names=parameters,
                            n.iter=nIter,
                            thin=thinSteps)
###End run JAGS

###Begin Trace Plots
chain1 <- data.frame(codaSamples[[1]])
chain2 <- data.frame(codaSamples[[2]])
postSamples <- rbind(chain1,chain2)
names(postSamples) <- c(as.character(unique(subDat$Region)),"beta0","beta1","beta2","tau2","tau2alpha")

vizTrace <- function(col,name) {
  chain <- as.factor(rep(c(1,2),each=nIter))
  sample <- rep((adaptSteps+burnInSteps):(adaptSteps+burnInSteps+nIter-1),2)
  return(ggplot(data=NULL,aes(x=sample,y=col,color=chain))+
           geom_line()+
           xlab("Sample Number")+
           ylab(name)+
           ggtitle(str_c("Posterior Samples for ",name)))
}

vizes <- map2(postSamples,names(postSamples),vizTrace)
grid.arrange(grobs=vizes,top="Figure 7: Trace Plots for Model 3")






























