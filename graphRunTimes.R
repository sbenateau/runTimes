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
library(dplyr)
library(tidyr)



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
plot1

plot2 <- ggplot(dataTime, aes(x = Type, y = Time))+
  geom_violin(aes(fill = Function))+
  scale_y_continuous(trans='log10')+
  labs(x = "Data type")+
  labs(y = "Execution time")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
plot2

#calculate ratios
dataTime2 <- dataTime %>%
  select(expr, mean, nrow, ncol) %>%
  spread(expr,mean) %>%
  mutate(loopVsApply = loop / apply)  %>%
  mutate(loopVsColsums = loop / colSums)  %>%
  mutate(applyVsColsums = apply / colSums)


plot2 <- ggplot(dataTime2, aes(x = ncol, y = loopVsApply))+
  geom_line()+
  geom_hline(yintercept=1, linetype="dashed", 
             color = "red", size=1)+
  geom_point()+
  scale_x_continuous(trans='log10', labels = function(x) format(x, scientific = TRUE))+
  scale_y_continuous(trans='log10')+
  facet_grid(.~nrow, labeller = label_both) +
  labs(x = "Column number in the matrix")+
  labs(y = "Loop / Apply executation time ratio")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


plot3 <- ggplot(dataTime2, aes(x = ncol, y = loopVsColsums))+
  geom_line()+
  geom_hline(yintercept=1, linetype="dashed", 
             color = "red", size=1)+
  geom_point()+
  scale_x_continuous(trans='log10', labels = function(x) format(x, scientific = TRUE))+
  scale_y_continuous(trans='log10')+
  facet_grid(.~nrow, labeller = label_both) +
  labs(x = "Column number in the matrix")+
  labs(y = "Loop / colSums executation time ratio")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

plot4 <- ggplot(dataTime2, aes(x = ncol, y = applyVsColsums))+
  geom_line()+
  geom_hline(yintercept=1, linetype="dashed", 
             color = "red", size=1)+
  geom_point()+
  scale_x_continuous(trans='log10', labels = function(x) format(x, scientific = TRUE))+
  scale_y_continuous(trans='log10')+
  facet_grid(.~nrow, labeller = label_both) +
  labs(x = "Column number in the matrix")+
  labs(y = "Apply / colSums executation time ratio")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

grid.arrange(plot1, plot2, plot3, plot4)