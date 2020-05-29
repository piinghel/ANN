# clean environment
rm(list = ls())
library(readxl)
library(tidyverse)
library(patchwork)
library(plyr)

# own plot library
source("functions/make_boxplot.R")
source("functions/make_barplot.R")


#--------------------------------
# global paramaters
#--------------------------------
# choose theme
THEME <- theme_gray() #theme_minimal()
# remove legend title
LEGEND <- theme(legend.title = element_blank())

#--------------------------------
# Part 1
#--------------------------------


df1 <- read_excel("output/part1.xlsx")

df1 %>% dim()

df1 %>% head()

#--------------------------------
# BOXPLOT
#--------------------------------

# noise
make_boxplot(
  data = df1,
  var_list = list('time', 'best_epoch', 'mse_val') ,
  fill = 'sd'
)
# hidden neurons
make_boxplot(
  data = df1,
  var_list = list('time', 'best_epoch', 'mse_val') ,
  fill = 'hidden_size'
)
# number of samples
make_boxplot(
  data = df1,
  var_list = list('time', 'best_epoch', 'mse_val') ,
  fill = 'num_samples'
)


#--------------------------------
# Barplot
#--------------------------------


# number of hidden neurons
make_barplot(
  data = df1,
  x = "train_algo",
  var_list = list('time', 'best_epoch', 'mse_val') ,
  x_lab_list = list("", "", "Training Algorithm"),
  y_lab_list = list("Time (s)", "# Epochs", "MSE Validation"),
  fill = 'hidden_size',
  trans_list = list("sqrt", "pseudo_log", "pseudo_log"),
  title_legend_list = list("Number of Neurons", NULL, NULL)
)
ggsave(
  "output/figure1.png",
  units = "cm",
  height = 16,
  width = 11
)


# noise
make_barplot(
  data = df1,
  x = "train_algo",
  var_list = list('time', 'best_epoch', 'mse_val') ,
  x_lab_list = list("", "", "Training Algorithm"),
  y_lab_list = list("Time (s)", "# Epochs", "MSE Validation"),
  fill = 'sd',
  trans_list = list("sqrt", "pseudo_log", "pseudo_log"),
  title_legend_list = list("Noise Level", NULL, NULL)
)
ggsave(
  "output/figure2.png",
  units = "cm",
  height = 16,
  width = 11
)



# number of samples
make_barplot(
  data = df1,
  x = "train_algo",
  var_list = list('time', 'best_epoch', 'mse_val') ,
  x_lab_list = list("", "", "Training Algorithm"),
  y_lab_list = list("Time (s)", "# Epochs", "MSE Validation"),
  fill = 'num_samples',
  trans_list = list("sqrt", "pseudo_log", "pseudo_log"),
  title_legend_list = list("Number of samples", NULL, NULL)
)
ggsave(
  "output/figure3.png",
  units = "cm",
  height = 16,
  width = 11
)

# not exactly the same, but doesn't differ that much
df1 %>% dplyr::group_by(fold,train_algo,hidden_size) %>%
  dplyr::summarise(central_measure = median(mse_val)) %>%
  dplyr::group_by(train_algo,hidden_size) %>% 
  dplyr::summarise(median_mse = median(central_measure))

df1 %>% dplyr::group_by(train_algo,hidden_size) %>% 
  dplyr::summarise(median_mse = median(mse_val))

#--------------------------------
# Part 2
#--------------------------------

df2 <- read_excel("output/part2.xlsx")

df2 %>% dim()

df2 %>% head()

# find best parameters: trainbr, 50 hidden size, logsig of transig
best_params <-
  df2 %>% dplyr::group_by(repetition, hidden_size, transfer_func, train_algos) %>%
  dplyr::summarise(
    mse_val_mean = mean(mse_val),
    mean_time = mean(time),
    mean_epoch = mean(best_epoch)
  )

best_params %>% arrange(mse_val_mean)

# transfer_func
make_barplot(
  data = df2,
  x = "train_algos",
  var_list = list('time', 'mse_val') ,
  x_lab_list = list("", "Training Algorithm"),
  y_lab_list = list("Time (s)", "MSE Validation"),
  trans_list = list("log10", "log10"),
  fill = 'transfer_func',
  title_legend_list = list("Transfer Function", NULL)
)
ggsave(
  "output/figure4.png",
  units = "cm",
  height = 14,
  width = 11
)

make_barplot(
  data = df2,
  x = "train_algos",
  var_list = list('time', 'mse_val') ,
  x_lab_list = list("", "Training Algorithm"),
  y_lab_list = list("Time (s)", "MSE Validation"),
  trans_list = list("log10", "log10"),
  fill = 'hidden_size',
  title_legend_list = list("Size Hidden Layer", NULL)
)
ggsave(
  "output/figure5.png",
  units = "cm",
  height = 14,
  width = 11
)


# boxplot performance training/validation
keycol <- "dataset"
valuecol <- "mse"
gathercols <- c("mse_train", "mse_val")

df2_new <- gather_(df2, keycol, valuecol, gathercols)
df2_new$dataset <- mapvalues(df2_new$dataset, from = c("mse_train", "mse_val"), to = c("train", "validation"))

# visualize performance on trainng and validaton data
ggplot(df2_new, aes(x = train_algos, y = mse, fill = dataset)) +
  geom_boxplot() + scale_y_continuous(trans = "log10") +
  scale_fill_brewer(palette = "Dark2") + labs(x="Training Algorithm", y = "MSE") +
  theme(legend.position = "top") + labs(fill = "Dataset")
ggsave(
  "output/figure6.png",
  units = "cm",
  height = 14,
  width = 11
)



#--------------------------------
# Part 3
#--------------------------------

df1$sd <-
  as.factor(mapvalues(
    df1$sd,
    from = c("0", "0.1", "0.2", "0.3"),
    to = c("noise = 0", "noise = 0.1", "noise = 0.2", "noise = 0.3")
  ))


df1 %>% dplyr::group_by(train_algo, sd, hidden_size) %>%
  dplyr::summarise(mse_val = (median(mse_val)) ** (1 / 2)) %>% ggplot(., aes(
    x = train_algo,
    y = mse_val,
    fill = as.factor(hidden_size)
  )) +
  geom_bar(stat = "identity",
           color = "black",
           position = position_dodge()) +
  THEME +
  scale_fill_brewer(palette = "Dark2") +
  scale_y_continuous(trans = "sqrt") +
  labs(x = "", y = "") +
  facet_grid(sd~., scales = 'free') +
  labs(x = "Training Algorithm", y = "MSE Valdiation", fill = "# Neurons") +
  theme(legend.position="top")

ggsave(
  "output/figure7.png",
  units = "cm",
  height = 20,
  width = 15
)
