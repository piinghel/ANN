# clean environment
rm(list=ls())
library(readxl)
library(tidyverse)
library(patchwork)

# own plot library
source("functions/make_boxplot.R")
source("functions/make_barplot.R")

# choose theme
THEME <- theme_minimal()
# remove legend title
LEGEND <- theme(legend.title=element_blank())

df <- read_excel("data/tbl_test.xlsx")


#--------------------------------
# BOXPLOT
#--------------------------------

# noise
make_boxplot(
  data = df, x = 'train_algo',y = list('time','epochs','rmse') ,fill = 'std_noise')
# hidden neurons
make_boxplot(
  data = df, x = 'train_algo',y = list('time','epochs','rmse') , fill = 'hidden_neurons')
# number of samples
make_boxplot(
  data = df, x = 'train_algo',y = list('time','epochs','rmse') , fill = 'num_samples')


#--------------------------------
# Barplot
#--------------------------------


# noise
make_barplot(
  data=df, central_measure=median,
  dispersion=mad, fill="std_noise",
  var_list=list("time","epochs","rmse"),
  y_lab = list("Time (s)","Epochs","RMSE"),
  title_legend = "Added Noise",
  trans = list("pseudo_log","pseudo_log","pseudo_log"))

# number of hidden neurons
make_barplot(
  data=df, central_measure=median,
  dispersion=mad, fill="hidden_neurons",
  var_list=list("time","epochs","rmse"),
  y_lab = list("Time (s)","Epochs","RMSE"),
  title_legend = "# Hidden Neurons",
  trans = list("pseudo_log","pseudo_log","pseudo_log"))

# number of samples
make_barplot(
  data=df, central_measure=median,
  dispersion=mad, fill="num_samples",
  var_list=list("time","epochs","rmse"),
  y_lab = list("Time (s)","Epochs","RMSE"),
  title_legend = "# Hidden Neurons",
  trans = list("pseudo_log","pseudo_log","pseudo_log"))