
# --------------------------------------------------------------------------
# Libraries
# --------------------------------------------------------------------------

library(readxl)
library(dplyr)

library(ggplot2)
library(tidyr)
library(patchwork)

# --------------------------------------------------------------------------
# Import data
# --------------------------------------------------------------------------

X3_layers <- read_excel("output/part2_auto_encoders/3_layers.xlsx")
X4_layers <- read_excel("output/part2_auto_encoders/4_layers.xlsx")


# --------------------------------------------------------------------------
# Auto encoder with 3 layers
# --------------------------------------------------------------------------


X3_layers <- X3_layers %>% 
  unite(neurons_hidden, c(hiddenSize1, hiddenSize2), sep = '-', remove = FALSE) %>%
  unite(nr_epochs, c(Max_epoch1, Max_epoch2, Max_epoch3), sep = '-', remove = FALSE)


p1_3 <- X3_layers %>% select(neurons_hidden, nr_epochs, classAcc, hiddenSize1, Max_epoch1) %>%
  group_by(neurons_hidden, nr_epochs, hiddenSize1, Max_epoch1) %>%
  summarise(median_classAcc = 100 - median(classAcc)) %>%
  ggplot(., aes(x=reorder(as.factor(neurons_hidden), hiddenSize1),y=median_classAcc, fill=reorder(as.factor(nr_epochs),Max_epoch1))) +
  geom_bar(stat="identity", color="black", position=position_dodge()) + 
  scale_y_continuous(trans='pseudo_log') +
  scale_fill_brewer(palette="Dark2") + 
  labs(fill="# Epochs",x="", y="Median Class Error (%)")


p2_3 <- X3_layers %>% select(neurons_hidden, nr_epochs, time, hiddenSize1, Max_epoch1) %>%
  group_by(neurons_hidden, nr_epochs, hiddenSize1, Max_epoch1) %>%
  summarise(median_time = median(time)) %>%
  ggplot(., aes(x=reorder(as.factor(neurons_hidden), hiddenSize1),y=median_time, fill=reorder(as.factor(nr_epochs),Max_epoch1))) +
  geom_bar(stat="identity", color="black", position=position_dodge()) + 
  scale_fill_brewer(palette="Dark2") + 
  #scale_y_continuous(trans='pseudo_log') +
  labs(fill="# Epochs",x="# Neurons Hidden Layers", y="Median Time (s)")

# group plots
p1_3 / p2_3 + plot_layout(guides = "collect") 
# save
ggsave("output/part2_auto_encoders/figure1.png", width = 14, height = 14, units = "cm")

# --------------------------------------------------------------------------
# Auto encoder with 4 layers
# --------------------------------------------------------------------------

X4_layers <- X4_layers %>% 
  unite(neurons_hidden, c(hiddenSize1, hiddenSize2, hiddenSize3), sep = '-', remove = FALSE) %>%
  unite(nr_epochs, c(Max_epoch1, Max_epoch2, Max_epoch3, Max_epoch4), sep = '-', remove = FALSE)

p1_4 <- X4_layers %>% select(neurons_hidden, nr_epochs, classAcc, hiddenSize1, Max_epoch1) %>%
  group_by(neurons_hidden, nr_epochs, hiddenSize1, Max_epoch1) %>%
  summarise(median_classErr = 100 - median(classAcc)) %>%
  ggplot(., aes(x=reorder(as.factor(neurons_hidden), hiddenSize1),y=median_classErr, fill=reorder(as.factor(nr_epochs),Max_epoch1))) +
  geom_bar(stat="identity", color="black", position=position_dodge()) + 
  #scale_y_continuous(trans='pseudo_log') + 
  scale_fill_brewer(palette="Dark2") + 
  labs(fill="# Epochs",x="", y="Median Class Error (%)")


p2_4 <- X4_layers %>% select(neurons_hidden, nr_epochs, time, hiddenSize1, Max_epoch1) %>%
  group_by(neurons_hidden, nr_epochs, hiddenSize1, Max_epoch1) %>%
  summarise(median_time = median(time)) %>%
  ggplot(., aes(x=reorder(as.factor(neurons_hidden), hiddenSize1),y=median_time, fill=reorder(as.factor(nr_epochs),Max_epoch1))) +
  geom_bar(stat="identity", color="black", position=position_dodge()) + 
  scale_fill_brewer(palette="Dark2") + 
  labs(fill="# Epochs",x="# Neurons Hidden Layers", y="Median Time (s)")

# group plots
p1_4 / p2_4 + plot_layout(guides = "collect") 
# save
ggsave("output/part2_auto_encoders/figure2.png", width = 14, height = 14, units = "cm")




