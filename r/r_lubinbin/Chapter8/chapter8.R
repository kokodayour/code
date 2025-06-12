install.packages("gstat")
install.packages("automap")
install.packages("spdep")
install.packages("GWmodel")
install.packages("spatstat")

library(gstat)
library(automap)
library(spdep)
library(GWmodel)
library(spatstat)


setwd("D:/Chapter8/data") #修改为存放示例数据的文件路径
getwd()
require(sf)
require(dplyr)
WHHP<-read_sf("WHHP_2015.shp")
WHHP$Pop_Den <- WHHP$Avg_Pop/WHHP$Avg_Shap_1
names(WHHP)
WHHP <- WHHP[, -c(1:9, 19, 22:23)]
names(WHHP)
names(WHHP) <- c("Pop", "Annual_AQI", "Green_Rate", "GDP_per_Land", "Rev_per_Land", "FAI_per_Land", 
                 "TertI_Rate", "Avg_HP", "Den_POI", "Length","Area","geometry","Pop_Den")


###8.2.1最邻近插值
require(terra)
WHHP.rast <- rast(nrows = 50, ncols = 60, ext = ext(WHHP))
WHHP.rast <- rasterize(WHHP, WHHP.rast, field = "Avg_HP")

grid <- as.points(WHHP.rast, na.rm = TRUE) 
grid.sf <- st_as_sf(grid)
st_crs(grid.sf) <- st_crs(WHHP)
dist_matrix <- st_distance(grid.sf, WHHP)
nearest_dat <- apply(dist_matrix, 1, which.min)

grid$nn <- WHHP$Avg_HP[nearest_dat]
grid_raster <- rasterize(grid, WHHP.rast, field = "nn")
plot(grid_raster,main = "Average price in Wuhan (Nearest-neighbor interpolation)")

###8.2.2IDW插值
WHHP_centroids <- st_centroid(WHHP)
g1 <- gstat(formula = Avg_HP ~ 1, locations = WHHP_centroids, set = list(idp = 0.3))  # idp = 0.3
g2 <- gstat(formula = Avg_HP ~ 1, locations = WHHP_centroids, set = list(idp = 10))   # idp = 10
WHHP_grid <- as.data.frame(xyFromCell(WHHP.rast, 1:ncell(WHHP.rast)))
colnames(WHHP_grid) <- c("x", "y")
WHHP_grid <- st_as_sf(WHHP_grid, coords = c("x", "y"), crs = st_crs(WHHP_centroids))

z1 <- predict(g1, newdata = WHHP_grid)
z2 <- predict(g2, newdata = WHHP_grid)
WHHP.rast[] <- z1$var1.pred
z1_raster <- WHHP.rast
WHHP.rast[] <- z2$var1.pred
z2_raster <- WHHP.rast

crs(z1_raster) <- st_crs(WHHP)$proj4string
crs(z2_raster) <- st_crs(WHHP)$proj4string
z1_raster <- mask(z1_raster, WHHP)
z2_raster <- mask(z2_raster, WHHP)
plot(z1_raster, main = "IDW Interpolation (beta = 0.3)")
plot(z2_raster, main = "IDW Interpolation (beta = 10)")


###8.2.3克里金插值
g = gstat(formula = WHHP_centroids$Avg_HP~ 1, data = WHHP_centroids)
ev = variogram(g) 
plot(ev,cex=1.5,pch="*")

v = autofitVariogram(formula = WHHP_centroids$Avg_HP~ 1, input_data = WHHP_centroids)
plot(v,pch="*",lwd=1.5,cex=2)

g_OK = gstat(formula = WHHP_centroids$Avg_HP~1, data = WHHP_centroids, model = v$var_model)
z <- predict(g_OK, newdata = WHHP_grid)
WHHP.rast <- rast(nrows = 50, ncols = 60, ext = ext(WHHP))
WHHP.rast[] <- z$var1.pred
z_raster <- WHHP.rast

crs(z_raster) <- st_crs(WHHP)$proj4string
z_raster <- mask(z_raster, WHHP)
plot(z_raster,main= "Ordinary Kriging")


###8.3.1全局空间自相关
WHHPnb <- knn2nb(knearneigh(WHHP_centroids, k = 4))
WHHPnb_s <- make.sym.nb(WHHPnb) 
plot(st_geometry(WHHP))
plot(nb2listw(WHHPnb_s), st_coordinates(WHHP_centroids), add=T, col="blue")


col.W<-nb2listw(WHHPnb_s,style = "W")
str(moran(WHHP$Avg_HP ,col.W,length(WHHP$Avg_HP),Szero(col.W)))

moran_WHHP_rn <- moran.test(WHHP$Avg_HP, listw = nb2listw(WHHPnb_s))
moran_WHHP_rn


moran_WHHP_nor <- moran.test(WHHP$Avg_HP, listw = nb2listw(WHHPnb_s), randomisation = FALSE)
moran_WHHP_nor

str(geary(WHHP$Avg_HP,col.W,length(WHHP$Avg_HP),length(WHHP$Avg_HP)-1,Szero(col.W)))

GR_WHHP_rn <- geary.test(WHHP$Avg_HP, listw = nb2listw(WHHPnb_s))
GR_WHHP_rn
GR_WHHP_nor<- geary.test(WHHP$Avg_HP, listw = nb2listw(WHHPnb_s), randomisation = FALSE)
GR_WHHP_nor


###8.3.2局部空间自相关
require(ggplot2)
require(ggspatial)
require(spdep)
require(sf)

# 计算局部莫兰统计量
lm_WHHP <- localmoran(WHHP$Avg_HP, listw = nb2listw(WHHPnb_s, style = "W"))
WHHP$lm <- lm_WHHP[,1]

# 删除局部莫兰统计量不在区间 [-1, 1] 范围的数据
WHHP_del <- WHHP %>% filter(lm > -1 & lm <= 1)
ggplot() + geom_sf(data = WHHP_del, aes(fill = lm)) + 
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0, name = "Local Moran I") +
  theme_minimal() + labs(title = "Local Moran Statistic") +
  theme(legend.position = "right") + 
  annotation_scale(location = "bl") +    
  annotation_north_arrow(location = "tr", which_north = "true", style = north_arrow_fancy_orienteering)


moran.plot(WHHP$Avg_HP,col.W,pch = 19)

library(ggspatial)
library(ggplot2)
G_WHHP <- localG(WHHP$Avg_HP, listw = nb2listw(WHHPnb_s,style = "W"))
lenData <- length(G_WHHP)
WHHP$G<- G_WHHP[1: lenData]
WHHP_del <- WHHP %>% filter(G >= 0 & G <= 2)
ggplot() +
  geom_sf(data = WHHP_del, aes(fill = G)) + 
  scale_fill_gradient2(low = "red", mid = "white", high = "blue", midpoint = 0, name = "Local Moran I") +
  theme_minimal() +  labs(title = "Local Geary's C statistic") +
  theme(legend.position = "right") +
  annotation_scale(location = "bl") +   
  annotation_north_arrow(location = "tr", which_north = "true",   style = north_arrow_fancy_orienteering)


###8.4空间回归分析
require(psych)
par(family = "serif", pch = 16, cex = 1.5, cex.axis = 1.5, cex.lab = 1.5)
pairs.panels(st_drop_geometry(WHHP), 
             method = "pearson", 
             smooth = FALSE,       
             hist.col = "#00AFBB",   
             density = TRUE, 
             ellipses = TRUE,     
             lm = TRUE, 
             stars = TRUE, 
             ci = TRUE, 
             cor.cex = 2)

###8.4.1线性回归
lm_WH<-lm(Avg_HP~GDP_per_Land,data=WHHP)
summary(lm_WH)


plot(WHHP$GDP_per_Land, WHHP$Avg_HP, pch="+",
     xlab = "GDP per Land", 
     ylab = "Average HP", 
     main = "Scatterplot with Regression Line")
abline(lm_WH, col = "blue")

lm_WH<-lm(Avg_HP~Annual_AQI + Green_Rate + GDP_per_Land + Rev_per_Land + FAI_per_Land + TertI_Rate + Den_POI + Pop_Den, data=WHHP)
summary(lm_WH)


###8.4.2空间滞后/误差/杜宾模型
require(spdep)
require(spatialreg)
# 构建邻接矩阵和空间权重矩阵
nb <- poly2nb(WHHP) 
listW <- nb2listw(nb, zero.policy = TRUE) 
# 空间滞后模型 (SLM)
slm <- lagsarlm(Avg_HP ~ Green_Rate + GDP_per_Land + Rev_per_Land + Den_POI + Pop_Den, data = WHHP, listw = listW, zero.policy = TRUE)
summary(slm)


# 空间误差模型 (SEM)
sem <- errorsarlm(Avg_HP ~ Green_Rate + GDP_per_Land + Rev_per_Land + Den_POI + Pop_Den, data = WHHP, listw = listW, zero.policy = TRUE)

# 输出空间误差模型结果
summary(sem)


sdm <- lagsarlm(Avg_HP ~ Green_Rate + GDP_per_Land + Rev_per_Land + Den_POI + Pop_Den, data = WHHP, listw = listW, zero.policy = TRUE, type = "mixed")
# 输出空间杜宾模型结果
summary(sdm)


###8.4.3.1
require(GWmodel)
DeVar <- "Avg_HP"
InDeVars<- c("Pop",  "Annual_AQI", "Green_Rate", "GDP_per_Land",
             "Rev_per_Land", "FAI_per_Land", "TertI_Rate", "Den_POI","Pop_Den" )
model.sel<-gwr.model.selection(DeVar,InDeVars,data=WHHP,kernel = "gaussian",adaptive=TRUE,bw=10000000000000)
sorted.models <- gwr.model.sort(model.sel, numVars = length(InDeVars), ruler.vector = model.sel[[2]][,2])
model.list <- sorted.models[[1]]
gwr.model.view(DeVar, InDeVars, model.list = model.list)
plot(sorted.models[[2]][,2], col = "black", pch = 20, lty = 5, main = "Alternative view of GWR model selection procedure",ylab = "AICc", xlab = "Model number", type = "b")
abline(v=c(9, 17, 24, 30, 35, 39, 42, 44),lty=3, col="grey")


bw1 <- bw.gwr(Avg_HP~ Green_Rate + GDP_per_Land + Rev_per_Land + Den_POI + Pop_Den, WHHP, kernel="bisquare",adaptive=T,approach="AIC")
gwr.res <- gwr.basic(Avg_HP~ Green_Rate + GDP_per_Land + Rev_per_Land + Den_POI + Pop_Den, WHHP, kernel="bisquare",adaptive=T, bw=bw1)
print(gwr.res)


require(maps)
gwr.res$SDF$lm_residual <- gwr.res$lm$residuals
p1<- ggplot(gwr.res$SDF)+
  geom_sf(aes(fill=lm_residual))+    
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0, name = "Residuals of LM") + 
  annotation_scale(location = "bl", width_hint = 0.1) + 
  annotation_north_arrow(location = "tr", which_north = "true", pad_x = unit(0.1, "in"), pad_y = unit(0.1, "in"), style = north_arrow_fancy_orienteering)
p2<- ggplot(gwr.res$SDF)+
  geom_sf(aes(fill=residual))+    
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0, name = "Residuals of GWR")  +  
  annotation_scale(location = "bl", width_hint = 0.1) + 
  annotation_north_arrow(location = "tr", which_north = "true", pad_x = unit(0.1, "in"), pad_y = unit(0.1, "in"),   style = north_arrow_fancy_orienteering)
require(patchwork)
p1 / p2




p1<- ggplot(gwr.res$SDF)+
  geom_sf(aes(fill=Intercept)) +    
  scale_fill_gradient(trans = "reverse", name="Est. Intercept")  +
  annotation_scale(location = "bl", width_hint = 0.1) + 
  annotation_north_arrow(location = "tr", which_north = "true", pad_x = unit(0.1, "in"), pad_y = unit(0.1, "in"),
                         style = north_arrow_fancy_orienteering)

p2<- ggplot(gwr.res$SDF)+
  geom_sf(aes(fill=Green_Rate))+    
  scale_fill_gradient2(low = "green", mid = "white", high = "red", midpoint = 0, name = "Est. Green_Rate")  +
  annotation_scale(location = "bl", width_hint = 0.1) + 
  annotation_north_arrow(location = "tr", which_north = "true", pad_x = unit(0.1, "in"), pad_y = unit(0.1, "in"),
                         style = north_arrow_fancy_orienteering)
p3<- ggplot(gwr.res$SDF)+
  geom_sf(aes(fill=GDP_per_Land))+    
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0, name = "Est. GDP_per_Land")  +
  annotation_scale(location = "bl", width_hint = 0.1) + 
  annotation_north_arrow(location = "tr", which_north = "true", 
                         pad_x = unit(0.1, "in"), pad_y = unit(0.1, "in"),
                         style = north_arrow_fancy_orienteering)

p4<- ggplot(gwr.res$SDF)+
  geom_sf(aes(fill=Rev_per_Land))+    
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0, name = "Est. Rev_per_Land")  +
  annotation_scale(location = "bl", width_hint = 0.1) + 
  annotation_north_arrow(location = "tr", which_north = "true", 
                         pad_x = unit(0.1, "in"), pad_y = unit(0.1, "in"),
                         style = north_arrow_fancy_orienteering)

p5<- ggplot(gwr.res$SDF)+
  geom_sf(aes(fill=Den_POI))+    
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0, name = "Est. Den_POI")  +
  annotation_scale(location = "bl", width_hint = 0.1) + 
  annotation_north_arrow(location = "tr", which_north = "true", 
                         pad_x = unit(0.1, "in"), pad_y = unit(0.1, "in"),
                         style = north_arrow_fancy_orienteering)

p6<- ggplot(gwr.res$SDF)+
  geom_sf(aes(fill=Pop_Den))+    
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0, name = "Est. Pop_Den")  +
  annotation_scale(location = "bl", width_hint = 0.1) + 
  annotation_north_arrow(location = "tr", which_north = "true", 
                         pad_x = unit(0.1, "in"), pad_y = unit(0.1, "in"),
                         style = north_arrow_fancy_orienteering) 

p<- (p1 | p2) / (p3 | p4) / (p5 | p6)   
ggsave("coefficient_GWR.png", p, width = 16, height = 16, dpi = 300)



###8.4.3.2多尺度GWR模型
mgwr.res <- gwr.multiscale(Avg_HP ~ Green_Rate + GDP_per_Land + Rev_per_Land + Den_POI + Pop_Den,WHHP, kernel="bisquare",adaptive=T)
print(mgwr.res)


require(GISTools)
thematic.map(mgwr.res$SDF, var.names="residual", horiz = FALSE, na.pos = "topleft", scaleBar.pos = "bottomright", legend.pos = "bottomleft", colorStyle = hcl.colors)


gwr.T.pv<-function(Tvalues, enp)
{
  n<-nrow(Tvalues)
  rdf<-n-enp
  var.n<-ncol(Tvalues)
  pvals<-c()
  for (i in 1:var.n)
  {
    pv<-2*pt(abs(Tvalues[,i]), df=rdf, lower.tail = F)
    pvals<-cbind(pvals, pv)
  }
  colnames(pvals)<-paste(colnames(Tvalues),"pv", sep="_")
  pvals
}
tv.df <- st_drop_geometry(mgwr.res$SDF)[,15:20]
pval <- gwr.T.pv(tv.df, mgwr.res$GW.diagnostic$enp)




library(RColorBrewer)
user.cuts <- function(x, n = 5, params = NA)
{
  aa <- params
}
mypalette1 <- c(brewer.pal(3, "Blues")[c(2,1)],brewer.pal(5, "YlOrRd"))
par(family = "serif")

indx.Pop_Den<- which(pval[, "Pop_Den_TV_pv"]<=0.05)
png("Pop_Den.png", res=300, width=24, height=18, unit="cm")

shades <- auto.shading(mgwr.res$SDF$Pop_Den, 
                       cutter =user.cuts,params=c(-20000, -10000, 0, 5000, 10000, 20000), n=7,cols=mypalette1)
choropleth(mgwr.res$SDF,"Pop_Den", shades, border="grey")
plot(st_geometry(mgwr.res$SDF)[indx.Pop_Den], border="black", lwd=1, add=T)
choro.legend(545000, 3376163, shades, title="Est. Pop_Den")
map.scale(525000,3363000,km2ft(5),"Kilometers",4,0.5)
north.arrow(550000,3394566,km2ft(0.35),col="white")
dev.off()

indx.Den_POI<- which(pval[, "Den_POI_TV_pv"]<=0.05)
png("Den_POI.png", res=300, width=24, height=18, unit="cm")

shades <- auto.shading(mgwr.res$SDF$Den_POI, 
                       cutter =user.cuts,params=c(-4000, -1000, 0, 1000, 4000, 8000),
                       n=7,cols=mypalette1)
choropleth(mgwr.res$SDF,"Den_POI", shades, border="grey")
plot(st_geometry(mgwr.res$SDF)[indx.Den_POI], border="black", lwd=1, add=T)
choro.legend(545000, 3376163, shades, title="Est. Den_POI")
map.scale(525000,3363000,km2ft(5),"Kilometers",4,0.5)
north.arrow(550000,3394566,km2ft(0.35),col="white")
dev.off()

indx.Rev_per_Land<- which(pval[, "Rev_per_Land_TV_pv"]<=0.05)
png("Rev_per_Land.png", res=300, width=24, height=18, unit="cm")

shades <- auto.shading(mgwr.res$SDF$Rev_per_Land, 
                       cutter =user.cuts,params=c(-1, -0.5, 0, 0.5, 0.75, 1),
                       n=7, cols=mypalette1)
choropleth(mgwr.res$SDF,"Rev_per_Land", shades, border="grey")
plot(st_geometry(mgwr.res$SDF)[indx.Rev_per_Land], border="black", lwd=1, add=T)
choro.legend(545000, 3376163, shades, title="Est. Rev_per_Land")
map.scale(525000,3363000,km2ft(5),"Kilometers",4,0.5)
north.arrow(550000,3394566,km2ft(0.35),col="white")
dev.off()

indx.GDP_per_Land<- which(pval[, "GDP_per_Land_TV_pv"]<=0.05)
png("GDP_per_Land.png", res=300, width=24, height=18, unit="cm")

shades <- auto.shading(mgwr.res$SDF$GDP_per_Land, 
                       cutter =user.cuts,params=c(-1, -0.5, 0, 0.5, 0.75, 1),
                       n=7,cols=mypalette1)
choropleth(mgwr.res$SDF,"GDP_per_Land", shades, border="grey")
plot(st_geometry(mgwr.res$SDF)[indx.GDP_per_Land], border="black", lwd=1, add=T)
choro.legend(545000, 3376163, shades, title="Est. Green_Rate")
map.scale(525000,3363000,km2ft(5),"Kilometers",4,0.5)
north.arrow(550000,3394566,km2ft(0.35),col="white")
dev.off()

indx.Green_Rate<- which(pval[, "Green_Rate_TV_pv"]<=0.05)
png("Green_Rate.png", res=300, width=24, height=18, unit="cm")

shades <- auto.shading(mgwr.res$SDF$Green_Rate, 
                       cutter = user.cuts,params=c(-500, -200, 0, 200, 500, 1000),
                       n=7,cols=mypalette1)
choropleth(mgwr.res$SDF,"Green_Rate", shades, border="grey")
plot(st_geometry(mgwr.res$SDF)[indx.Green_Rate], border="black", lwd=1, add=T)
choro.legend(545000, 3376163, shades, title="Est. Green_Rate")
map.scale(525000,3363000,km2ft(5),"Kilometers",4,0.5)
north.arrow(550000,3394566,km2ft(0.35),col="white")
dev.off()

indx.intercept <- which(pval[, "Intercept_TV_pv"]<=0.05)
png("Intercept_2015.png", res=300, width=24, height=18, unit="cm")

mypalette1 <- c(brewer.pal(3, "Blues")[c(2,1)],brewer.pal(6, "YlOrRd"))
shades <- auto.shading(WHHP$Avg_HP, cutter =user.cuts, params = c( 6000,10000, 14000, 18000, 22000, 26000), n=8,cols=mypalette1)
choropleth(mgwr.res$SDF,"Intercept", shades, border="grey")
plot(st_geometry(mgwr.res$SDF)[indx.intercept], border="black", lwd=1, add=T)
choro.legend(545000, 3376163, shades, title="Intercept")
map.scale(525000,3363000,km2ft(5),"Kilometers",4,0.5)
north.arrow(550000,3394566,km2ft(0.35),col="white")
dev.off()



###8.5空间点模式分析
ggplot() +
  geom_sf(data = WHHP, fill = "#d9e6f2", color = "black", lwd = 0.5) +  
  geom_sf(data = WHHP_centroids, shape = 3, color = "blue", size = 2) +  
  theme_minimal() +  
  annotation_scale(location = "bl", width_hint = 0.5) +  
  annotation_north_arrow(location = "tr", which_north = "true", 
                         style = north_arrow_fancy_orienteering) 



WHHP_centroids_ppp <- as.ppp(st_coordinates(WHHP_centroids), W = as.owin(st_bbox(WHHP_centroids)))
nearest_neighbor_distances <- nndist(WHHP_centroids_ppp)
mean_nn_distance <- mean(nearest_neighbor_distances)
lambda <- intensity(WHHP_centroids_ppp)
expected_nn_distance <- 1 / (2 * sqrt(lambda))
R <- mean_nn_distance / expected_nn_distance
cat("最近邻比值 R:", R, "\n")


K <- Kest(WHHP_centroids_ppp)
L <- Lest(WHHP_centroids_ppp)
par(mfrow=c(1, 2))
plot(K, main="Ripley's K-function", ylab="K(r)", xlab="Distance r")
plot(L, main="Ripley's L-function", ylab="L(r) - r", xlab="Distance r")
