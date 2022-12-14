library(pdftools)
library(stringr)
library(dplyr, warn.conflicts = FALSE)
library(readr)
library(sf)

## Read pdf files and convert them to text
umf_pdf <- './data/ContratoConcesso012021_umf1_flonas_amapa.pdf'
umf_txt <- pdf_text(umf_pdf)

cat(umf_txt[23]) # view a page text

## Subset pages by UMF
umf2 <- umf_txt[21:22]  # UMF 2 21-22
cat(umf2)

## Regex to extract the name of the vertices 
unlist(str_extract_all(umf2, '\\bP-\\s*?\\d{2}+'))

vertex <- c(paste0('P-0', 1:9), paste0('P-', 10:24))

## Regex to extract longitude and latitude UTM
# Check out if the regex get all the 63th vertices to east and north coordinates
summary(unlist(str_extract_all(umf2, '\\bE\\s*?(\\d{3}\\.\\d{3},\\d{2})m\\b')))

# Did not extract east coordinate from the vertex P-42
summary(unlist(str_extract_all(umf2, '\\bN\\s*?(\\d{3}\\.\\d{3},\\d{2})m\\b'))) 

east <- unlist(str_extract_all(umf2, '\\bE\\s*?(\\d{3}\\.\\d{3},\\d{2})m\\b'))
north <- unlist(str_extract_all(umf2, '\\bN\\s*?(\\d{3}\\.\\d{3},\\d{2})m\\b'))


## Set a dataframe and save as csv
df <- data.frame(vértice = vertex, east = east, north = north) %>%
        mutate(east = gsub('m', '', east)) %>%
        mutate(east = parse_number(east, locale = locale(decimal_mark = ',', 
                                                         grouping_mark = '.'))) %>%
        mutate(north = gsub('m', '', north)) %>%
        mutate(north = parse_number(north, locale = locale(decimal_mark = ',', 
                                                           grouping_mark = '.')))


write.csv(df, 
          './output/vertices_umf2_flona_amapa.csv', 
          row.names = FALSE, 
          fileEncoding = 'UTF-8')

## Convert the dataframe to sf object and as shapefile
shp_points <- st_as_sf(df, coords = c('east', 'north'), crs = '31976')
st_crs(shp_points) <- 'EPSG:31976'
st_write(shp_points, './output/vertices_umf_2_flonas_amapa.shp')
