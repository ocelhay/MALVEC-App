
# library(formattable)  # version 0.1.7 onwards (not needed here)
library(dplyr)
library(tidyr)
library(ggplot2)
library(RColorBrewer)
library(sp)
library(leaflet)
library(car)

library(shiny)
library(DT)  # should be called after shiny

load(file='./www/data/MALVEC_light.RData')

list_primary_vec <- gsub("[[:space:]]", "_", unique((df_BR %>% filter(Status=='Primary vector'))$Species))
names(list_primary_vec) <- unique((df_BR %>% filter(Status=='Primary vector'))$Species)
list_secondary_vec <- gsub("[[:space:]]", "_", unique((df_BR %>% filter(Status=='Secondary vector'))$Species))
names(list_secondary_vec) <- unique((df_BR %>% filter(Status=='Secondary vector'))$Species)