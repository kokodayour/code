###echarts4r.assets、echarts4r.maps、REmap这三个包需要从GitHub下载
library(devtools)
install_github("JohnCoene/echarts4r.assets")
install_github("JohnCoene/echarts4r.maps")
install_github("lchiffon/REmap")

install.packages("GISTools")
install.packages("tmap")
install.packages("echarts4r")
install.packages("leaflet")
library(echarts4r.assets)
library(echarts4r.maps)
library(REmap)
library(GISTools)
library(tmap)
library(echarts4r)
library(leaflet)

###整理数据
library(sf)
setwd("E:/R_course/Chapter6/Data") #修改为数据实际存放的文件夹路径
WHHP<-read_sf("WHHP_2015.shp")
WHHP$Pop_Den <- WHHP$Avg_Pop/WHHP$Avg_Shap_1
names(WHHP)
WHHP <- WHHP[, -c(1:9, 19, 22:23)]
names(WHHP)
names(WHHP) <- c("Pop", "Annual_AQI", "Green_Rate", "GDP_per_Land", "Rev_per_Land", "FAI_per_Land", "TertI_Rate", "Avg_HP", "Den_POI", "Length","Area","geometry","Pop_Den")
#直接绘制
plot(WHHP)

#控制数量
plot(WHHP, max.plot = 4)

#只绘制几何形状
plot(WHHP$geometry)
plot(st_geometry(WHHP))


#6.2.1
###修改配色
HP_outline<-st_union(WHHP)
plot(WHHP$geometry,col = "red",bg = "skyblue",lty = 2,border = "blue")
plot(HP_outline,lwd = 3,add = TRUE)
title(main="The Central Zone of Wuhan", font.main=2, cex.main=1.5)

#GISTools添加制图要素
plot(WHHP$geometry)
north.arrow(553300,3397000,500,col='lightblue')
map.scale(508190,3370000,5000,"km",2,2.5,sfcol='black')
title("The Central Zone of Wuhan")


#tmap添加制图要素
tm_shape(WHHP) +
  tm_borders(lty = 1, col = "black") +
  tm_compass(position = c("right", "top")) +
  tm_scale_bar(position = c("left", "bottom")) +
  tm_layout(title = "The Map of Wuhan",
            title.position = c("left", "top"))


###多个图层叠加显示
###plot+GISTools多个图层叠加显示
WHRD <- read_sf("WHRD.shp")
WHZZQ<-read_sf("WHSWZZ_ZZQ.shp")
WH_Dis<-read_sf("WHDistrict.shp")
WH_Dis<-st_make_valid(WH_Dis)
WH_outline<-st_union(WH_Dis)
WH_Dis_proj <- st_transform(WH_Dis, crs = 32650)
WH_outline_proj<-st_transform(WH_outline, crs = 32650)
WHRD_proj<-st_transform(WHRD,crs = 32650)
WHZZQ_proj<-st_transform(WHZZQ,crs = 32650)
WHRD_tuk<-WHRD_proj[WHRD_proj$fclass=="trunk"|WHRD_proj$fclass=="trunk_link",]
plot(WH_Dis_proj$geometry,lty=1,lwd=1,border = "grey40")
plot(WH_outline_proj,lwd=3,border="black",add=T)
plot(WHZZQ_proj$geometry,pch=3,col = "red", size = 0.3,add=T)
plot(WHRD_tuk$geometry,col="blue",lty=2,lwd=1.5,add=T)
north.arrow(316690,3455000,5000,col="lightblue")
map.scale(183125,3335000,10000,"km",2,5)



###tmap多个图层叠加显示
tm_shape(WH_Dis_proj) +
  tm_polygons(col = "white", border.col = "black") +  
  tm_shape(WH_outline_proj) +
  tm_borders(lwd = 3, col = "black") + 
  tm_shape(WHZZQ_proj) +
  tm_dots(shape = 3, col = "red", size = 0.3) +  
  tm_shape(WHRD_tuk) +
  tm_lines(col = "blue", lty = 2, lwd = 1.5) +  
  tm_scale_bar(position = c("left", "bottom")) +  
  tm_compass(position = c("right", "top")) 



###6.3.1 plot点数据属性数据可视化
plot(WHHP$geometry, col="white", lty=1,lwd=1, border = "grey40")
WHHP_cen<-st_centroid(WHHP$geometry)
plot(WHHP_cen, pch=1, col="red", cex=WHHP$Avg_HP/20000,add=T)
legVals <- c(5000, 10000, 15000, 20000, 25000)
legend("bottomright",legend = legVals, cex=0.5, pch = 1, col = "red", pt.cex = legVals/10000, title = "House price")


###tmap点数据属性数据可视化
require(RColorBrewer)
WHHP_cen<-st_as_sf(WHHP_cen)
WHHP_cen$Avg_HP<-WHHP$Avg_HP
WHHP_cen$Pop<-WHHP$Pop
WHHP_cen$GDP_per_Land<-WHHP$GDP_per_Land
WHHP_cen$FAI_per_Land<-WHHP$FAI_per_Land
blue_palette <- brewer.pal(9, "Blues")

tm_shape(WHHP) + 
  tm_polygons(col = "white", border.col = "black") +
  tm_shape(WHHP_cen) +
  tm_bubbles(size = "Avg_HP", col = "Avg_HP", palette = blue_palette, scale = 0.8) + 
  tm_layout(legend.position = c("right", "bottom"),
            inner.margins = c(0.05, 0.05, 0.05, 0.2))


###thematic.map
thematic.map(WHHP_cen, var.names="Avg_HP", colorStyle ="red",na.pos = "topleft", scaleBar.pos = "bottomright", 
legend.pos = "bottomleft",cuts=5, cutter=rangeCuts, bglyrs = list(WHHP),bgStyle=list(col="white", cex=1, lwd=1, pch=16, lty=1))

###spplot
library(sp)
WHHP_cen_sp <- SpatialPointsDataFrame(st_coordinates(WHHP_cen), st_drop_geometry(WHHP_cen))
mypalette <- brewer.pal(7, "Reds")
spplot(WHHP_cen_sp, "Avg_HP", key.space = "right", pch = 16, cex = WHHP_cen_sp$Avg_HP/15000, col.regions = mypalette, cuts=7)


###绘制多个属性
is_outlier <- function(x) {
  Q1 <- quantile(x, 0.25)
  Q3 <- quantile(x, 0.75)
  IQR <- Q3 - Q1
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  return(x < lower_bound | x > upper_bound)
}
columns <- c("Pop", "GDP_per_Land","Avg_HP","FAI_per_Land")
outlier_matrix <- sapply(columns, function(col) {
  is_outlier(WHHP_cen_sp@data[[col]])
})
rows_to_remove <- apply(outlier_matrix, 1, any, na.rm = TRUE)
sp_data_filtered <- WHHP_cen_sp[!rows_to_remove, ]
data_df_scaled <- as.data.frame(scale(sp_data_filtered@data))
sp_data_filtered@data <- data_df_scaled
mypalette <- brewer.pal(4, "Reds")
spplot(sp_data_filtered,c("Pop","GDP_per_Land","Avg_HP","FAI_per_Land"),key.space="right",pch=16,col.regions=mypalette,cex=0.5,cuts=3)


###添加指南针和比例尺
WHHP_sp<-as(WHHP,"Spatial")
mypalette <- brewer.pal(6, "Blues")
map.na = list("SpatialPolygonsRescale", layout.north.arrow(), offset = c(549000,3393000), scale = 4000, col=1)
map.scale.1 = list("SpatialPolygonsRescale", layout.scale.bar(), offset = c(512000,3367000), scale = 5000, col=1, fill=c("transparent","green"))
map.scale.2  = list("sp.text", c(512000,3367000), "0", cex=0.9, col=1)
map.scale.3  = list("sp.text", c(518000,3367000), "5km", cex=0.9, col=1)
WHHP_sp_list <-  list("sp.polygons",WHHP_sp) 
map.layout<- list(WHHP_sp_list, map.na, map.scale.1, map.scale.2, map.scale.3)
spplot(WHHP_cen_sp, "Avg_HP", key.space = "right", pch=16,col.regions =mypalette,cuts=6,sp.layout=map.layout,xlim=c(bbox(WHHP_sp)[1,][[1]]-1000,bbox(WHHP_sp)[1,][[2]]+1000),ylim=c(bbox(WHHP_sp)[2,][[1]]-1000,bbox(WHHP_sp)[2,][[2]]+1000))


###6.3.2 plot面数据属性数据可视化
library(dplyr)
WHRD <- WHRD %>%  
  mutate(new_fclass = case_when(  
    fclass == "trunk_link" | fclass == "trunk" ~ "trunk", 
    fclass == "primary_link" | fclass == "primary" ~ "primary",
    fclass == "motorway_link" | fclass == "motorway" ~ "motorway", 
    fclass == "secondary_link" | fclass == "secondary" ~ "secondary",
    fclass == "tertiary_link"  | fclass == "tertiary"~ "tertiary"
  ))
road_type <- unique(WHRD$new_fclass)
shades <- brewer.pal(5, "Set3")
idx <- match(WHRD$new_fclass, road_type)
plot(WHRD$geometry,col = shades[idx])
legend("bottomright", legend = road_type, lty=1,col=shades, title = "Road type",cex = 0.5)

###修改颜色以及线型等
road_type <- unique(WHRD$new_fclass)
shades <- c("grey","#E6F598","#66C2A5","#C51B7D","#BF812D")
idx <- match(WHRD$new_fclass, road_type)
ltypes <- c(3,3,1,1,3)
lwidths <- c(0.5,0.5,2,1,0.5)
plot(WHRD$geometry, col=shades[idx],lty=ltypes[idx],lwd=lwidths[idx])
legend("bottomright", legend = road_type, lty=ltypes,lwd=lwidths,col=shades, title = "Road type",cex = 0.5)

###tmap线数据属性数据可视化
tm_shape(WHRD)+
  tm_lines(col="new_fclass",col.scale = tm_scale(values = c("trunk" = "#66C2A5","primary" = "#C51B7D", "motorway"="#BF812D", "secondary"="#E6F598", "tertiary"="grey")),
           lwd.scale = tm_scale(values = c("trunk" = 2,"primary" = 1, "motorway"=0.5, "secondary"=0.5, "tertiary"=0.5)),
           lty.legend = tm_legend_combine("col"),
           col.legend = tm_legend_combine("col"))


###6.3.3 面数据的属性数据可视化
area<-as.numeric(st_area(WHHP$geometry))
WHHP$Area<-area
plot(WHHP["Area"],key.pos = 4)

###修改图例位置以及样式
plot(WHHP["Area"],key.pos = 1,key.length = 1.0,key.width = lcm(1.3),axes=FALSE)

###修改分组方式
WHHP$new_area<-cut(area,breaks=5)
plot(WHHP["new_area"],key.pos = 4, pal = sf.colors(5), key.width = lcm(5))
plot(WHHP["Area"], breaks = c(0, 0.05e+07, 0.25e+07, 0.5e+07, 1e+07,1.5e+07), key.pos = 4, pal = rainbow(5))


###使用内置的分组方法
plot(WHHP["Area"], breaks = "pretty",main="Pretty")
plot(WHHP["Area"], breaks = "equal", main="Equal")
plot(WHHP["Area"], breaks = "quantile",main="Quantile")
plot(WHHP["Area"], breaks = "jenks", main="Jenks")


###tmap不同类型属性的映射函数
require(dplyr)
sum_hp<-summary(WHHP$Avg_HP)
WHHP <- WHHP %>%  
  mutate(HP_level = case_when(  
    Avg_HP >= sum_hp[[1]] & Avg_HP < sum_hp[[2]] ~ "低", 
    Avg_HP >= sum_hp[[2]] & Avg_HP < sum_hp[[3]] ~ "较低",
    Avg_HP >= sum_hp[[3]] & Avg_HP < sum_hp[[5]] ~ "较高",
    Avg_HP >= sum_hp[[5]] & Avg_HP <= sum_hp[[6]] ~ "高"
  ))
map_categorical <- tm_shape(WHHP) +
  tm_polygons("HP_level",style = "cat", palette = "Set3", title = "Categorical Scale")
tmap_save(map_categorical, "map_categorical.png", width = 18, height = 16, units = "cm", dpi = 300)

WHHP <- WHHP %>%  
  mutate(HP_level = case_when(  
    Avg_HP >= sum_hp[[1]] & Avg_HP < sum_hp[[2]] ~ "1", 
    Avg_HP >= sum_hp[[2]] & Avg_HP < sum_hp[[3]] ~ "2",
    Avg_HP >= sum_hp[[3]] & Avg_HP < sum_hp[[5]] ~ "3",
    Avg_HP >= sum_hp[[5]] & Avg_HP <= sum_hp[[6]] ~ "4"
  ))
map_ordinal <- tm_shape(WHHP) +
  tm_polygons("HP_level", style = "order", title = "Ordinal Scale")  
tmap_save(map_ordinal, "map_ordinal.png", width = 18, height = 16, units = "cm", dpi = 300)

breaks <- c(5000, 10000, 15000,20000, 25000)
map_intervals <- tm_shape(WHHP) +
  tm_polygons("Avg_HP", style = "fixed", breaks = breaks, title = "Interval Scale")
tmap_save(map_intervals, "map_intervals.png", width = 18, height = 16, units = "cm", dpi = 300)
map_continuous <- tm_shape(WHHP) +
  tm_polygons("Avg_HP", style = "cont", title = "Continuous Scale")
tmap_save(map_continuous, "map_continuous.png", width = 18, height = 16, units = "cm", dpi = 300)

###设置绘图风格
tmap_style("classic") 
classic_sty <- tm_shape(WHHP) +
  tm_polygons("Avg_HP", title = "Average HP") +  
  tm_legend(position = c("right", "bottom"), text.size = 0.8) +  
  tm_scale_bar(position = c("left", "bottom")) +  
  tm_compass(position = c("right", "top"), size = 3)
  
tmap_save(classic_sty, "classic_sty.png", width = 18, height = 16, units = "cm", dpi = 300)

gray_sty <-tm_shape(WHHP)+
  tm_polygons("Avg_HP", title = "Average HP") + 
  tm_legend(position = c("right", "bottom"), text.size = 0.8) +  
  tm_scale_bar(position = c("left", "bottom")) +  
  tm_compass(position = c("right", "top"), size = 3)+
  tm_style("gray")
tmap_save(gray_sty , "gray_sty .png", width = 18, height = 16, units = "cm", dpi = 300)

natural_sty <-tm_shape(WHHP)+
  tm_polygons("Avg_HP", title = "Average HP") + 
  tm_legend(position = c("right", "bottom"), text.size = 0.8) +  
  tm_scale_bar(position = c("left", "bottom")) +  
  tm_compass(position = c("right", "top"), size = 3)+
  tm_style("natural")
tmap_save(natural_sty , "natural_sty.png", width = 18, height = 16, units = "cm", dpi = 300)


###绘制专题图
shades = auto.shading(WHHP[["Avg_HP"]])
dev.new(width = 16, height = 12)
choropleth(sp = WHHP,v="Avg_HP",shading=shades)
choro.legend(548871.4, 3377000, shades, title='Average house price')

#修改主题色
library(RColorBrewer)
shades = auto.shading(WHHP[["Avg_HP"]],n=6,cols = brewer.pal(6, "Blues"))
dev.new(width = 16, height = 12)
choropleth(sp = WHHP,v="Avg_HP",shading=shades)
choro.legend(548871.4, 3377000, shades,title='Average house price')

shades = auto.shading(WHHP[["Avg_HP"]],n=7,cols = brewer.pal(7, "Greens"),cutter = rangeCuts)
dev.new(width = 16, height = 12)
choropleth(sp = WHHP,v="Avg_HP",shading=shades)
choro.legend(548871.4, 3377000, shades,title='Average house price')


##thematic map
data(newhaven)
thematic.map(blocks, var.names="POP1990", horiz = FALSE, na.pos = "topleft",scaleBar.pos = "bottomright", legend.pos = "bottomleft",colorStyle = "red")

#多属性
thematic.map(blocks, var.names=c("P_35_44","P_25_34", "POP1990"),horiz =FALSE, na.pos = "topleft", scaleBar.pos = "bottomright",legend.pos = "bottomleft",colorStyle =hcl.colors)

#修改颜色
thematic.map(blocks, var.names=c("P_35_44","P_25_34", "POP1990"),horiz =FALSE, na.pos = "topleft", scaleBar.pos = "bottomright",legend.pos = "bottomleft", colorStyle =c("red", "blue", "na"))

###6.4.1 echarts4r
library(echarts4r)
WHHP %>%
  e_charts(GDP_per_Land) %>%
  e_scatter(FAI_per_Land) %>%
  e_tooltip()

###热力图与地图叠加显示
usa <- sapply(1:15, function(i){
  x <- -120 + runif(1, 0, 1) * 5
  y <- 35 + runif(1, 0, 1) * 10
  lapply(0:floor(10 * abs(rnorm(1))), function(j){
    c(x + runif(1, 0, 1) * 3, y + runif(1, 0, 1) * 2, runif(1, 10, 500))
  })
})
usa <- data.frame(matrix(unlist(usa), byrow = TRUE, ncol = 3))
colnames(usa) <- c("lng", "lat", "value")

usa %>%
  e_charts(lng) %>%
  e_geo(map = "world",  
        center = c(-100, 40),  
        zoom = 3,              
        roam = TRUE) %>%       
  e_heatmap(lat, value, coord_system = "geo", blurSize = 20, pointSize = 3) %>%
  e_visual_map(value)


###绘制湖北省地图
Hubei_map <- jsonlite::read_json("湖北省.json")
json_df<-as.data.frame(Hubei_map)
city_name_df<-json_df %>%
  select(contains("name"))
city_name<-unlist(city_name_df, use.names = FALSE)
df<-data.frame(region = city_name,
               value = runif(length(city_name),10,500))
df %>%
  e_charts(region) %>%
  e_map_register("Hubei", Hubei_map) %>%
  e_map(value, map = "Hubei") %>%
  e_visual_map(value)


###航线可视化
library(echarts4r.assets)
flights <- read.csv("flight.csv")
flights %>% 
  e_charts() %>% 
  e_globe(
    environment = ea_asset("starfield"),
    base_texture = ea_asset("world topo"), 
    height_texture = ea_asset("world topo"),
    displacementScale = 0.05
  ) %>% 
  e_lines_3d(
    start_lon, 
    start_lat, 
    end_lon, 
    end_lat,
    name = "flights",
    effect = list(show = TRUE)
  ) %>% 
  e_legend(FALSE)


###热力图
options(remap.ak="你的ak")
library(REmap)
cities <- mapNames("hubei")
cities
city_Geo <- get_geo_position(cities)
percent <- runif(17,min=0.3,max = 0.99)
data_all <- data.frame(city_Geo[,1:2],percent,city_Geo[,3])
data_all
result <- remapH(data_all,
                 maptype = "湖北",
                 title = "湖北省XX热力图",
                 theme = get_theme("Dark"),
                 blurSize = 50,
                 color = "red",
                 minAlpha = 8,
                 opacity = 1)
result

###调用百度地图
remapB(get_city_coord("武汉"),zoom = 12)


###绘制迁徙图
location<-data.frame(origin = rep('武汉', 12),
                     destination=c('黄石','十堰','宜昌','襄阳',
                                   '鄂州','荆门','孝感','荆州','黄冈',
                                   '咸宁','随州','恩施'))
remapB(center=get_city_coord("武汉"),
       zoom = 8,
       title = "湖北地区迁徙图示例",
       color = "Blue",
       markLineData = location,
       markLineTheme = markLineControl(symbolSize = 0.3,
                                       lineWidth = 12,
                                       color = "white",
                                       lineType = 'dotted'))


###绘制上海地铁一号线示意图
pointData = data.frame(geoData$name,
                       color = c(rep("red",10),
                                 rep("yellow",50)))
names(geoData) = names(subway[[1]])
remapB(get_city_coord("上海"),
       zoom = 13,
       color = "Blue",
       title = "上海地铁一号线",
       markPointData = pointData,
       markPointTheme = markPointControl(symbol = 'pin',
                                         symbolSize = 8,
                                         effect = T),
       markLineData = subway[[2]],
       markLineTheme = markLineControl(symbolSize = c(0,0),
                                       smoothness = 0),
       geoData = rbind(geoData,subway[[1]]))


###分层设色图
data = data.frame(country = mapNames("hubei"),
                  value = 5*sample(17)+200)
remapC(data,maptype = "hubei",color = 'skyblue')

###6.4.3
library(leaflet)
m <- leaflet() %>% setView(lng = 114.3, lat = 30.6, zoom = 10)
m %>% addProviderTiles(providers$Esri.NatGeoWorldMap)
m %>% addProviderTiles(providers$Stadia.StamenToner)
m %>% addProviderTiles(providers$Stadia.StamenTonerLines,
                       options = providerTileOptions(opacity = 0.35)) %>%
  addProviderTiles(providers$Stadia.StamenTonerLabels)

###房价点分层设色
HP_cen_wgs84<-st_transform(WHHP_cen,4326)
bins <- c(0, 5000, 13000, 15000, 20000, Inf)
pal <- colorBin("Blues", domain = WHHP$Avg_HP, bins = bins)

leaflet(HP_cen_wgs84) %>% setView(lng = 114.3, lat = 30.6, zoom = 12) %>% 
  addProviderTiles(providers$Stadia.StamenToner,
                   options = providerTileOptions(opacity = 0.35)) %>%
  addProviderTiles(providers$Stadia.StamenTonerLabels) %>%
  addCircles(
    lng = st_coordinates(HP_cen_wgs84)[,1], 
    lat = st_coordinates(HP_cen_wgs84)[,2],
    weight = 2,
    fillColor = ~pal(WHHP$Avg_HP),
    opacity = 1,
    color = "white",
    dashArray = "3",
    fillOpacity = 0.7,
    radius = WHHP$Avg_HP * 0.02)%>%
  addLegend(pal = pal, values = WHHP$Avg_HP, 
            opacity = 0.7, title = NULL,
            position = "bottomright")
