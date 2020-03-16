#' 
#' 
#' @param data: A tsibble
#' @param central_measure: default median
#' @param var_list: 
#' @param x_lab_list: 
#' @param y_lab_list: 
#' @param trans_list: 
#' @param fill: 
#' @param title_legend_list: 
#' @param THEME: 
#' @param LEGEND: 
#' @param palette
#' @return 

make_boxplot <-function(
  data = NULL, 
  central_measure=median,
  var_list=list("time","epochs","rmse"),
  x_lab_list = list("","",""),
  y_lab_list = list("Time (s)","Epochs","Root Mean Squared Error"),
  trans_list = list("pseudo_log","pseudo_log","pseudo_log"),
  fill = "std_noise",
  title_legend_list = list("Added noise",NULL,NULL),
  THEME = theme_minimal(),
  PALETTE = "Dark2"){
  
  
  for (j in 1:length(var_list)){
    # legend or no legend
    if (is.null(title_legend_list[[j]])){
      LEGEND <- theme(legend.position = "none")
    }
    else{
      LEGEND <- labs(fill = title_legend_list[[j]])
    }
    
    
    # make figure
    p <- ggplot(df, aes(x=train_algo, y = !!dplyr::sym(var_list[[j]]),
      fill = as.factor(!!sym(fill)))) + 
      geom_boxplot() + 
      scale_y_continuous(trans=trans_list[[j]]) + THEME +
      LEGEND +
      scale_fill_brewer(palette=PALETTE) + 
      labs(x = x_lab_list[[j]], y = y_lab_list[[j]]) 
    
    # first figure
    if (j==1){
      fig <- p  }
    # add other figures
    if (j>1){
      fig <- (fig/p)
    }
  }
  
  # return figure
  return(fig)
}


