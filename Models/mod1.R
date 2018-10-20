library(rjags)
library(tidyverse)
library(ggplot2)
library(stringr)
library(gridExtra)

subDat <- readRDS("../data/auxPink.rds")

#####Begin organize data
nRow <- nrow(subDat)
s <- as.integer(subDat$S*1000)
n <- as.integer(subDat$lastR*1000)
region <- as.numeric(subDat$Region)
nReg <- length(unique(region))
#time <- subDat$BY

####Begin Setting up values for jags
dataList <- list(
  'nRow' = nRow,
  "n" = n,
  "s" = s,
  "region" = region,
  "nReg" = nReg)


parameters <- c(
  "alpha"
)

initsValues <- list(
  "alpha" = rep(0,nReg)
)

adaptSteps <- 10000
burnInSteps <- 10000
nChains <- 2
numSavedSteps <- 10000
thinSteps <- 1
nIter <- ceiling((numSavedSteps*thinSteps)/nChains)

jagsModel <- jags.model("../Jags/mod1.txt",
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
names(postSamples) <- c(as.character(unique(subDat$Region)))

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
grid.arrange(grobs=vizes,top="Figure 6: Trace Plots for Model 1")
























