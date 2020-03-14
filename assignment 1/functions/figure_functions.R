

figure_evaluate_boxplot <- function(data,x,y,fill, THEME = theme_minimal(), 
                                    LEGEND = theme(legend.title=element_blank())){
  
  
  p_time <- ggplot(data = data, aes(x=!!sym(x), y=!!sym(y[[1]]),fill = as.factor(!!sym(fill)))) + 
    geom_boxplot() + scale_y_continuous(trans='log10') + 
    THEME + labs(fill = "Added noise") + 
    scale_fill_brewer(palette="Dark2") + labs(x = "Training Algorithm", y = "Time (s)") 
  
  
  p_epochs <- ggplot(data = data, aes(x=!!sym(x), y=!!sym(y[[2]]),fill = as.factor(!!sym(fill)))) + 
    geom_boxplot() + scale_y_continuous(trans='log10') + THEME +
    theme(legend.position = "none")  +
    scale_fill_brewer(palette="Dark2") + 
    labs(x = "Training Algorithm") 
  
  p_rmse <- ggplot(data = data, aes(x=!!sym(x), y=!!sym(y[[3]]),fill = as.factor(!!sym(fill)))) + 
    geom_boxplot(outlier.shape=NA) + scale_y_continuous(trans='exp') + THEME +
    theme(legend.position = "none")  +
    scale_fill_brewer(palette="Dark2") + 
    labs(x = "Training Algorithm", y = "RMSE") 
  
  
  # group figure
  return((p_time/p_epochs/p_rmse))
  
  
}





figure_evaluate_barplot <-function(data, central_measure=median, 
                                   var_list=list("time","epochs","rmse"),
                                   y_lab = list("Time (s)","Epochs","Root Mean Squared Error"),
                                   dispersion=mad, 
                                   trans = list("pseudo_log","pseudo_log","pseudo_log"),
                                   fill = "std_noise",
                                   title_legend = "Added noise",
                                   THEME = theme_minimal(), 
                                   LEGEND = theme(legend.title=element_blank())){
  
  df <- df %>% dplyr::group_by(!!sym(fill), train_algo) %>%
    summarise(
      # time
      central_measure_var1 = central_measure(!!sym(var_list[[1]])),
      
      # epochs
      central_measure_var2 = central_measure(!!sym(var_list[[2]])),
      
      # mse
      central_measure_var3 = central_measure(!!sym(var_list[[3]]))
      
    )
  
  # var 1
  p_var1 <- ggplot(df, aes(x=train_algo, y=central_measure_var1,fill = as.factor(!!sym(fill)))) + 
    geom_bar(stat="identity", color="black", position=position_dodge()) + 
    scale_y_continuous(trans=trans[[1]]) + 
    THEME + labs(fill = title_legend)  +
    scale_fill_brewer(palette="Dark2") + 
    labs(x = "Training Algorithm", y = y_lab[[1]]) 
  
  p_var2 <- ggplot(df, aes(x=train_algo, y=central_measure_var2,fill = as.factor(!!sym(fill)))) + 
    geom_bar(stat="identity", color="black", position=position_dodge()) + 
    THEME + theme(legend.position = "none")  +
    scale_y_continuous(trans=trans[[2]]) + 
    scale_fill_brewer(palette="Dark2") + 
    labs(x = "Training Algorithm", y = y_lab[[2]]) 
  
  
  p_var3 <- ggplot(df, aes(x=train_algo, y=central_measure_var3,fill = as.factor(!!sym(fill)))) + 
    geom_bar(stat="identity", color="black", position=position_dodge()) + 
    THEME + theme(legend.position = "none") +
    scale_fill_brewer(palette="Dark2") +
    scale_y_continuous(trans=trans[[3]]) + 
    labs(x = "Training Algorithm", y = y_lab[[3]]) 
  
  
  # overview plot
  return((p_var1/p_var2/p_var3))
  
  
}




