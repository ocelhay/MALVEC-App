# server.R

shinyServer(
  
  function(session, input, output) {
    
    
    # recommended to stop the R process & R when the browser is closed - http://www.r-bloggers.com/deploying-desktop-apps-with-r/
    # -------------------------------------------------------------------------------------------------
    session$onSessionEnded(function() {
      stopApp()
      # q("no")  # terminate the R session - only for offline deployment
    })
    
    
    # MALVEC sections
    # -------------------------------------------------------------------------------------------------
    output$map_malvec_sites <- renderLeaflet({
      
      return(leaflet(shp_lao_prov) %>% 
               setView((bb_shp_lao[1,1]+bb_shp_lao[1,2])/2, (bb_shp_lao[2,1]+bb_shp_lao[2,2])/2, zoom=6) %>%
               addProviderTiles('OpenStreetMap.BlackAndWhite', group = "Open Street Map") %>%
               addProviderTiles("Esri.WorldImagery", group = "Satellite") %>%
               addProviderTiles("Esri.WorldTopoMap", group = "Topo") %>%
               addPolygons(fillOpacity=0.3, weight=2, color='black', fillColor=shp_lao_prov$col_MALVEC) %>%
               addPolygons(data=shp_ubon_prov, fillOpacity=0.3, weight=2, color='black', fillColor='pink') %>%
               addMarkers(data=sites_lao, lng=~Lon, lat=~Lat, popup=~popup) %>%
               addMarkers(data=sites_thai, lng=~Lon, lat=~Lat, popup=~popup) %>%
               addLayersControl(
                 baseGroups = c("Open Street Map", "Satellite", "Topo"),
                 options = layersControlOptions(collapsed = FALSE))
      )
      
    })
    
    output$map_malvec_sites_2 <- renderLeaflet({
      
      return(leaflet(shp_lao_prov) %>% 
               setView((bb_shp_lao[1,1]+bb_shp_lao[1,2])/2, (bb_shp_lao[2,1]+bb_shp_lao[2,2])/2, zoom=6) %>%
               addProviderTiles('OpenStreetMap.BlackAndWhite', group = "Open Street Map") %>%
               addProviderTiles("Esri.WorldImagery", group = "Satellite") %>%
               addProviderTiles("Esri.WorldTopoMap", group = "Topo") %>%
               addPolygons(fillOpacity=0.3, weight=2, color='black', fillColor=shp_lao_prov$col_MALVEC) %>%
               addPolygons(data=shp_ubon_prov, fillOpacity=0.3, weight=2, color='black', fillColor='pink') %>%
               addMarkers(data=sites_lao, lng=~Lon, lat=~Lat, popup=~popup) %>%
               addMarkers(data=sites_thai, lng=~Lon, lat=~Lat, popup=~popup) %>%
               addLayersControl(
                 baseGroups = c("Open Street Map", "Satellite", "Topo"),
                 options = layersControlOptions(collapsed = FALSE))
      )
      
    })
    
    output$map_malvec_abundance <- renderLeaflet(
      leaflet(shp_ubon_subdist) %>% 
        setView((bb_shp_lao[1,1]+bb_shp_lao[1,2])/2, (bb_shp_lao[2,1]+bb_shp_lao[2,2])/2, zoom=6) %>%
        addProviderTiles("Esri.WorldGrayCanvas") %>%
        addPolygons(fillOpacity=0.8, weight=2, color='black', fillColor=~pal_abundance(Total.all), popup=~all, group='All Seasons') %>%
        # addPolygons(fillOpacity=0.8, weight=2, color='black', fillColor=~pal_abundance(Total.dry), popup=~dry, group='Dry Season') %>%
        # addPolygons(fillOpacity=0.8, weight=2, color='black', fillColor=~pal_abundance(Total.rainy), popup=~rainy, group='Rainy Season') %>%
        addPolygons(data=shp_lao_prov, fillOpacity=0.8, weight=2, color='black', fillColor=~pal_abundance(Total.all), popup=~all, group='All Seasons') %>%
        # addPolygons(data=shp_lao_prov, fillOpacity=0.8, weight=2, color='black', fillColor=~pal_abundance(Total.dry), popup=~dry, group='Dry Season') %>%
        # addPolygons(data=shp_lao_prov, fillOpacity=0.8, weight=2, color='black', fillColor=~pal_abundance(Total.rainy), popup=~rainy, group='Rainy Season') %>%
        # # addPolygons(data=shp_ubon_subdist, fillOpacity=0.3, weight=2, color='black', dashArray='5, 10', fillColor='transparent') %>%
        # addLayersControl(
        #   baseGroups = c("All Seasons", "Dry Season", "Rainy Season"),
        #   options = layersControlOptions(collapsed = FALSE)) %>%
        addLegend('bottomleft', pal = pal_abundance, values=~Total.all, title = 'Anopheles <br> specimen <br> collected', labFormat=labelFormat(), opacity=1)
    )
    
    
    # Interaction with the map of abundance
    map <- reactiveValues(Pcode='', Aunit='')
    observeEvent(input$map_malvec_abundance_shape_click, {
      map$Pcode <- over(SpatialPoints(cbind(input$map_malvec_abundance_shape_click$lng, input$map_malvec_abundance_shape_click$lat)), shp_lao_prov)$Pcode
      map$Aunit <- over(SpatialPoints(cbind(input$map_malvec_abundance_shape_click$lng, input$map_malvec_abundance_shape_click$lat)), shp_ubon_subdist)$Aunit
    })
    
    # output$text_map_click <- renderText({paste0('clicked Pcode: ', map$Pcode, ' - clicked Aunit: ', map$Aunit)})
    output$text_map_click <- renderText({if(map$Pcode == '' & map$Aunit == '') return('<h4>Click on the map to display info.</h4>')})
    
    output$plot_malvec_abundance <- renderPlot({
      plot_malvec_abundance <- NULL
      if(map$Pcode %in% sites_lao$Acode){
        plot_malvec_abundance <- ggplot(vectors_lao %>% 
                                          filter(Total>0, Acode == map$Pcode) %>%
                                          group_by(Province, Species, Season) %>% 
                                          summarise(Total=sum(Total, na.rm=T)),  # dataset
                                        aes(Species, Total, fill=Season)) +  # aesthetic
          geom_bar(stat='identity') +
          xlab(NULL) + ylab(NULL) +  # axis labeling
          ggtitle(NULL) +  # title
          facet_wrap(~Province, ncol=2, scales='free') +
          scale_y_continuous(limits=c(0, NA), labels=scales::comma) +  # y-axis
          guides(fill=guide_legend(title='Season of collection: ')) +  # legend
          scale_fill_manual(values=brewer.pal(11, 'RdYlBu')[c(3, 9)]) +
          theme_bw() +  # default theme
          theme(axis.text=element_text(size=rel(.9)), 
                axis.text.x=element_text(angle=45, hjust=1, face='italic'),
                axis.title=element_text(size=rel(1)), 
                legend.text=element_text(size=rel(1)), 
                legend.title=element_text(size=rel(1)),
                legend.position= 'top',
                plot.margin = unit(c(1,1,1,1), "cm"))
      }
      if(map$Aunit %in% sites_thai$Subdistrict){
        plot_malvec_abundance <- ggplot(vectors_thai %>%
                                          filter(Total>0, Subdistrict == map$Aunit) %>%
                                          group_by(Subdistrict, Species, Season) %>%
                                          summarise(Total=sum(Total, na.rm=T)),  # dataset
                                        aes(Species, Total, fill=Season)) +  # aesthetic
          geom_bar(stat='identity') +  # type
          xlab(NULL) + ylab(NULL) +  # axis labeling
          ggtitle(NULL) +  # title
          facet_wrap(~Subdistrict, ncol=2, scales='free') +
          scale_y_continuous(limits=c(0, NA), labels=scales::comma) +  # y-axis
          guides(fill=guide_legend(title='Season of collection: ')) +  # legend
          scale_fill_manual(values=brewer.pal(11, 'RdYlBu')[c(3, 9)]) +
          theme_bw() +  # default theme
          theme(axis.text=element_text(size=rel(.9)),
                axis.text.x=element_text(angle=45, hjust=1, face='italic'),
                axis.title=element_text(size=rel(1)),
                legend.text=element_text(size=rel(1)),
                legend.title=element_text(size=rel(1)),
                legend.position= 'top',
                plot.margin = unit(c(1,1,1,1), "cm")
          )
      }
      return(plot_malvec_abundance)
    }
    )
    
    output$table_malvec_abundance <- renderDataTable({
      dt <- datatable(df_abundance %>% transmute(Country=as.factor(Country), Aggregation_Unit=as.factor(Aggregation_Unit), Species_link, Status=as.factor(Status), Season=as.factor(Season), Rel_Abundance), 
                      filter='top',
                      colname=c('Country', 'Province (Lao) / Subdistrict (Thai)', 'Species', 'Vector Status', 'Season', 'Relative Abundance'),
                      escape=F,
                      rownames=F,
                      selection='none',
                      options=list(searching=T)) %>%
        formatStyle('Season', backgroundColor = styleEqual(c('dry', 'rainy', 'all'), brewer.pal(11, 'RdYlBu')[c(3, 9, 5)])) %>%
        formatPercentage('Rel_Abundance', digits=2) %>%
        formatStyle('Rel_Abundance', background=styleColorBar(df_abundance$Rel_Abundance, brewer.pal(9, 'Greys')[4]))
      
      return(dt)
    }
    )
    
    output$map_malvec_ir <- renderLeaflet(
      leaflet(shp_lao_prov) %>% 
        setView((bb_shp_lao[1,1]+bb_shp_lao[1,2])/2, (bb_shp_lao[2,1]+bb_shp_lao[2,2])/2, zoom=6) %>%
        addProviderTiles("Esri.WorldGrayCanvas") %>%
        addPolygons(data=shp_ubon_prov, fillOpacity=0.3, weight=2, color='black', dashArray='5, 10', fillColor='transparent') %>%
        addPolygons(data=shp_ubon_subdist, fillOpacity=0.8, weight=2, color='black', fillColor=~Color.Del, popup=~popup.Del, group='Deltamethrin') %>%
        addPolygons(data=shp_ubon_subdist, fillOpacity=0.8, weight=2, color='black', fillColor=~Color.DDT, popup=~popup.DDT, group='DDT') %>%
        addPolygons(data=shp_ubon_subdist, fillOpacity=0.8, weight=2, color='black', fillColor=~Color.Per, popup=~popup.Per, group='Permethrin') %>%
        addPolygons(fillOpacity=0.8, weight=2, color='black', fillColor=~Color.Del, popup=~popup.Del, group='Deltamethrin') %>%
        addPolygons(fillOpacity=0.8, weight=2, color='black', fillColor=~Color.DDT, popup=~popup.DDT, group='DDT') %>%
        addPolygons(fillOpacity=0.8, weight=2, color='black', fillColor=~Color.Per, popup=~popup.Per, group='Permethrin') %>%
        addLayersControl(
          baseGroups = c('Deltamethrin', 'DDT', "Permethrin"),
          options = layersControlOptions(collapsed = FALSE)) %>%
        addLegend('bottomleft', colors = c(brewer.pal(11, 'RdYlGn')[c(2, 5, 9)], brewer.pal(9, 'Greys')[3]), labels=c('Resistant', 'Suspected resistance', 'Susceptible', 'Not Tested'), title = 'At least one species:', opacity=0.8)
    )
    
    output$table_malvec_ir <- renderDataTable(
      datatable(left_join(ir, all_sites, by='Site') %>% 
                  transmute(Country=as.factor(Country), Aunit=as.factor(Aunit), Species=paste0('<em>', Species, '</em>'), Status=as.factor(Status), Insecticide=as.factor(Insecticide), Insec_Status=as.factor(Insec_Status), Mortality, Number_Tested), 
                filter='top',
                colname=c('Country', 'Province (Lao) / Subdistrict (Thai)', 'Species', 'Species Status', 'Insecticide', 'Insec. Status', 'Mortality', 'N'),
                rownames=F,
                escape=F,
                extensions='Scroller',
                selection='none',
                options=list(pageLength=18)) %>%
        formatPercentage('Mortality', digits=1) %>% 
        formatStyle('Insec_Status', backgroundColor = styleEqual(c('Resistant', 'Suspected resistance', 'Susceptible', 'Not Tested'), c(brewer.pal(11, 'RdYlGn')[c(2, 5, 9)], brewer.pal(9, 'Greys')[3]))) %>%
        formatStyle('Insecticide', backgroundColor = styleEqual(unique(ir$Insecticide), brewer.pal(3, 'Pastel1')))
    )
    
    # HBR map
    map_hbr <- reactive({
      shp_lao_prov@data <- shp_lao_prov@data %>% mutate_(species=input$species)
      shp_ubon_subdist@data <- shp_ubon_subdist@data %>% mutate_(species=input$species)
      palette <- colorNumeric(palette = rev(brewer.pal(n=11, name='RdYlBu')), domain = c(0, 0.5), na.color = 'transparent')
      
      return(leaflet(shp_lao_prov) %>% 
               addProviderTiles('Esri.WorldGrayCanvas') %>%
               addPolygons(fillOpacity=1, dashArray=1, weight=1.5, color='#B6BCB3', popup=paste0('Human Biting Rate, <em>', input$species, '</em>:<br>', format(round(shp_lao_prov$species, 2), nsmall=2), ' mosquitoes/man/night.'), fillColor=~palette(species)) %>%
               addPolygons(data=shp_ubon_subdist, fillOpacity=1, dashArray=1, weight=1.5, color='#B6BCB3', popup=paste0('Human Biting Rate, ', input$species, ':<br>', format(round(shp_ubon_subdist$species, 2), nsmall=2), ' mosquitoes/man/night.'), fillColor=~palette(species)) %>%
               addLegend('bottomleft', pal = palette, values=c(0, 0.5), title='Human Biting Rate', opacity=1)
      )
    })
    
    output$map_malvec_hbr <- renderLeaflet(map_hbr())
    
    
    output$table_malvec_brb_1 <- renderDataTable(
      datatable(df_BR %>% select(Country, Aunit, Status, Species, Total_Bites_H, Total_Bites_C, HBR, HBR_indoor, HBR_outdoor, CBR) %>%
                  mutate(Country=as.factor(Country), Aunit=as.factor(Aunit), Status=as.factor(Status), Species=paste0('<em>', Species, '</em>')), 
                filter='top',
                colname=c('Country', 'Province (Lao) / Subdistrict (Thai)', 'Vector Status', 'Species', 'Total Bites Human', 'Total Bites Cow', 'Human Biting Rate', 'Human Biting Rate Indoor', 'Human Biting Rate Outdoor', 'Cow Biting Rate'),
                rownames=F,
                escape=F,
                extensions='Scroller',
                selection='none',
                options=list(pageLength=12, autoWidth = TRUE))
    )
    
    output$table_malvec_brb_2 <- renderDataTable(
      datatable(df_BR %>% select(Country, Aunit, Status, Species, ZI, AI, ENGI, EXGI) %>%
                  mutate(Country=as.factor(Country), Aunit=as.factor(Aunit), Status=as.factor(Status), Species=paste0('<em>', Species, '</em>')), 
                filter='top',
                colname=c('Country', 'Province (Lao) / Subdistrict (Thai)', 'Vector Status', 'Species', 'Zoophagic Index', 'Anthropophagic Index', 'Endophagic Index', 'Exophagic Index'),
                rownames=F,
                escape=F,
                extensions='Scroller',
                selection='none',
                options=list(pageLength=12, autoWidth = TRUE)) %>%
        formatPercentage('ZI', digits=1) %>% 
        formatPercentage('AI', digits=1) %>% 
        formatPercentage('ENGI', digits=1) %>% 
        formatPercentage('EXGI', digits=1) %>%
        formatStyle('ZI', background=styleColorBar(df_BR$ZI, brewer.pal(9, 'Greys')[4])) %>%
        formatStyle('AI', background=styleColorBar(df_BR$AI, brewer.pal(9, 'Greys')[4])) %>%
        formatStyle('ENGI', background=styleColorBar(df_BR$ENGI, brewer.pal(5, 'Pastel2')[2])) %>%
        formatStyle('EXGI', background=styleColorBar(df_BR$EXGI, brewer.pal(5, 'Pastel2')[2]))
    )
    
    # Table of KDR results
    output$table_kdr <- renderDataTable(
      datatable(df_kdr %>% select(-Site) %>% mutate(Species=paste0('<em>', Species, '</em>')),
                filter='top',
                colname=c('Country', 'Province (Lao) / Site (Thai)', 'Species', 'SS (L1014)', 'RS (L1014F)', 'RR (1014F)'),
                rownames=F,
                escape=F,
                extensions='Scroller',
                selection='none',
                options=list(pageLength=12, autoWidth = TRUE)) 
    )
    
    # Tables of sibling species
    output$table_ss_1 <- renderDataTable(datatable(df_ss_1, rownames=F, colnames=c(colnames(df_ss_1)[1:2], paste0('<em>', colnames(df_ss_1)[3:8], '</em>'), colnames(df_ss_1)[9:10]), escape=FALSE))
    output$table_ss_2 <- renderDataTable(datatable(df_ss_2, rownames=F, colnames=c(colnames(df_ss_2)[1:2], paste0('<em>', colnames(df_ss_2)[3:6], '</em>'), colnames(df_ss_2)[7:8]), escape=FALSE))
    output$table_ss_3 <- renderDataTable(datatable(df_ss_3, rownames=F, colnames=c(colnames(df_ss_3)[1:2], paste0('<em>', colnames(df_ss_3)[3:5], '</em>'), colnames(df_ss_3)[6]), escape=FALSE))
    output$table_ss_4 <- renderDataTable(datatable(df_ss_4, rownames=F, colnames=c(colnames(df_ss_4)[1:2], paste0('<em>', colnames(df_ss_4)[3:8], '</em>'), colnames(df_ss_4)[9:10]), escape=FALSE))
    output$table_ss_5 <- renderDataTable(datatable(df_ss_5, rownames=F, colnames=c(colnames(df_ss_5)[1:2], paste0('<em>', colnames(df_ss_5)[3:6], '</em>'), colnames(df_ss_5)[7:8]), escape=FALSE))
    output$table_ss_6 <- renderDataTable(datatable(df_ss_6, rownames=F, colnames=c(colnames(df_ss_6)[1:2], paste0('<em>', colnames(df_ss_6)[3:5], '</em>'), colnames(df_ss_6)[6]), escape=FALSE))
    
    
    # Tables for plasmodium
    output$table_plasm_thai_1 <- renderDataTable(datatable(df_plasm_thai_1 %>% mutate(Species=paste0('<em>', Species, '</em>')), rownames=F, escape=F))
    output$table_plasm_thai_2 <- renderDataTable(datatable(df_plasm_thai_2 %>% mutate(Species=paste0('<em>', Species, '</em>')), rownames=F, escape=F))
    output$table_plasm_lao_1 <- renderDataTable(datatable(df_plasm_lao_1 %>% mutate(Species=paste0('<em>', Species, '</em>')), rownames=F, escape=F))
    output$table_plasm_lao_2 <- renderDataTable(datatable(df_plasm_lao_2 %>% mutate(Species=paste0('<em>', Species, '</em>')), rownames=F, escape=F))
  
    
    
    }
  
)