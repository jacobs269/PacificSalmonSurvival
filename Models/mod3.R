library(rjags)
library(tidyverse)
library(ggplot2)
library(stringr)
library(gridExtra)

subDat <- readRDS("../data/auxPink.rds")
dat <- read.csv("../data/pinkdata.csv")

###Regional summary information
regionSummary <- dat %>% group_by(Region) %>%
  summarise(medLat = median(Latitude,na.rm=TRUE),medLong = median(Longitude,na.rm=TRUE), medAlongShoreDist = median(AlongShore_Distance,na.rm=TRUE))


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
  "nReg" = nReg,
  "asd" = asd)


parameters <- c(
  "alpha",
  "tau2alpha",
  "beta2"
)

initsValues <- list(
  "alpha" = rep(0,nReg),
  "tau2alpha" = 1,
  "beta2" = 0
)

adaptSteps <- 10000
burnInSteps <- 10000
nChains <- 2
numSavedSteps <- 10000
thinSteps <- 1
nIter <- ceiling((numSavedSteps*thinSteps)/nChains)

jagsModel <- jags.model("../Jags/mod3.txt",
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
names(postSamples) <- c(as.character(unique(subDat$Region)),"beta2","tau2alpha")

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
grid.arrange(grobs=vizes,top="Figure 8: Trace Plots for Model 3")

##################################Analysis of final model
justAlphas <- postSamples %>%
  select(-c(beta2,tau2alpha))

#Posterior Samples visual
vizHist <- function(col,name) {
  chain <- as.factor(rep(c(1,2),each=nIter))
  return(ggplot(data=NULL,aes(x=col))+
           geom_histogram()+
           xlab(name)+
           ggtitle(str_c("Post Samps:  ",name))+
           theme(axis.text.x = element_text(size  = 10,
                                            angle = 45,
                                            hjust = 1,
                                            vjust = 1)))
}
vizes <- map2(justAlphas,names(justAlphas),vizHist)
#Just the histograms of the alpha_j
viz1 <- grid.arrange(grobs=vizes)

##Since the logit probability is equal to the alpha j effect, we can do the probability transformation, and then look at the histograms
toProb <- function(alph) {
  return (exp(alph)/(1+exp(alph)))
}

alphProbs <- map_dfc(justAlphas,toProb)

vizes <- map2(alphProbs,names(alphProbs),vizHist)
###Visualization for the probabilities based on the regions [first results figure]
grid.arrange(grobs=vizes,top="Figure 9: Posterior Samples for Alphas")

###95% posterior credible intervals [second results figure]
tab2Show <- map_dfr(alphProbs,quantile,c(.025,.975))
regionPostMeans <- map_dbl(alphProbs,mean)
regionSummary <- dat %>% group_by(Region) %>%
  summarise(medLat = median(Latitude,na.rm=TRUE),medLong = median(Longitude,na.rm=TRUE), medAlongShoreDist = median(AlongShore_Distance,na.rm=TRUE))
regionSummary <- cbind(regionSummary,regionPostMeans)
#saveRDS(tab2Show,"code/Images/table1.rds")

##Beta2 samples
ggplot(data=postSamples,aes(x=beta2))+
  geom_histogram()+xlab("beta2")+ggtitle("Figure 10: Posterior Samples for Beta2")

quantile(postSamples$beta2,c(.025,.975))





























