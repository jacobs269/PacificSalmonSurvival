library(tidyverse)
library(stringr)

pink <- read.csv("data/pinkdata.csv")
pink <- pink %>% 
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

pink$lastR <- grabRecruit(pink)
pink <- pink %>% mutate(survRate = S/lastR)

#elminiate missing values
pink <- pink %>%
  select(Region,AlongShore_Distance,BY,S,lastR) %>%
  mutate(missing = apply(pink,1,anyNA)) %>%
  filter(!missing) %>%
  select(-c(missing)) %>%
  filter(S<=lastR) #There is one row where S exceeds lastR. I think this is just a data entry mistake 

saveRDS(pink,"data/auxPink.rds")







