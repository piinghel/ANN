
#' 
#' 
#' @param data: A tsibble
#' @param x: 
#' @param y: 
#' @param fill: 
#' @param THEME: 
#' @param LEGEND: 
#' 
#' @return 

make_boxplot <- function(data = NULL,
                         x = NULL,
                         y = NULL,
                         fill = NULL, 
                         THEME = theme_minimal(), 
                         LEGEND = theme(legend.title=element_blank())){
  
  
  p_time <- ggplot(data = data, aes(x=!!sym(x), 
    y=!!sym(y[[1]]),fill = as.factor(!!sym(fill)))) + 
    geom_boxplot() + scale_y_continuous(trans='log10') + 
    THEME + labs(fill = "Added noise") + 
    scale_fill_brewer(palette="Dark2") + 
    labs(x = "", y = "Time (s)") 
  
  
  p_epochs <- ggplot(data = data, aes(x=!!sym(x), y=!!sym(y[[2]]),
    fill = as.factor(!!sym(fill)))) + 
    geom_boxplot() + scale_y_continuous(trans='log10') + THEME +
    theme(legend.position = "none")  +
    scale_fill_brewer(palette="Dark2") + 
    labs(x = "", y= "Epochs") 
  
  p_rmse <- ggplot(data = data, aes(x=!!sym(x), y=!!sym(y[[3]]),
    fill = as.factor(!!sym(fill)))) + 
    geom_boxplot(outlier.shape=NA) + 
    scale_y_continuous(trans='log10') + THEME +
    theme(legend.position = "none")  +
    scale_fill_brewer(palette="Dark2") + 
    labs(x = "Training Algorithm", y = "RMSE") 
  
  
  # group figure
  return((p_time/p_epochs/p_rmse))
  

}










