#4.2.1sp
library(sp)
library(maptools)
setwd("E:/R_course/Chapter4/Data") 
WHHP_sp <- readShapePoly("WHHP_2015.shp", verbose=T, proj4string = CRS("+proj=tmerc +lat_0=0 +lon_0=114 +k=1 +x_0=500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
class(WHHP_sp@data)
summary(WHHP_sp@data)


#去除重复列和NA列
new_df <- WHHP_sp@data
new_df$FID_1_1 <- NULL
new_df$District <- NULL
WHHP_sp@data <- new_df
summary(WHHP_sp@data)

#增加列(法1)
pop <-new_df$Avg_Pop
area <- new_df$Avg_Shap_1
den <-pop/area 
new_df["Pop_Den"] <- den
WHHP_sp@data <- new_df
summary(WHHP_sp@data)
#法2
den <- data.frame(den)
rownames(den) <- as.character(as.numeric(rownames(den))-1)#调整行名
names(den) <-"Pop_Den" 
WHHP_sp <-spCbind(WHHP_sp,den) 
summary(WHHP_sp@data)

#4.2.2sf
library(sf)
library(dplyr)
WHHP_sf<-read_sf("WHHP_2015.shp")
WHHP_att<-st_drop_geometry(WHHP_sf)
class(WHHP_att)
summary(WHHP_att)

#删除列(法1)
WHHP_att$FID_1_1<-NULL
WHHP_att$District<-NULL
summary(WHHP_att)
#法2
WHHP_att<-WHHP_att[,!names(WHHP_att)%in%c("FID_1_1","District")]
#法3
WHHP_att<-select(WHHP_att,-c(FID_1_1,District))

#新增列(法1)
pop<-WHHP_att$Avg_Pop
area<-WHHP_att$Avg_Shap_1
den <-pop/area
WHHP_att$Pop_Den<-den
summary(WHHP_att)
#法2
den<-data.frame(den)
names(den)<-"Pop_Den"
WHHP_att<-cbind(WHHP_att,den)
summary(WHHP_att)


#4.3.1Spatial*DataFrame对象
WHZZQ_sp <- readShapePoints("WHSWZZ_ZZQ.shp", verbose=T, proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs"))
WHRD_sp <- readShapeLines("WHRD.shp", verbose=T, proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs"))
WHDis_sp <- readShapePoly("WHDistrict.shp", verbose=T, proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs"))
#coordinates函数
coord_spt<- coordinates(WHZZQ_sp)
plot(WHZZQ_sp)
points(coord_spt, col="red")

coord_spl<- coordinates(WHRD_sp)
plot(WHRD_sp)
for(i in 1:length(coord_spl))
  points(coord_spl[[i]][[1]], col="red",cex=0.4)

coord_spol<- coordinates(WHDis_sp)
plot(WHDis_sp)
points(coord_spol, col="red")

#bbox函数
bbox(WHZZQ_sp)
bbox(WHRD_sp)
bbox(WHDis_sp)

#4.3.2simple feature对象
WHZZQ_sf <- read_sf("WHSWZZ_ZZQ.shp")
WHRD_sf<-read_sf("WHRD.shp")
WHDis_sf<-read_sf("WHDistrict.shp")
#st_coordinates函数
coord_sfpt<-st_coordinates(WHZZQ_sf$geometry)
class(coord_sfpt)
coord_sfpt<-data.frame(coord_sfpt)
plot(WHZZQ_sf$geometry,pch=4)
points(coord_sfpt,col="red")

coord_sfl<-st_coordinates(WHRD_sf$geometry)
class(coord_sfl)
coord_sfl<-data.frame(coord_sfl)
plot(WHRD_sf$geometry)
for(i in 1:nrow(coord_sfl)){
  points(coord_sfl[i,],col="red",cex=0.4)
}

coord_sfpol<-st_coordinates(WHDis_sf$geometry)
class(coord_sfpol)
coord_sfpol<-data.frame(coord_sfpol)
plot(WHDis_sf$geometry)
for(i in 1:nrow(coord_sfpol)){
  points(coord_sfpol[i,],col="red")
}

#st_centroid函数
WHDis_sf$geometry <- st_make_valid(WHDis_sf$geometry)
WHDis_sf_cen<-st_centroid(WHDis_sf$geometry)
plot(WHDis_sf$geometry)
plot(WHDis_sf_cen,col="red",add=TRUE)

#st_bbox函数
st_bbox(WHZZQ_sf)
st_bbox(WHRD_sf)
st_bbox(WHDis_sf)

#st_convex_hull函数
par(mfrow=c(1,2))

s1<-rbind(c(0,0),c(1,1),c(2,1))
s2<-rbind(c(0,2),c(1,3),c(0,3))
ls_sfc<-st_sfc(
  st_linestring(s1),
  st_linestring(s2)
)
ls_sf<-st_sf(id=c(1,2),geometry=ls_sfc,crs=4326)
#不合并
ls_hull<-st_convex_hull(ls_sf$geometry)
plot(ls_hull,border="red")
plot(ls_sf$geometry,add=TRUE)
title("不合并")
#合并
ls_sf_un<-st_union(ls_sf$geometry)
ls_un_hull<-st_convex_hull(ls_sf_un)
plot(ls_un_hull,border="red")
plot(ls_sf_un,add=TRUE)
title("合并")
par(mfrow=c(1,1))

#st_length函数
st_length(WHRD_sf$geometry)

#st_area函数
st_area(WHDis_sf$geometry)

#4.4遥感影像数据分析
#4.4.1影像信息统计
library(terra)
r<-rast("MOD09A1.A2019137.h27v05.061.2020294200410.hdf")
r

dim(r)
ncell(r)
nlyr(r)
names(r)
res(r)
crs(r)

#4.4.2波段信息分析
#(1)单个波段绘制
par(mfrow = c(2,2))
plot(r[[1]], main = "Red", col = gray(0:100 / 100))
plot(r[[3]], main = "Blue", col = gray(0:100 / 100))
plot(r[[4]], main = "Green", col = gray(0:100 / 100))
plot(r[[2]], main = "NIR", col = gray(0:100 / 100))
par(mfrow = c(1,1))

#(2)不同波段组合
#真彩色
Modis_RGB<-c(r[[1]],r[[4]],r[[3]])
Modis_RGB
plotRGB(Modis_RGB, stretch="lin")
#假彩色
Modis_FCC<-c(r[[2]],r[[1]],r[[4]])
Modis_FCC
plotRGB(Modis_FCC, stretch="lin")

#(3)不同波段相关性
s<-r[[1:3]]
names(s)<-c("Red","NIR","Blue")
pairs(s, main = "Red versus NIR versus Blue")

#4.4.3归一化植被指数计算
r<-clamp(r, 0, 1)
ndvi <- (r[[2]] - r[[1]]) /(r[[2]] + r[[1]])
plot(ndvi, main="NDVI")

#4.5空间数据基础分析
#sp
#gUnion函数
WHDis1_sp <- readShapePoly("WHDistrict_p1.shp", proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs"))
WHDis2_sp <- readShapePoly("WHDistrict_p2.shp", proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs"))
plot(WHDis1_sp, border="blue", xlim=bbox(WHDis_sp)[1,], ylim=bbox(WHDis_sp)[2,])
plot(WHDis2_sp, border="red",add=T)

library(rgeos)
WHDis1_sp<-gBuffer(WHDis1_sp, byid = TRUE, width = 0)
WHDis2_sp<-gBuffer(WHDis2_sp, byid = TRUE, width = 0)
WHDis_un_sp <- gUnion(WHDis1_sp, WHDis2_sp, byid=T)
plot(WHDis_un_sp, border="blue")

#gUnaryUnion函数
plot(WHDis_un_sp, border="grey")
plot(gUnaryUnion(WHDis1_sp), border= "blue", add=T, lwd=2)
plot(gUnaryUnion(WHDis2_sp), border= "red", add=T, lwd=2)
#提取特定属性的数据
WHZZQ_hs_sp<-WHZZQ_sp[WHZZQ_sp$District=="Hongshan",]
plot(WHZZQ_sp,col="grey")
plot(WHZZQ_hs_sp,col="red",add=T)

WHRD_tuk_sp <- WHRD_sp[WHRD_sp$fclass=="trunk" | WHRD_sp$fclass == "trunk_link",]
plot(WHRD_sp, col="grey")
plot(WHRD_tuk_sp, col="red", lwd=1.5, add=T)

#gBuffer生成缓冲区
WHZZQ_sp_utm <- spTransform(WHZZQ_hs_sp, CRS("+proj=utm +zone=50 +datum=WGS84 +units=m +no_defs"))
WHRD_sp_utm <- spTransform(WHRD_tuk_sp, CRS("+proj=utm +zone=50 +datum=WGS84 +units=m +no_defs"))
WHDis_sp_utm <- spTransform(WHDis_sp, CRS("+proj=utm +zone=50 +datum=WGS84 +units=m +no_defs"))

WHZZQ_hs_buf <- gBuffer(WHZZQ_sp_utm, width=500)
plot(WHZZQ_hs_buf, col="green")
plot(WHZZQ_sp_utm, add=T, cex=0.5)
WHRD_tuk_buf <- gBuffer(WHRD_sp_utm, width=500)
plot(WHRD_tuk_buf, col="green")
plot(WHRD_sp_utm, add=T)
WHDis_buf <- gBuffer(WHDis_sp_utm, width=1000)
plot(WHDis_buf, col="green")
plot(WHDis_sp_utm, col="grey",add=T)

#gDelaunayTriangulation函数：德劳内三角剖分
set.seed(123)
spt_rand <- spsample(WHDis_sp, 100, type="random")
spt_rand_dt <- gDelaunayTriangulation(spt_rand)
plot(WHDis_sp, col="grey")
plot(spt_rand_dt, col="green", add=T)
plot(spt_rand, col="red", add=T)


#sf
#st_union函数
WHDis1 <- read_sf("WHDistrict_p1.shp")
WHDis2 <- read_sf("WHDistrict_p2.shp")
WHDis_bbox<-st_bbox(WHDis_sf)
plot(WHDis1$geometry,border="blue",xlim = c(WHDis_bbox["xmin"],WHDis_bbox["xmax"]), ylim = c(WHDis_bbox["ymin"],WHDis_bbox["ymax"]))
plot(WHDis2$geometry,border="red",add=TRUE)

WHDis1$geometry <- st_make_valid(WHDis1$geometry)
WHDis2$geometry <- st_make_valid(WHDis2$geometry)
WHDis_un<-st_union(WHDis1,WHDis2)
plot(WHDis_un$geometry,border="blue")

#根据属性提取数据
WHZZQ_hs_sf<-WHZZQ_sf[WHZZQ_sf$District=="Hongshan",]
plot(WHZZQ_sf$geometry,col="grey")
plot(WHZZQ_hs_sf$geometry,col="red",add=TRUE)

WHRD_tuk_sf<-WHRD_sf[WHRD_sf$fclass=="trunk"|WHRD_sf$fclass=="trunk_link",]
plot(WHRD_sf$geometry,col="grey")
plot(WHRD_tuk_sf$geometry,col="red",lwd=1.5,add=TRUE)

#st_buffer函数
WHZZQ_hs_buf<-st_buffer(WHZZQ_hs_sf,dist = 500)
plot(WHZZQ_hs_buf$geometry,col="green")
plot(WHZZQ_hs_sf$geometry,add=TRUE,cex=0.5,pch=3)

WHRD_tuk_buf<-st_buffer(WHRD_tuk_sf,dist=500)
plot(WHRD_tuk_buf$geometry,col="green")
plot(WHRD_tuk_sf$geometry,add=TRUE)

WHDis_sf$geometry <- st_make_valid(WHDis_sf$geometry)
WHDis_buf<-st_buffer(WHDis_sf,dist = 1000)
plot(WHDis_buf$geometry,col="green")
plot(WHDis_sf$geometry,col="grey",add=TRUE)

#st_voronoi函数
set.seed(123)
point<-st_sample(WHZZQ_hs_sf$geometry,100)
box<-st_bbox(WHZZQ_hs_sf$geometry)
box_polygon<-st_polygon(list(rbind(c(box[1],box[2]),c(box[3],box[2]),c(box[3],box[4]),c(box[1],box[4]),c(box[1],box[2]))))
v<-st_voronoi(point,box_polygon)
v_box<-st_bbox(v)
new_v_box<-c(v_box[1]+0.25*(v_box[3]-v_box[1]),
             v_box[2]+0.25*(v_box[4]-v_box[2]),
             v_box[3]-0.25*(v_box[3]-v_box[1]),
             v_box[4]-0.25*(v_box[4]-v_box[2]))
new_v_box_polygon<-st_polygon(list(rbind(c(new_v_box[1],new_v_box[2]),c(new_v_box[3],new_v_box[2]),c(new_v_box[3],new_v_box[4]),c(new_v_box[1],new_v_box[4]),c(new_v_box[1],new_v_box[2]))))
plot(v,col=0,border="blue")
#plot(v,col=0,border="blue",xlim=c(new_v_box[1],new_v_box[3]),ylim=c(new_v_box[2],new_v_box[4]))
plot(point,col="red",add=TRUE)
plot(box_polygon,add=TRUE)

#4.6
#sp
#计算距离矩阵
dmat1 <- gDistance(WHZZQ_sp_utm, byid=T)
#gWithinDistance函数：检验对应空间对象位置是否在一定的距离阈值范围之内（通过参数dist设定）
dist100 <- gWithinDistance(WHZZQ_sp_utm, WHRD_sp_utm, dist=100, byid=T)
bbox_ZZQ_hs<-bbox(WHZZQ_sp_utm)
plot(WHRD_sp_utm,xlim = c(bbox_ZZQ_hs[1,1], bbox_ZZQ_hs[1,2]),ylim = c(bbox_ZZQ_hs[2,1], bbox_ZZQ_hs[2,2]))
plot(WHZZQ_sp_utm[as.logical(apply(dist100, 2, sum)),], pch=3, col="red", add=T)
#gNearestPoints函数：查看两个空间对象之间的最临近的两个点
l1 <- Line(cbind(c(1,2,3),c(3,2,2)))
S1 = SpatialLines(list(Lines(list(l1), ID="a")))
Poly1 = Polygon(cbind(c(2,4,4,1,2),c(3,3,5,4,4)))
Polys1 = SpatialPolygons(list(Polygons(list(Poly1), "s1")))
plot(S1, col="blue",xlim=c(1,4), ylim=c(2,5))
plot(Polys1, add=T)
plot(gNearestPoints(S1, Polys1), add=TRUE, col="red", pch=7)
lines(coordinates(gNearestPoints(S1, Polys1)), col="red", lty=3)
#gIntersection函数：求交运算
WHDis_sp<-gBuffer(WHDis_sp, byid = TRUE, width = 0) # WHBou_sp原本有自相交 所以invalid
WHDis_dt <- gIntersection(WHDis_sp, spt_rand_dt)
plot(WHDis_dt, col="green", xlim=bbox(WHDis_sp)[1,], ylim=bbox(WHDis_sp)[2,], lwd=3)
plot(WHDis_sp, lty=2, add=T)
plot(spt_rand_dt, lty=3, add=T)
#求异运算函数gDifference和gSymdifference
river <- readShapePoly("YangtzeRiver.shp", proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs"))
plot(WHDis_sp, col="grey")
plot(river, col="green", add=T)
#gDifference函数
WHDis_dif <- gDifference(WHDis_sp, river, byid=T)
plot(WHDis_dif, col="grey")
#gSymdifference函数
WHDis_symdif <- gSymdifference(WHDis_sp, river)
plot(WHDis_symdif , col="grey")


#sf
#st_distance函数：计算空间对象之间的距离
dmat1<-st_distance(WHZZQ_hs_sf$geometry,WHZZQ_hs_sf$geometry)

#st_is_within_distance函数：检验对应空间对象位置是否在一定的距离阈值范围之内
dist100<-st_is_within_distance(WHZZQ_sf$geometry,WHRD_tuk_sf$geometry,dist = 100,sparse = FALSE)
WHZZQ_100<-WHZZQ_sf[as.logical(apply(dist100,1,sum)),]
plot(WHRD_tuk_sf$geometry,col="grey")
plot(WHZZQ_100$geometry,col="red",pch=3,add=TRUE)

#st_nearest_points函数:查看两个空间对象之间的最临近点
s1<-st_linestring(rbind(c(1,3),c(2,2),c(3,2)))
p1<-st_polygon(list(rbind(c(2,3),c(4,3),c(4,5),c(1,4),c(3,4),c(2,3))))
n<-st_nearest_points(s1,p1)
plot(s1,col="blue",xlim=c(1,4),ylim=c(2,5))
plot(p1,add=TRUE)
plot(n,col="red",lty=3,add=TRUE)
points(st_coordinates(n),pch=7,col="red")

#st_intersection函数：获取两个空间对象的公共部分
v_envelope<-st_intersection(st_cast(st_sfc(v)),box_polygon)
plot(v,col=0,border="grey",lty=3,xlim=c(new_v_box[1],new_v_box[3]),ylim=c(new_v_box[2],new_v_box[4]))
plot(v_envelope,col="green",add=TRUE)
plot(point,col="red",add=TRUE)

#求异运算函数st_difference和st_sym_difference
river<-read_sf("YangtzeRiver.shp")
plot(WHDis_sf$geometry,col="grey")
plot(river$geometry,col="green",add=TRUE)
#st_difference函数
WHDis_dif<-st_difference(WHDis_sf$geometry,river$geometry)
plot(WHDis_dif,col="grey")
#st_sym_difference函数
WHDis_symdif<-st_sym_difference(st_union(WHDis_sf$geometry),
                                 st_union(river$geometry))
plot(WHDis_symdif,col="grey")

#st_touches
Hongshan<-WHDis_sf[WHDis_sf$name=="Hongshan",]
Hongshan_touch<-WHDis_sf[Hongshan,op=st_touches]
plot(WHDis_sf$geometry,col="grey")
plot(Hongshan_touch$geometry,col="red",add=TRUE)
plot(Hongshan$geometry,col="blue",add=TRUE)


#4.7属性与空间关联

#用武汉市住宅区点数据和住宅区面数据
joined_data <- st_join(WHZZQ_sf, WHDis_sf)
joined_data
summary(joined_data)
library(ggplot2)
ggplot() +
  geom_sf(data = WHDis_sf, fill = "lightblue", color = "black") +
  geom_sf(data = WHZZQ_sf, color = "red", size = 3) +
  geom_sf(data = joined_data, aes(color = as.factor(District)), size = 2) +
  labs(color = "Polygon ID") +
  theme_minimal()
