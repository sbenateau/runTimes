########################################################
#
# Compare speed between loop, apply and  colSums
#       Plot script
#
# Simon Benateau 05.03.2019
#
######################################################

# packages to plot results
library(ggplot2)
library(gridExtra)
library(dplyr)
library(tidyr)


#load data
dataTime <- read.table("runTimes.tsv", sep = "\t", header = TRUE)

dataTime$Function <- relevel(dataTime$Function,"colSums")
dataTime <- subset(dataTime, Nrow > 10 & Ncol > 10)
plot1 <- ggplot(dataTime, aes(x = as.factor(Ncol), y = Time))+
  geom_violin(aes(color = Function, fill = Function))+
  facet_grid(Type~Nrow, labeller = label_both)+
  # scale_x_continuous(trans='log10', labels = function(x) format(x, scientific = TRUE))+
  scale_y_continuous(trans='log10')+
  labs(x = "Column number in the object")+
  labs(y = "Execution time")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

png("runTimesCompare.png", width = 800, height = 600)
plot1
dev.off()

#Calculate execution time ratio between functions
dataTimeSummary <- dataTime %>%
  group_by(Function,Ncol,Nrow,Type) %>%
  summarise(meanTime = mean(Time)) %>%
  spread(Function,meanTime) %>%
  mutate(loopVScolSums = loop/colSums)%>%
  mutate(applyVScolSums = apply/colSums)%>%
  mutate(applyVSloop = apply/loop)



plot1 <- ggplot(dataTimeSummary, aes(x = Ncol, y = applyVSloop))+
  geom_line()+
  geom_hline(yintercept=1, linetype="dashed", 
             color = "red", size=1)+
  geom_point()+
  scale_x_continuous(trans='log10', 
                     labels = function(x) format(x, scientific = TRUE))+
  scale_y_continuous(trans='log10')+
  facet_grid(Type~Nrow, labeller = label_both) +
  labs(x = "Column number in the matrix")+
  labs(y = "apply / loop execution time ratio")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

plot2 <- ggplot(dataTimeSummary, aes(x = Ncol, y = loopVScolSums))+
  geom_line()+
  geom_hline(yintercept=1, linetype="dashed", 
             color = "red", size=1)+
  geom_point()+
  scale_x_continuous(trans='log10', 
                     labels = function(x) format(x, scientific = TRUE))+
  scale_y_continuous(trans='log10')+
  facet_grid(Type~Nrow, labeller = label_both) +
  labs(x = "Column number in the matrix")+
  labs(y = "loop / colSums execution time ratio")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

plot3 <- ggplot(dataTimeSummary, aes(x = Ncol, y = applyVScolSums))+
  geom_line()+
  geom_hline(yintercept=1, linetype="dashed", 
             color = "red", size=1)+
  geom_point()+
  scale_x_continuous(trans='log10', 
                     labels = function(x) format(x, scientific = TRUE))+
  scale_y_continuous(trans='log10')+
  facet_grid(Type~Nrow, labeller = label_both) +
  labs(x = "Column number in the matrix")+
  labs(y = "apply / colSums execution time ratio")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

png("runTimesRatio.png", width = 800, height = 600)
grid.arrange(plot1, plot2, plot3, ncol = 3)
dev.off()