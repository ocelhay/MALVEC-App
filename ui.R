# ************************************************************************************* #
# MALVEC Project Dashboard: dashboard for malaria data in Lao
# Author: Olivier Celhay - olivier.celhay@gmail.com
#
# ui.R: Define the elements of the user interface for the Shiny
# ************************************************************************************* #

library(shinydashboard)

header <- dashboardHeader(title = "MALVEC Project")

sidebar <- dashboardSidebar(
  
  sidebarMenu(id='menu',
    menuItem("Background", tabName = "malvec_background", icon = icon("hashtag")),
    menuItem("Results", tabName = "malvec", icon = icon("arrow-right"),
             menuSubItem('Mosquito Collection Sites', tabName = 'malvec_2'),
             menuSubItem('Abundance & Diversity', tabName = 'malvec_3'),
             menuSubItem('Sibling Species', tabName = 'malvec_3-2'),
             menuSubItem('Insecticide Resistance', tabName = 'malvec_4'),
             menuSubItem('Biting Rates and Behaviour', tabName = 'malvec_5'),
             menuSubItem('Plasmodium infection', tabName = 'malvec_6')
    ),
    menuItem("Recommendations", tabName = "malvec_recommendations", icon = icon("arrow-right"))
  )
  
)

body <- dashboardBody(
  tabItems(
    tabItem(tabName = "malvec_background", fluidRow(
      column(width=6,
             box(width=NULL, solidHeader=TRUE, collapsible=TRUE, collapsed=FALSE, title='MALVEC Project, 2013-2016', includeMarkdown('./www/markdown/malvec_intro_project.md')),
             box(width=NULL, solidHeader=TRUE, collapsible=TRUE, collapsed=FALSE, title='Study Sites', leafletOutput('map_malvec_sites', height='500'))
      ),
      column(width=6,
             HTML('<img src="./images/MALVEC-anopheles.jpg" width="100%" border="5px" /> <p> </p> '),
             box(width=NULL, solidHeader=TRUE, collapsible=TRUE, collapsed=TRUE, title='Introduction', includeMarkdown('./www/markdown/malvec_intro.md')),
             box(width=NULL, solidHeader=TRUE, collapsible=TRUE, collapsed=TRUE, title='Objectives', includeMarkdown('./www/markdown/malvec_objectives.md')),
             box(width=NULL, solidHeader=TRUE, collapsible=TRUE, collapsed=TRUE, title='Methods', includeMarkdown('./www/markdown/malvec_methods.md')),
             box(width=NULL, solidHeader=TRUE, collapsible=TRUE, collapsed=TRUE, title='Partners', includeMarkdown('./www/markdown/malvec_partners.md')),
             box(width=NULL, solidHeader=TRUE, collapsible=TRUE, collapsed=TRUE, title='Source of data', includeMarkdown('./www/markdown/malvec_sources_of_data.md')),
             box(width=NULL, solidHeader=TRUE, collapsible=TRUE, collapsed=TRUE, title='Additional Information', includeMarkdown('./www/markdown/malvec_references.md'))
      )
      
    )
    ),
    
    tabItem(tabName = "malvec_2", fluidRow(
      column(width=5,
             box(width=NULL, solidHeader=TRUE, collapsible=FALSE, collapsed=FALSE, title='Study Sites', leafletOutput('map_malvec_sites_2', height='500'))
      ),
      column(width=7,
             box(width=NULL, solidHeader=TRUE, collapsible=FALSE, collapsed=FALSE, title='Collection', includeMarkdown('./www/markdown/malvec_collection.md'))
      )
    )
    ),
    
    
    tabItem(tabName = "malvec_3", fluidRow(
      column(width=6,
             box(width=NULL, solidHeader=TRUE, collapsible=TRUE, collapsed=FALSE, title='Anopheles Abundance', 
                 HTML('<p>Map of abundance showing top 5 species per Province/Sub-district and season.</p>'),
                 leafletOutput('map_malvec_abundance', height='500'))
      ),
      column(width=6,
             box(width=NULL, solidHeader=TRUE, collapsible=TRUE, collapsed=FALSE, title='Anopheles Seasonal Abundance', 
                 htmlOutput('text_map_click'),
                 plotOutput('plot_malvec_abundance', height='450'))
             
      )
    ),
    fluidRow(
      box(width=12, solidHeader=TRUE, collapsible=TRUE, collapsed=FALSE, title='Anopheles Abundance Table', 
          HTML('<p>Relative abundance for a selected Province/Sub-district and season. <br> For one species: (Number of individuals collected of this species)/(Total number of individuals collected)</p>'),
          dataTableOutput('table_malvec_abundance')))
    ), 
    
    tabItem(tabName = "malvec_3-2",
      fluidRow(
             box(width=12, solidHeader=TRUE, collapsible=FALSE, collapsed=FALSE, title='Sibling Species Lao PDR', 
                 HTML('<h4>Note:</h4><p>Negative = extraction or sequencing failed</p><p>Field misidentification of mosquitoes in different Anopheles groups resulted in numbers of field identified mosquitoes being different than the number of mosquitoes identified by PCR/sequencing.</p>'),
                 HTML('<h4>Table 1. Siblings species of Maculatus group in Lao PDR</h4>'),
                 dataTableOutput('table_ss_1'),
                 HTML('<br><br><h4>Table 2. Siblings species of Funestus group in Lao PDR</h4>'),
                 dataTableOutput('table_ss_2'),
                 HTML('<br><br><h4>Table 3. Siblings species of Leucosphyrus group in Lao PDR</h4>'),
                 dataTableOutput('table_ss_3')
             )
             ),
      fluidRow(
             box(width=12, solidHeader=TRUE, collapsible=FALSE, collapsed=FALSE, title='Sibling Species Thailand', 
                 HTML('<h4>Note:</h4><p>Negative = extraction or sequencing failed</p><p>Field misidentification of mosquitoes in different Anopheles groups resulted in numbers of field identified mosquitoes being different than the number of mosquitoes identified by PCR/sequencing.</p>'),
                 HTML('<h4>Table 4. Siblings species of Maculatus group in Ubon Ratchathani, Thailand</h4>'),
                 dataTableOutput('table_ss_4'),
                 HTML('<br><br><h4>Table 5. Siblings species of Funestus group in Ubon Ratchathani, Thailand</h4>'),
                 dataTableOutput('table_ss_5'),
                 HTML('<br><br><h4>Table 6. Siblings species of Leucosphyrus group in Thailand</h4>'),
                 dataTableOutput('table_ss_6')
                 )
             )
    ),
    
    
    tabItem(tabName = "malvec_4", 
            fluidRow(
              column(width=5,
                     box(width=NULL, solidHeader=TRUE, collapsible=TRUE, collapsed=FALSE, title='Insecticide Resistance', 
                         HTML('<p>WHO criteria:<ul>
<li> <span style="color:#088A4B">Susceptible</span>: [98-100% mortality] </li>
<li> <span style="color:#DF7401">Suspected resistance</span>: [90-97% mortality] </li>
<li> <span style="color:#8A0808">Resistant</span>: [<90% mortality] </li>
                      </ul>'),
                         leafletOutput('map_malvec_ir', height='500'))
              ),
              column(width=7,
                     box(width=NULL, solidHeader=TRUE, collapsible=TRUE, collapsed=TRUE, title='Resistance Mechanisms',
                         includeMarkdown('./www/markdown/malvec_kdr.md'), dataTableOutput('table_kdr')
                     )
              )
            ),
            fluidRow(
              box(width=12, solidHeader=TRUE, collapsible=TRUE, collapsed=FALSE, title='Table IR', 
                  dataTableOutput('table_malvec_ir'))
            )
    ),
    
    tabItem(tabName = "malvec_5", 
            fluidRow(
              column(width=6,
                     box(width=NULL, solidHeader=TRUE, collapsible=TRUE, collapsed=FALSE, title='Human Biting Rate by Species', 
                         selectInput('species', 'Select a vector type/species:', list(
                           `Vector Type`=c(
                             'Primary vector' = 'Primary_vector', 
                             'Secondary vector' = 'Secondary_vector'),
                           `Primary Vector`=list_primary_vec,
                           `Secondary Vector`=list_secondary_vec), 
                           selected='Primary_vector'),
                         leafletOutput('map_malvec_hbr', height='500')
                     )),
              column(width=6,
                     box(width=NULL, solidHeader=TRUE, collapsible=TRUE, collapsed=FALSE, title='Residual Malaria Transmission and Vector Control',
                         includeMarkdown('./www/markdown/malvec_behaviour_3.md')))
            ),
            fluidRow(
              box(width=12, solidHeader=TRUE, collapsible=TRUE, collapsed=TRUE, title='Table Biting Rates', 
                  includeMarkdown('./www/markdown/malvec_behaviour_1.md'),
                  dataTableOutput('table_malvec_brb_1')),
              box(width=12, solidHeader=TRUE, collapsible=TRUE, collapsed=TRUE, title='Table Biting Preferences', 
                  includeMarkdown('./www/markdown/malvec_behaviour_2.md'),
                  dataTableOutput('table_malvec_brb_2')
              )
            )
            
    ),
    
    tabItem(tabName = "malvec_6", 
            fluidRow(
              box(width=12, solidHeader=TRUE, collapsible=TRUE, collapsed=FALSE, title='Plasmodium Infection',
                  includeMarkdown('./www/markdown/malvec_plasmodium_infection.md'),
                  HTML('<h4>Thailand:</h4>'),
                  dataTableOutput('table_plasm_thai_1'),
                  dataTableOutput('table_plasm_thai_2'),
                  HTML('<h4>Lao PDR:</h4>'),
                  dataTableOutput('table_plasm_lao_1'),
                  dataTableOutput('table_plasm_lao_2')
                  )
            )
    ),
    
    tabItem(tabName = "malvec_recommendations", 
            fluidRow(
              box(width=12, solidHeader=TRUE, collapsible=TRUE, collapsed=FALSE, title='Recommendations',
                  includeMarkdown('./www/markdown/malvec_recommendations.md'))
            )
    )
    
  ))

dashboardPage(header, sidebar, body)