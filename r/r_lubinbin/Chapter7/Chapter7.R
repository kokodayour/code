install.packages("ggplot2")
install.packages("ggspatial")
install.packages("maps")
install.packages("patchwork")
install.packages("ggthemes")
library(ggplot2)
library(ggspatial)
library(maps)
library(patchwork)
library(ggthemes)



setwd("E:/R_course/Chapter4/Data") #修改为存放示例数据的文件路径  
getwd()
library(sf)
library(dplyr)
WHHP<-read_sf("WHHP_2015.shp")
WHHP$Pop_Den <- WHHP$Avg_Pop/WHHP$Avg_Shap_1
names(WHHP)
WHHP <- WHHP[, -c(1:9, 19, 22:23)]
names(WHHP)
names(WHHP) <- c("Pop", "Annual_AQI", "Green_Rate", "GDP_per_Land", "Rev_per_Land", "FAI_per_Land", "TertI_Rate", "Avg_HP", "Den_POI", "Length","Area","geometry","Pop_Den")
sum_hp<-summary(WHHP$Avg_HP)
WHHP <- WHHP %>%  
  mutate(HP_level = case_when(  
    Avg_HP >= sum_hp[[1]] & Avg_HP < sum_hp[[2]] ~ "低", 
    Avg_HP >= sum_hp[[2]] & Avg_HP < sum_hp[[3]] ~ "较低", 
    Avg_HP >= sum_hp[[3]] & Avg_HP < sum_hp[[5]] ~ "较高",
    Avg_HP >= sum_hp[[5]] & Avg_HP <= sum_hp[[6]] ~ "高"
  ))

#7.2.2数据
library(ggplot2)
ggplot(data = WHHP)

#7.2.3美学映射
ggplot(data = WHHP, mapping = aes(x = GDP_per_Land, y = FAI_per_Land, color = HP_level))

ggplot(WHHP, aes(GDP_per_Land, FAI_per_Land, colour = HP_level)) + 
  geom_point()

#(1)映射与非映射
ggplot(WHHP, aes(GDP_per_Land, FAI_per_Land)) + 
  geom_point(aes(colour = "blue"))

ggplot(WHHP, aes(GDP_per_Land, FAI_per_Land)) + 
  geom_point(colour = "blue")

#(2)全局映射与局部映射
ggplot(WHHP, aes(GDP_per_Land, FAI_per_Land, color = HP_level)) + 
  geom_point() + 
  geom_smooth()

ggplot(WHHP, aes(GDP_per_Land, FAI_per_Land)) + 
  geom_point(aes(color = HP_level)) +
  geom_smooth()

#7.2.4几何对象
library(patchwork)
require(dplyr)
sum_gre<-summary(WHHP$Green_Rate)
WHHP <- WHHP %>%  
  mutate(Green_level = case_when(  
    Green_Rate >= sum_gre[[1]] & Green_Rate < sum_gre[[2]] ~ "低", 
    Green_Rate >= sum_gre[[2]] & Green_Rate < sum_gre[[3]] ~ "较低", 
    Green_Rate >= sum_gre[[3]] & Green_Rate < sum_gre[[5]] ~ "较高",
    Green_Rate >= sum_gre[[5]] & Green_Rate <= sum_gre[[6]] ~ "高"
  )) %>%
mutate(HP_level2 = case_when(  
    Avg_HP >= sum_hp[[1]] & Avg_HP < sum_hp[[4]] ~ "平均线以下", 
    Avg_HP >= sum_hp[[4]] & Avg_HP < sum_hp[[6]] ~ "平均线以上",
     .default = "其他"))

p1<-ggplot(WHHP, aes(GDP_per_Land, FAI_per_Land)) + 
  geom_point()
p2<-ggplot(WHHP, aes(Avg_HP)) +
  geom_density()
p3<-ggplot(WHHP, aes(Green_Rate, Avg_HP)) + 
  geom_line()
p4<-ggplot(WHHP, aes(Avg_HP,color = HP_level2)) + 
  geom_histogram()
p5<-ggplot(WHHP, aes(x = HP_level, y = Green_Rate)) +
  geom_boxplot(aes(color = HP_level))
p6<-ggplot(WHHP, aes(x = Green_level, y = HP_level)) +
  geom_tile(aes(fill = GDP_per_Land))
p7<-ggplot(WHHP, aes(x = HP_level2)) +
  geom_bar()
p8<-ggplot(WHHP, aes(x = HP_level, y = Green_Rate)) +
  geom_violin(aes(color = HP_level))

(p1|p2)/(p3|p4) /(p5|p6)/(p7|p8)

#7.2.5标度
#(1)修改坐标轴的刻度与刻度所对应的标签
ggplot(WHHP, aes(GDP_per_Land, FAI_per_Land)) + 
  geom_point() +
  scale_x_continuous(
    breaks = seq(0, 7500, 2500), 
    labels = c("0", "2500", "5000", "7500")) +
  scale_y_continuous(
    breaks = seq(0, 3000, 1000), 
    labels = c("0", "1000", "2000", "3000"))
#(2)设置坐标轴取值范围
p1 <- ggplot(WHHP, aes(GDP_per_Land, FAI_per_Land)) + 
  geom_point() +
  scale_x_continuous(limits = c(0, 3000)) +
  scale_y_continuous(limits = c(0, 2500)) +
  geom_smooth()

p2<- ggplot(WHHP, aes(GDP_per_Land, FAI_per_Land)) + 
  geom_point() +
  coord_cartesian(xlim = c(0, 3000), ylim = c(0, 2500)) +
  geom_smooth()
  

p3 <- ggplot(WHHP, aes(GDP_per_Land, FAI_per_Land)) + 
  geom_point() +
  xlim(0, 3000) +  ylim(0, 2500) +
  geom_smooth()

p1|p2|p3
#(3)对坐标轴取值进行变换
p1 <- ggplot(WHHP, aes(FAI_per_Land, GDP_per_Land)) + 
  geom_point() +
  geom_smooth()

p2<- ggplot(WHHP, aes(FAI_per_Land, GDP_per_Land)) + 
  geom_point() +
  scale_y_log10() +
  geom_smooth()

p1|p2


#(4)设置变量的颜色
p1 <- ggplot(WHHP, aes(GDP_per_Land, FAI_per_Land, color = HP_level2, shape=HP_level2)) + 
  geom_point() +
  scale_color_manual(values = c("#C51B7D","#7fbc41","#f46d43"))

p2 <- ggplot(WHHP, aes(GDP_per_Land, FAI_per_Land, color = Avg_HP)) +
  geom_point() +
  scale_color_continuous(low = "green", high = "red")
p1/p2
#7.2.6统计变换
df <- data.frame(
  category = c("A", "B", "C"),
  value = c(5, 3, 6)
)
p1<-ggplot(df, aes(x = category)) +
  geom_bar()
p2<-ggplot(df, aes(x = category, y = value)) +
  geom_bar(stat = "identity")
p1|p2

#stat_summary()
ggplot(WHHP, aes(x = Green_level, y = Avg_HP)) +
  stat_summary(
    fun = mean, 
    geom = "bar",
    fill = "skyblue"
  ) +
  stat_summary(
    fun.data = mean_cl_normal,
    geom = "errorbar",
    width = 0.2
  )

#7.2.7坐标系
#coord_flip()
p1 <- ggplot(WHHP, aes(x = Green_level, y = Avg_HP)) +
  geom_boxplot(width=0.8)
p2 <-  ggplot(WHHP, aes(x = Green_level, y = Avg_HP)) +
  geom_boxplot(width=0.8) +coord_flip()
p1|p2
#coord_polar()
wind_data <- data.frame(
  Direction = factor(c("北", "东北", "东", "东南", "南", "西南", "西", "西北")),
  Frequency = c(10, 15, 20, 30, 20, 15, 10, 10))

# 绘制风玫瑰图
p1 <- ggplot(wind_data, aes(x = Direction, y = Frequency, fill = Direction)) +
  geom_bar(width = 1, stat = "identity")
p2 <- ggplot(wind_data, aes(x = "", y = Frequency, fill = Direction)) +
  geom_bar(width = 1, stat = "identity") + coord_polar("y")
p3<- ggplot(wind_data, aes(x = Direction, y = Frequency, fill = Direction)) +
  geom_bar(stat = "identity") + coord_polar(start = 0)
p4 <- ggplot(wind_data, aes(x = 2, y = Frequency, fill = Direction)) +
  geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start = 0) + xlim(0.5, 2.5)
(p1|p2)/(p3|p4)


#7.2.8位置调整
#(1)position_jitter()
data <- data.frame(
  category = rep(c("A", "B", "C"), each = 30),
  value = c(rnorm(30, mean = 10, sd = 0.5), 
            rnorm(30, mean = 15, sd = 0.5), 
            rnorm(30, mean = 20, sd = 0.5))
)
p1<-ggplot(data, aes(x = category, y = value)) +
  geom_point() +
  labs(title = "Scatter Plot without Jitter",
       x = "Category", 
       y = "Value")
p2<-ggplot(data, aes(x = category, y = value)) +
  geom_point(position = position_jitter(width = 0.2, height = 0)) +
  labs(title = "Scatter Plot with Jitter",
       x = "Category", 
       y = "Value")
p1|p2


p1 <- ggplot(WHHP, aes(GDP_per_Land, FAI_per_Land)) + 
  geom_point()+labs(title = "Scatter Plot without Jitter")

p2<- ggplot(WHHP, aes(GDP_per_Land, FAI_per_Land)) + 
  geom_point(position = position_jitter(width = 100, height = 100)) +
  labs(title = "Scatter Plot with Jitter")
p1|p2


#(2)position_dodge()
data <- data.frame(
  category = rep(c("A", "B", "C"), times = 3),
  group = rep(c("G1", "G2", "G3"), each = 3),
  value = c(10, 15, 20, 12, 17, 22, 11, 16, 21))
p1<-ggplot(data, aes(x = category, y = value, fill = group)) +
  geom_bar(stat = "identity", width=0.5) +
  labs(title = "Grouped Bar Plot without Dodge",
       x = "Category", y = "Value")
p2<-ggplot(data, aes(x = category, y = value, fill = group)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.8)) +
  labs(title = "Grouped Bar Plot with Dodge",
       x = "Category", y = "Value")
p1|p2

#7.2.9分面
#(1)facet_grid() 网格式分面
ggplot(WHHP, aes(x = GDP_per_Land, y = FAI_per_Land)) +
  geom_point() +
  facet_grid(HP_level ~ Green_level)
#(2)facet_wrap() 包装式分面
ggplot(WHHP, aes(x = GDP_per_Land, y = FAI_per_Land)) +
  geom_point() +
  facet_wrap(~ HP_level, nrow = 2)

#7.2.10主题与输出
#(1)主题
ggplot(WHHP, aes(GDP_per_Land, FAI_per_Land, color = HP_level)) +
  geom_point() +
  labs(x = "地均GDP",
       y = "地均固定资产投入", 
       color = "房价水平",
       title = "地均固定资产投入随地均GDP的变化图",
       subtitle = "武汉市2015年数据，点颜色表示不同平均房价水平",
       caption = "制图时间：2024-08-08")+
  theme(axis.title = element_text(size=9),
        axis.text = element_text(size=8),
        plot.title = element_text(size=13,face = "bold"),
        legend.text = element_text(size = 8))
##主题细节函数
lty <- c("solid", "dashed", "dotted", "dotdash", "longdash", "twodash")
linetypes <- data.frame(
  y = seq_along(lty),
  lty = lty
) 
p1 <- ggplot(linetypes, aes(0, y)) + 
  geom_segment(aes(xend = 5, yend = y, linetype = lty)) + 
  scale_linetype_identity() + 
  geom_text(aes(label = lty), hjust = 0, nudge_y = 0.2) +
  scale_x_continuous(NULL, breaks = NULL) + 
  scale_y_reverse(NULL, breaks = NULL)


shapes <- data.frame(
  shape = c(0:19, 22, 21, 24, 23, 20),
  x = 0:24 %/% 5,
  y = -(0:24 %% 5)
)
p2<- ggplot(shapes, aes(x, y)) + 
  geom_point(aes(shape = shape), size = 5, fill = "red") +
  geom_text(aes(label = shape), hjust = 0, nudge_x = 0.15) +
  scale_shape_identity() +
  expand_limits(x = 4.1) +
  theme_void()

df <- data.frame(x = c(1,1,1,2,2,2,2), y = c(1:3, 1:4), fontf = c("plain","plain","plain", "plain", "bold", "italic", "bold.italic"),
fam = c("sans", "serif", "mono","serif","serif","serif","serif"))
p3 <- ggplot(df, aes(x, y),xlim = c(0,3)) + 
  geom_text(aes(label = c(fam[1:3],fontf[4:7]), fontface = fontf,family = fam))



sizes <- expand.grid(size = (0:3) * 2, stroke = (0:3) * 2)
p4 <- ggplot(sizes, aes(size, stroke, size = size, stroke = stroke)) + 
  geom_abline(slope = -1, intercept = 6, colour = "white", linewidth = 6) + 
  geom_point(shape = 21, fill = "red") +
  scale_size_identity()

(p1|p2)/(p3|p4)
#主题函数
p1 <- ggplot(WHHP, aes(x = GDP_per_Land, y = FAI_per_Land)) +
  geom_point() + labs(title ="theme_gray") +
  theme_gray()

p2<- ggplot(WHHP, aes(x = GDP_per_Land, y = FAI_per_Land)) +
  geom_point() + labs(title ="theme_bw") +
  theme_bw()

p3<- ggplot(WHHP, aes(x = GDP_per_Land, y = FAI_per_Land)) +
  geom_point() + labs(title ="theme_minimal") +
  theme_minimal()

p4<- ggplot(WHHP, aes(x = GDP_per_Land, y = FAI_per_Land)) +
  geom_point() + labs(title ="theme_classic") +
  theme_classic()

p<- (p1|p2)/(p3|p4)
p


library(ggthemes)
p1 <- ggplot(WHHP, aes(x = GDP_per_Land, y = FAI_per_Land)) +
  geom_point() + labs(title ="theme_economist") +
  theme_economist()

p2<- ggplot(WHHP, aes(x = GDP_per_Land, y = FAI_per_Land)) +
  geom_point() + labs(title ="theme_fivethirtyeight") +
  theme_fivethirtyeight()

p3<- ggplot(WHHP, aes(x = GDP_per_Land, y = FAI_per_Land)) +
  geom_point() + labs(title ="theme_solarized") +
  theme_solarized()

p4<- ggplot(WHHP, aes(x = GDP_per_Land, y = FAI_per_Land)) +
  geom_point() + labs(title ="theme_stata") +
  theme_stata()

p5<- ggplot(WHHP, aes(x = GDP_per_Land, y = FAI_per_Land)) +
  geom_point() + labs(title ="theme_tufte") +
  theme_tufte()

p6<- ggplot(WHHP, aes(x = GDP_per_Land, y = FAI_per_Land)) +
  geom_point() + labs(title ="theme_excel") +
  theme_excel()

p<- (p1|p2)/(p3|p4)/(p5|p6)
p

#(2)输出
ggsave("scatterplot.png", p, width = 24, height = 24, dpi = 300)


#7.3地图可视化
#7.3.1不同格式空间数据绘图的基本流程
#(1)simple feature
WHHP_cen<-st_centroid(WHHP)
ggplot(data=WHHP_cen)+
  geom_sf()+ labs(title ="点数据") +
 theme_minimal()


WHRD<-read_sf("WHRD.shp")
ggplot(data=WHRD)+
  geom_sf()+ labs(title ="线数据") +
  theme_bw()

ggplot(data=WHHP)+
  geom_sf()+labs(title ="面数据") +
  theme_gray()

#(2)dataframe
#例1
library(maps)
library(ggplot2)

world <- map_data("world")
cities <- data.frame(
  city = c("New York", "Los Angeles", "Toronto", "Mexico City"),
  lon = c(-74.006, -118.2437, -79.3832, -99.1332),
  lat = c(40.7128, 34.0522, 43.6532, 19.4326)
)

ggplot() +
  geom_polygon(data = world, aes(x = long, y = lat, group = group), fill = "lightblue", color = "black") +
  geom_point(data = cities, aes(x = lon, y = lat), color = "red", size = 3) +
  labs(title = "Map of North America with Cities", x = "Longitude", y = "Latitude") +
  coord_cartesian(xlim = c(-170, -50), ylim = c(0, 50))  # 仅显示北美城市

#例2
flight_path <- data.frame(
  lon = c(-74.006, -0.1278, 139.6917),
  lat = c(40.7128, 51.5074, 35.6895)
)
ggplot(flight_path, aes(x = lon, y = lat)) +
  geom_path(color = "red") +
  geom_point() +
  labs(title = "Flight Path",
       x = "Longitude", y = "Latitude")

#(3)Spatial*对象
library(maptools)
WHHP_sp<-readShapePoly("WHHP_2015.shp", verbose=T, 
                       proj4string = CRS("+proj=tmerc +lat_0=0 +lon_0=114 +k=1 +x_0=500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
WHHP_sf<-st_as_sf(WHHP_sp)
ggplot(WHHP_sf)+
  geom_sf()

#7.3.2属性数据可视化
#(1)点
library(ggspatial)
WHHP_cen<-st_centroid(WHHP)
ggplot(WHHP)+
  geom_sf()+
  geom_sf(data = WHHP_cen,pch=16,aes(color=Avg_HP,size=Avg_HP))+
  scale_size(range = c(1, 3))+scale_color_gradient(trans = "reverse") +
  annotation_scale(location = "bl", width_hint = 0.1) + 
  annotation_north_arrow(location = "tr", which_north = "true", 
                         pad_x = unit(0.1, "in"), pad_y = unit(0.1, "in"),
                         style = north_arrow_fancy_orienteering)
#(2)线
WHRD<-read_sf("WHRD.shp")
WHRD <- WHRD %>%  
  mutate(new_fclass = case_when(  
    fclass == "trunk_link" | fclass == "trunk" ~ "trunk", 
    fclass == "primary_link" | fclass == "primary" ~ "primary",
    fclass == "motorway_link" | fclass == "motorway" ~ "motorway", 
    fclass == "secondary_link" | fclass == "secondary" ~ "secondary",
    fclass == "tertiary_link"  | fclass == "tertiary"~ "tertiary"
  ))
ggplot(WHRD)+
  geom_sf(aes(col=new_fclass,linetype=new_fclass))+
  annotation_scale(location = "bl", width_hint = 0.1) + 
  annotation_north_arrow(location = "tr", which_north = "true", 
                         pad_x = unit(0.1, "in"), pad_y = unit(0.1, "in"),
                         style = north_arrow_fancy_orienteering)
#(3)面
ggplot(WHHP)+
  geom_sf(aes(fill=Avg_HP))+  scale_fill_gradient(trans = "reverse") +
  annotation_scale(location = "bl", width_hint = 0.1) + 
  annotation_north_arrow(location = "tr", which_north = "true", 
                         pad_x = unit(0.1, "in"), pad_y = unit(0.1, "in"),
                         style = north_arrow_fancy_orienteering)
