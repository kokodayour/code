install.packages("sp")
install.packages("sf")
install.packages("terra")
###重要！！！一定要先下载并安装RTools，然后配置环境变量，再下载这几个包
install.packages("D:/R/package/rgdal_1.6-7.tar.gz", repos = NULL, type = "source")
install.packages("D:/R/package/maptools_1.1-8.tar.gz", repos = NULL, type = "source")
install.packages("D:/R/package/rgeos_0.6-4.tar.gz", repos = NULL, type = "source")
library(sp)
library(sf)
library(terra)
library(rgdal)
library(maptools)



#查询派生类的细节
library(sp)
getClass("Spatial")

#空间数据的坐标参考系
EPSG <- make_EPSG()
EPSG[grep("China Geodetic Coordinate System", EPSG$note), ]
CRS("+init=epsg:4490")
showWKT("+init=epsg:4490")
showP4(showWKT("+init=epsg:4490"))


##3.2.1.1点数据
x = c(1,2,3,4,5)
y = c(3,2,5,1,4)
Spt <- SpatialPoints(cbind(x,y))
class(Spt)
plot(Spt)
Spt <- SpatialPoints(list(x,y))
class(Spt)
plot(Spt)
Spt <- SpatialPoints(data.frame(x,y))
class(Spt)
plot(Spt)

#制作SpatialPointsDataFrame对象
Spt_df <- SpatialPointsDataFrame(Spt, data=data.frame(x,y))
class(Spt_df)
str(Spt_df)
Spt_df@data

##3.2.1.2线数据
l1 <- cbind(c(1,2,3),c(3,2,2))
l1a <- cbind(l1[,1]+.05,l1[,2]+.05)
l2 <- cbind(c(1,2,3),c(1,1.5,1))
Sl1 <- Line(l1)
Sl1a <- Line(l1a)
Sl2 <- Line(l2)
S1 = Lines(list(Sl1, Sl1a), ID="a")
S2 = Lines(list(Sl2), ID="b")
Sl = SpatialLines(list(S1,S2))
cols <- data.frame(c("red", "blue"))
Sl_df <-SpatialLinesDataFrame(Sl, cols, match.ID = F)
summary(Sl_df)

#观察SpatialLinesDataFrame组成结构
str(Sl_df)
plot(Sl_df, col=c("red", "blue"))


##3.2.1.3制作面数据对象
Poly1 = Polygon(cbind(c(2,4,4,1,2), c(2,3,5,4,2)))
Poly2 = Polygon(cbind(c(5,4,2,5), c(2,3,2,2)))
Poly3 = Polygon(cbind(c(4,4,5,10,4), c(5,3,2,5,5)))
Poly4 = Polygon(cbind(c(5,6,6,5,5), c(4,4,3,3,4)), hole = TRUE)
Polys1 = Polygons(list(Poly1), "s1")
Polys2 = Polygons(list(Poly2), "s2")
Polys3 = Polygons(list(Poly3, Poly4), "s3/4")
SPoly = SpatialPolygons(list(Polys1,Polys2,Polys3), 1:3)
SPoly_df <- SpatialPolygonsDataFrame(SPoly, data.frame(coordinates(SPoly)), match.ID = F)

#观察SpatialPolygonsDataFrame对象的组成结构
str(SPoly_df)
plot(SPoly_df, col = 1:3, pbg="white")

##3.2.1.4栅格数据
sp_df = data.frame(z = c(1:6,NA,8,9),
                   xc = c(1,1,1,2,2,2,3,3,3),
                   yc = c(rep(c(0, 1.5, 3),3)))
coordinates(sp_df) <- ~xc+yc
gridded(sp_df) <- TRUE
str(sp_df)
image(sp_df["z"])
cc = coordinates(sp_df)
z=sp_df[["z"]]
zc=as.character(z)
zc[is.na(zc)]="NA"
text(cc[,1], cc[,2], zc)

#SpatialGridsDataFrame对象结构
grd <- GridTopology(c(1,1), c(1,1), c(10,10))
sg_df <- SpatialGridDataFrame(grid = grd, data = data.frame(coordinates(grd)))
str(sg_df)
plot(sg_df)
text(coordinates(sg_df), labels=row.names(sg_df))


##3.2simple feature
setwd("E:/R_course/Chapter3/Data") #根据实际情况替换 
getwd()
WHZZQ_sf <- read_sf("WHSWZZ_ZZQ.shp")
print(WHZZQ_sf,n=3)

#3.2.2.1 点数据
p1<-st_point(c(1,2))
str(p1)
p2<-st_point(c(1,2,3))
str(p2)
p3<-st_point(c(1,2,3),"XYM")
str(p3)
p4<-st_point(c(1,2,3,4))
str(p4)

graphics.off()
mp<-st_multipoint(rbind(c(1,3),c(2,2),c(3,5),c(4,1),c(5,4)))
mp
str(mp)
plot(mp)

#3.2.2.2 线数据
#LINESTRING
s1<-rbind(c(1,3),c(2,2),c(3,2))
ls<-st_linestring(s1)
#MULTISTRING
s2<-rbind(c(2,3), c(3,3), c(4,2), c(4,1))
s3<-rbind(c(0,1),c(1,1))
mls<-st_multilinestring(list(s1,s2,s3))
#观察数据组成
ls
str(ls)
mls
str(mls)
plot(mls,col="red")

#3.2.2.3 面数据
#without holes
p<-st_polygon(list(rbind(c(4,2),c(4,3),c(5,3),c(4,2))))
#with holes
p1<-rbind(c(0,0), c(1,0), c(3,2), c(2,4), c(1,4), c(0,0))
p2<-rbind(c(1,1), c(1,2), c(2,2), c(1,1))
p3<-rbind(c(1,2), c(2,3), c(2,2), c(1,2))
pol<-st_polygon(list(p1,p2,p3))
#MULTIPOLYGON
p4<-rbind(c(3,0), c(4,0), c(4,1), c(3,1), c(3,0))
p5<-rbind(c(3.3,0.3), c(3.3,0.8), c(3.8,0.8), c(3.8,0.3), c(3.3,0.3))
p6<-rbind(c(3,3), c(4,2), c(4,3), c(3,3))
mpol<-st_multipolygon(list(list(p1,p2,p3),list(p4,p5),list(p6)))
#观察数据结构
p
str(p)
pol
str(pol)
mpol
str(mpol)
plot(mpol,col="red")

#3.2.2.4 复杂对象
p <- rbind(c(3.2,4), c(3,4.6), c(3.8,4.4), c(3.5,3.8), c(3.4,3.6), c(3.9,4.5))
mp <- st_multipoint(p)
p1 <- rbind(c(0,0), c(1,0), c(3,2), c(2,4), c(1,4), c(0,0))
p2 <- rbind(c(1,1), c(1,2), c(2,2), c(1,1))
p3 <- rbind(c(3,0), c(4,0), c(4,1), c(3,1), c(3,0))
p4 <- rbind(c(3.3,0.3), c(3.8,0.3), c(3.8,0.8), c(3.3,0.8), c(3.3,0.3))[5:1,]
p5 <- rbind(c(3,3), c(4,2), c(4,3), c(3,3))
mpol <- st_multipolygon(list(list(p1,p2), list(p3,p4), list(p5)))
s1 <- rbind(c(0,3),c(0,4),c(1,5),c(2,5))
ls <- st_linestring(s1)
gc <- st_geometrycollection(list(mp,mpol,ls))
gc
str(gc)
plot(gc,col="red")

#3.2.2.5 栅格数据
# 创建一个5x5的栅格，每个单元格的值为1
graphics.off()
r <- rast(nrows=5, ncols=5, xmin=0, xmax=5, ymin=0, ymax=5)
values(r) <- 1
# 不同单元格设置成不同的值
values(r)[c(1,3,5,7,9)] <- 2
values(r)[c(11,13,15,17,19)] <- 3
values(r)[c(21,23,25)] <- 4
r
plot(r)

#3.2.3 sf数据与data.frame数据的相互转化
#查看坐标系
st_crs(WHZZQ_sf)$proj4string

#sfg→sfc→sf
p_sfc<-st_sfc(
  st_point(c(1,3)),
  st_point(c(2,2)),
  st_point(c(3,5)),
  st_point(c(4,1)),
  st_point(c(5,4))
)
id<-c(1,2,3,4,5)
p_sf<-st_sf(id=id,geometry=p_sfc,crs=4326)
p_sf

#sf→dataframe
p_df<-as.data.frame(p_sf)
p_df

#sp和sf互相转化
WHZZQ_sp<-as(WHZZQ_sf,"Spatial")
class(WHZZQ_sp)
WHZZQ_sf<-st_as_sf(WHZZQ_sp)
class(WHZZQ_sf)

pt1 <- st_point(c(0,1))
pt2 <- st_point(c(1,1))
sf_pt <- st_sfc(pt1, pt2)
df <- data.frame(at = 1:2)
df$geom <- sf_pt
sf_pt <- st_as_sf(df)
class(sf_pt)



#3.3.1空间数据读入
#sp
WHZZQ_sp <- readShapePoints("WHSWZZ_ZZQ.shp", verbose=T, proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs"))
summary(WHZZQ_sp)
plot(WHZZQ_sp)

WHRD_sp <- readShapeLines("WHRD.shp", verbose=T, proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs"))
summary(WHRD_sp)
plot(WHRD_sp)

WHDis_sp <- readShapePoly("WHDistrict.shp", verbose=T, proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs"))
summary(WHDis_sp)
plot(WHDis_sp)

#sf
WHZZQ_sf <- read_sf("WHSWZZ_ZZQ.shp")
summary(WHZZQ_sf)
plot(WHZZQ_sf$geometry,pch=3)

WHRD_sf<-read_sf("WHRD.shp")
summary(WHRD_sf)
plot(WHRD_sf$geometry)

WHDis_sf<-read_sf("WHDistrict.shp")
summary(WHDis_sf)
plot(WHDis_sf$geometry)

#3.3.2空间数据导出
#sp
writePointsShape(WHZZQ_sp, fn="WHZZQ_sp_w.shp")
writeLinesShape(WHRD_sp, fn="WHRD_sp_w.shp")
writePolyShape(WHDis_sp, fn="WHDistrict_sp_w.shp")
#sf
write_sf(WHZZQ_sf,"WHZZQ_sf_w.shp")
write_sf(WHRD_sf,"WHRD_sf_w.shp")
write_sf(WHDis_sf,"WHDistrict_sf_w.shp")

#3.3.3遥感影像导入
r<-rast("MOD09A1.A2019137.h27v05.061.2020294200410.hdf")
res(r)
names(r)
plotRGB(r, r = 1, g = 4, b = 3, stretch="lin")

#遥感影像导出
x <- writeRaster(r, "test_output.tif", overwrite=TRUE)
x
