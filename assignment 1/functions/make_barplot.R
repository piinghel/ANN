#'
#'
#' @param data: Tsibble
#' @param x: Character
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




make_barplot <- function(data = NULL,
                         x = "train_algo",
                         central_measure = stats::median,
                         var_list = list("time", "epochs", "rmse"),
                         x_lab_list = list("", "", ""),
                         y_lab_list = list("Time (s)", "Epoch", "RMSE"),
                         trans_list = list("pseudo_log", "pseudo_log", "pseudo_log"),
                         fill = "std_noise",
                         title_legend_list = list("Added noise", NULL, NULL),
                         THEME = theme_gray(),
                         PALETTE = "Dark2",
                         LEGEND_POSITION = "top") {
  for (j in 1:length(var_list)) {
    # legend or no legend
    if (is.null(title_legend_list[[j]])) {
      LABS <- labs(fill = "") 
      LEGEND <- theme(legend.position = "none")
    }
    else{
      LABS <- labs(fill = title_legend_list[[j]]) 
      LEGEND <- theme(legend.position = LEGEND_POSITION)
    }
    
    df_sum <-
      data %>% dplyr::group_by(!!dplyr::sym(fill),!!dplyr::sym(x)) %>%
      dplyr::summarise(# var  e.g. time
        central_measure = central_measure(!!dplyr::sym(var_list[[j]])))
    
    
    # make figure
    p <- ggplot(data = df_sum,
                aes(
                  x = !!dplyr::sym(x),
                  y = central_measure,
                  fill = as.factor(!!dplyr::sym(fill))
                )) +
      geom_bar(stat = "identity",
               color = "black",
               position = position_dodge()) +
      THEME + LEGEND + LABS + 
      scale_fill_brewer(palette = "Dark2") +
      scale_y_continuous(trans = trans_list[[j]]) +
      labs(x = x_lab_list[[j]], y = y_lab_list[[j]])
    
    # first figure
    if (j == 1) {
      fig <- p
    }
    # add other figures
    if (j > 1) {
      fig <- (fig / p)
    }
  }
  
  # return figure
  return(fig)
}
