library(tidyverse)

data <- read.csv('/Users/imyerssmith/Desktop/nobel_prize_data.csv')

head(data)

(plot <- ggplot(data) +
    geom_boxplot(aes(x= continent, y= nobel_prizes, fill = continent), colour = "black", size = 0.5, alpha = 0.5) +
    ylab("Nobel Prizes\n") +
    xlab("\nContinents") +
    theme_bw() +
    theme(panel.border = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
          axis.line = element_line(colour = "black")))
#testing making comments 
