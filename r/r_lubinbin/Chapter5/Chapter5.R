install.packages("BiocManager")
require(BiocManager)
BiocManager::install("ComplexHeatmap")

install.packages("devtools")
library(devtools)
install_github("Hy4m/linkET")

install.packages("lattice")
install.packages("RColorBrewer")
install.packages("MASS")
install.packages("circlize")
install.packages("corrplot")
install.packages("ggplot2")
install.packages("GGally")
install.packages("psych")
install.packages("vegan")
library(lattice)
library(RColorBrewer)
library(MASS)
library(ComplexHeatmap) #从GitHub下载
library(circlize)
library(corrplot)
library(linkET) #从GitHub下载
library(ggplot2)
library(GGally)
library(psych)
library(vegan)

setwd("E:/R_course/Chapter5/Data")
getwd()

###5.2
library(sf)
WHHP<-read_sf("WHHP_2015.shp")
names(WHHP)
WHHP$Pop_Den <- WHHP$Avg_Pop/WHHP$Avg_Shap_1
names(WHHP)
WHHP <- WHHP[, -c(1:9, 19:23)]
names(WHHP)
names(WHHP) <- c("Pop", "Annual_AQI", "Green_Rate", "GDP_per_Land", "Rev_per_Land", "FAI_per_Land", "TertI_Rate", "Avg_HP", "Den_POI", "geometry","Pop_Den")

###5.2.1散点图
par(mfrow=c(1,2))
plot(WHHP$GDP_per_Land,WHHP$FAI_per_Land,xlab="地均GDP",ylab="地均固定资产投入")
plot(WHHP$GDP_per_Land,WHHP$FAI_per_Land,xlab="地均GDP",ylab="地均固定资产投入",cex=0.5,pch=3,col="blue")
par(mfrow=c(1,1))

###分类
library(dplyr)
sum_hp<-summary(WHHP$Avg_HP)
WHHP <- WHHP %>%  
  mutate(HP_level = case_when(  
    Avg_HP >= sum_hp[[1]] & Avg_HP < sum_hp[[2]] ~ "低", 
    Avg_HP >= sum_hp[[2]] & Avg_HP < sum_hp[[3]] ~ "较低",
    Avg_HP >= sum_hp[[3]] & Avg_HP < sum_hp[[5]] ~ "较高",
    Avg_HP >= sum_hp[[5]] & Avg_HP <= sum_hp[[6]] ~ "高"
  ))
idx1 <- which(WHHP$HP_level=="低")
idx2 <- which(WHHP$HP_level=="较低")
idx3 <- which(WHHP$HP_level=="较高")
idx4 <- which(WHHP$HP_level=="高")
pchs <- c(19,17,14,3)
cols <- c("black","blue","red","purple")
plot(WHHP$Green_Rate[idx1],WHHP$GDP_per_Land[idx1], col=cols[1],pch=pchs[1],ylim=range(WHHP$GDP_per_Land),xlim=range(WHHP$Green_Rate),xlab="绿化率",ylab="地均GDP",cex=0.5)
points(WHHP$Green_Rate[idx2],WHHP$GDP_per_Land[idx2],col=cols[2],pch=pchs[2],cex=0.8)
points(WHHP$Green_Rate[idx3],WHHP$GDP_per_Land[idx3],col=cols[3],pch=pchs[3],cex=0.8)
points(WHHP$Green_Rate[idx4],WHHP$GDP_per_Land[idx4],col=cols[4],pch=pchs[4],cex=0.8)
legend("topright",legend=c("低","较低","较高","高"),title = "房价水平",col=cols,pch=pchs)
#添加网格
grid(nx=20,ny=20,col="grey")
grid(nx=5,ny=5,col="grey",lty=1,lwd=1)


###5.2.2折线图
par(mfrow=c(1,2))
x <- seq(0, 2*pi, len=100)
y<- sin(x)+rnorm(100, 0, 0.1)
plot(x,y,type="l", col="darkblue", lwd=3)
plot(x,y,type="b", col="darkblue",pch=16)

par(mfrow=c(1,2))
plot(x,sin(x), type="l", col="darkblue", lwd=5)
points(x,y,col="darkred", pch=16)
title("plot+points")

plot(x,y,col="darkred",pch=16)
lines(x,sin(x),col="darkblue",lwd=5)
title("plot+lines")


###5.2.3直方图
par(mfrow=c(1,1))
hist(WHHP$Avg_HP,col = "pink",border = "grey",xlab = "房价",ylab = "频数",main = "武汉市房价分布直方图",labels = TRUE)

###修改分组方式
par(mfrow=c(2,3))
hist(WHHP$Avg_HP,col = "pink",border = "grey",breaks = 12,
     xlim = c(4000,26000),ylim=c(0,400),xlab = "房价",ylab = "频数",main = "breaks = 12",labels = TRUE)
hist(WHHP$Avg_HP,col = "pink",border = "grey",breaks = c(4e+03,8e+03,1.2e+04,1.6e+04,2e+04,2.4e+04,2.6e+04),freq=TRUE,
     xlim = c(4000,26000),ylim=c(0,600),xlab = "房价",ylab = "频数",main = "breaks = c(4e+03,8e+03,...,2.4e+04,2.6e+04)",labels = TRUE)
hist(WHHP$Avg_HP,col = "pink",border = "grey",breaks = seq(0,2.5e+04,5e+03),
     xlim = c(4000,26000),ylim=c(0,600),xlab = "房价",ylab = "频数",main = "breaks = seq(0,2.5e+04,5e+03)",labels = TRUE)
hist(WHHP$Avg_HP,col = "pink",border = "grey",breaks = "Scott",
     xlim = c(4000,26000),ylim=c(0,200),xlab = "房价",ylab = "频数",main = "breaks = \"Scott\"",labels = TRUE)
hist(WHHP$Avg_HP,col = "pink",border = "grey",breaks = "FD",
     xlim = c(4000,26000),ylim=c(0,100),xlab = "房价",ylab = "频数",main = "breaks = \"FD\"",labels = TRUE)
hist(WHHP$Avg_HP,col = "pink",border = "grey",breaks = "Sturges",
     xlim = c(4000,26000),ylim=c(0,400),xlab = "房价",ylab = "频数",main = "breaks = \"Sturges\"",labels = TRUE)

###频数改频率 绘制轴须图和核密度图
par(mfrow=c(1,1))
hist(WHHP$Avg_HP,col="pink",freq=FALSE,border="white",xlab="房价",ylab = "频率",main = "武汉市房价频率分布直方图")
rug(jitter(WHHP$Avg_HP))
lines(density(WHHP$Avg_HP),col="darkgreen",lwd=2)

###绘制正态分布曲线
hist(WHHP$Avg_HP,freq=FALSE,col="pink",border="white",xlab="房价",ylab="频率",main="武汉房价频率分布直方图")
data<-WHHP$Avg_HP
x<-seq(min(data),max(data),length=100)
y<-dnorm(x,mean = mean(data),sd = sd(data))
lines(x,y,col="darkgreen",lwd=2)

###plot函数绘制直方图
data <- c(1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5)
freq_table <- table(data)
df <- as.data.frame(freq_table)
plot(as.numeric(as.character(df$data)), df$Freq, type = "h", lwd = 10, col = "skyblue", xlab = "Values", ylab = "Frequency", main = "Histogram Example")


###5.2.4条形图
sum_green<-summary(WHHP$Green_Rate)
WHHP <- WHHP %>%  
  mutate(Green_level = case_when(  
    Green_Rate >= sum_green[[1]] & Green_Rate < sum_green[[4]] ~ "低", 
    Green_Rate >= sum_green[[4]] & Green_Rate <= sum_green[[6]] ~ "高"
  ))

gre_level_num <- st_drop_geometry(WHHP) %>%  
  group_by(Green_level) %>%  
  summarise(count = n(), .groups = 'drop')

barplot(gre_level_num[[2]], names.arg = gre_level_num[[1]], main="不同水平绿化率对应区域的数量", xlab="绿化率水平", ylab="区域数量", col="skyblue", border="black")

###堆砌条形图 分组条形图
breaks_green <- c(sum_green[[1]], sum_green[[4]], sum_green[[6]])
low<-WHHP[WHHP$HP_level=="低",]
low_table <- table(cut(low$Green_Rate, breaks = breaks_green, include.lowest = TRUE))
re_low<-WHHP[WHHP$HP_level=="较低",]
re_low_table <- table(cut(re_low$Green_Rate, breaks = breaks_green, include.lowest = TRUE))
re_high<-WHHP[WHHP$HP_level=="较高",]
re_high_table <- table(cut(re_high$Green_Rate, breaks = breaks_green, include.lowest = TRUE))
high<-WHHP[WHHP$HP_level=="高",]
high_table <- table(cut(high$Green_Rate, breaks = breaks_green, include.lowest = TRUE))
l_col<-c(low_table[[1]], low_table[[2]])
re_l_col<-c(re_low_table[[1]], re_low_table[[2]])
re_h_col<-c(re_high_table[[1]], re_high_table[[2]])
h_col<-c(high_table[[1]], high_table[[2]])
table<-cbind(l_col,re_l_col,re_h_col,h_col)
rownames(table)<-c("低绿化率","高绿化率")
colnames(table)<-c("低房价","较低房价","较高房价","高房价")
barplot(table,col=c("red","orange","yellow","green"),ylim=c(0,265)) #beside=TRUE
legend("top",rownames(table), cex = 0.8, fill = c("red", "orange", "yellow", "green"), horiz = TRUE)

barplot(table,col=c("red","green"),ylim=c(0,200),beside=TRUE) #beside=TRUE
legend("top",rownames(table), cex = 0.8, fill = c("red", "green"), horiz = TRUE)
###5.2.5箱线图
boxplot(WHHP$Avg_HP,horizontal = TRUE, xlab="房屋价格")

###修改样式
sum_green<-summary(WHHP$Green_Rate)
WHHP <- WHHP %>%  
  mutate(Green_level = case_when(  
    Green_Rate >= sum_green[[1]] & Green_Rate < sum_green[[2]] ~ "低",
    Green_Rate >= sum_green[[2]] & Green_Rate < sum_green[[3]] ~ "较低", 
    Green_Rate >= sum_green[[3]] & Green_Rate < sum_green[[5]] ~ "较高", 
    Green_Rate >= sum_green[[5]] & Green_Rate <= sum_green[[6]] ~ "高"
  ))
boxplot(Avg_HP~Green_level,data = WHHP,col = colors()[12:15], varwidth = TRUE, notch=TRUE, pch = 4,lwd=1.5,names=c("绿化率低","绿化率较低","绿化率较高","绿化率高"),xlab="绿化水平",ylab="平均房价")
boxplot(Avg_HP~Green_level,data = WHHP,col = colors()[c(3,8,12,15)], varwidth = TRUE, horizontal=T,notch=TRUE, pch = '*',lwd=1.5,names=c("绿化率低","绿化率较低","绿化率较高","绿化率高"),xlab="绿化水平",ylab="平均房价")
###5.3.1高维可视化
library(lattice)
###直方图
histogram(~Avg_HP| factor(Green_level), data = WHHP)

###密度图
dengraph <- densityplot(~Avg_HP|Green_level,data = WHHP)
plot(dengraph)
update(dengraph,col = "red", lwd = 2,pch="+")

###箱线图
bwplot(~Avg_HP|factor(Green_level),data=WHHP)

bwplot(~Pop_Den|factor(Green_level),data=WHHP)

###连续型变量
hp_rate<-equal.count(WHHP$Avg_HP,number=4,overlap=0)
xyplot(GDP_per_Land~ FAI_per_Land|hp_rate, data = WHHP, main = "GDP Per Land vs FAI Per Land by Average House Price", xlab = "GDP_Per_Land", ylab = "FAI_Per_Land", layout = c(4,1), aspect = 1.5)

###添加回归线
mypanel <- function(x,y){
  panel.xyplot(x,y,pch = 23)
  panel.grid(h = -1, v = -1)
  panel.lmline(x,y,col = "red", lwd = 5,lty = 2)
}
xyplot(GDP_per_Land~ FAI_per_Land|hp_rate, data = WHHP, panel=mypanel, main = "GDP Per Land vs FAI Per Land by Average House Price", xlab = "GDP_Per_Land", ylab = "FAI_Per_Land", layout = c(4,1), aspect = 1.5)

###添加拟合曲线
mypanel_1 <- function(x,y){
  panel.xyplot(x,y,pch = 23)
  panel.grid(h = -1, v = -1)
  panel.loess(x,y,lwd=2,col="darkblue")
  panel.abline(h=mean(y),lwd = 2, lty = 2, col = "darkred")
}
xyplot(GDP_per_Land~ FAI_per_Land|hp_rate, data = WHHP, panel=mypanel_1, main = "GDP Per Land vs FAI Per Land by Average House Price", xlab = "GDP_Per_Land", ylab = "FAI_Per_Land", layout = c(4,1), aspect = 1.5)

###三维
cloud(Avg_HP~GDP_per_Land*FAI_per_Land|factor(Green_level),data=WHHP,panel.aspect = 0.9)

###将多个条件变量的结果叠加到一起
densityplot(~Avg_HP, data=WHHP, group=Green_level, auto.key=TRUE,  horizontal = T)


###5.3.2散点图矩阵
WHHP_att<-st_drop_geometry(WHHP)
df<-WHHP_att[,c("Green_Rate","Annual_AQI","GDP_per_Land", "FAI_per_Land")]
pairs(df)

###修改样式
pairs(df,pch="+",col="blue",main="pch='+',col='blue'")

pairs(df,pch="*",col="red",lower.panel=NULL,main="lower.panel=NULL")


panel.cor <- function(x, y){
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r <- round(cor(x, y), digits=2)
  txt <- paste0("R = ", r)
  cex.cor <- 0.8/strwidth(txt)
  text(0.5, 0.5, txt, cex = cex.cor * r)
}
upper.panel<-function(x, y){
  points(x,y, pch = 19, col = "red")
}
pairs(df, 
      lower.panel = panel.cor,
      upper.panel = upper.panel)

###GGally包绘制
library(GGally)
ggpairs(df)

###psych包绘制
library(psych)
pairs.panels(df, 
             method = "pearson",
             hist.col = "#00AFBB",
             density = TRUE,
             ellipses = TRUE
)


###5.3.3热图
library(ComplexHeatmap)
WHHP_att<-st_drop_geometry(WHHP)[1:15,]
selected_columns <- c("Annual_AQI", "GDP_per_Land","Avg_HP", "Pop_Den")
WHHP_att<-WHHP_att[,selected_columns]
numeric_data <- as.data.frame(lapply(WHHP_att, as.numeric))
data <- t(as.matrix(numeric_data))
colnames(data) = paste("Zone", 1:15, sep = "")
exp <- apply(data, 1, scale)
rownames(exp) <- colnames(data)
exp <- t(exp)
Heatmap(exp)

###修改样式
library(circlize)
col_fun <- colorRamp2(
  c(-2, 0, 2), 
  c("#8c510a", "white", "#01665e")
)
Heatmap(exp, col = col_fun, 
        border = "black",
        rect_gp = gpar(col = "white", lwd = 1),
        
        column_title = "Zone Sample",
        column_title_side = "bottom",
        column_title_rot = 0,
        column_title_gp = gpar(
          col = "white",
          fontsize = 18,
          fontface = "italic",
          fill = "#01665e",
          border = "black"),
        row_title = "Zone Attribute",
        row_title_side = "left",
        row_title_gp = gpar(
          col = "white",
          fontsize = 18,
          fontface = "italic",
          fill = "#01665e",
          border = "black"),
        column_names_rot = 45)

###修改行列的聚类方式
Heatmap(
  exp, 
  col = col_fun,
  column_names_rot = 45,
  clustering_distance_columns = "spearman",
  clustering_method_rows = "single"
)

###分割热图
hm<-Heatmap(
  exp, 
  col = col_fun,
  column_km_repeats = 100,
  row_km_repeats = 100,
  column_km = 3,
  row_km = 2,
  row_title = "att_cluster_%s",
  column_title = "zone_cluster_%s",
  row_gap = unit(2, "mm"),
  column_gap = unit(c(2, 4), "mm"),
  column_names_rot = 45
)
draw(hm,row_title="Zone Attribute")

###5.3.3.2 添加注释
###简单注释
gre_level_num <- case_when(
  st_drop_geometry(WHHP)[1:15,"Green_level"] == "高" ~ 4,
  st_drop_geometry(WHHP)[1:15,"Green_level"] == "较高" ~ 3,
  st_drop_geometry(WHHP)[1:15,"Green_level"] == "较低" ~ 2,
  st_drop_geometry(WHHP)[1:15,"Green_level"] == "低" ~ 1
)

level<-columnAnnotation(
  Green_Level=gre_level_num,
  col=list(
    Green_Level = c("4" = "pink", "3" = "lightblue", "2" = "orange", "1" = "lightcyan")
  )
)
Heatmap(exp,col = col_fun,
        name = "mat",
        top_annotation = level)

###分块注释
Heatmap(
  exp, name = "mat",col = col_fun,
  top_annotation = columnAnnotation(
    anb = anno_block(
      gp = gpar(fill = 3:5),
      labels = c("group1", "group2", "group3"),
      labels_gp = gpar(col = "white", fontsize = 10))
  ),
  column_km = 3,
  left_annotation = rowAnnotation(
    anb1 = anno_block(
      gp = gpar(fill = 3:4),
      labels = c("group1", "group2"),
      labels_gp = gpar(col = "white", fontsize = 10)
    )
  ),
  row_km = 2,
  column_names_rot = 45
)

###条形图注释和线注释
Heatmap(
  exp[1:3,],
  col = col_fun,
  column_names_rot = 45,
  top_annotation = HeatmapAnnotation(
    FAI_bar=anno_barplot(
      st_drop_geometry(WHHP)[1:15,"FAI_per_Land"],
      bar_width = 0.8,
      gp = gpar(
        fill = colorRampPalette(c("#8c510a", "#01665e"))(15)
      ),
      height = unit(2, "cm")
    ),
    FAI_line=anno_lines(
      st_drop_geometry(WHHP)[1:15,"FAI_per_Land"],#data["FAI_per_Land",],
      gp = gpar(col = "#8c510a"),
      add_points = TRUE,
      pt_gp = gpar(col = "#01665e"),
      pch = 1,
      smooth = TRUE,
      height = unit(1.5,"cm")
    ),
    gap = unit(2, "mm")
  )
)

###5.3.3.3 连接多个热图和注释
WHHP_att<-st_drop_geometry(WHHP)[1:15,]

columns_1 <- c("Pop", "Pop_Den")
att_1<-WHHP_att[,columns_1]
data_1 <- as.data.frame(lapply(att_1, as.numeric))
data_1 <- t(as.matrix(data_1))
colnames(data_1) = paste("Zone", 1:15, sep = "")

columns_2 <- c("Annual_AQI", "Green_Rate", "Den_POI")
att_2<-WHHP_att[,columns_2]
data_2 <- as.data.frame(lapply(att_2, as.numeric))
data_2 <- t(as.matrix(data_2))
colnames(data_2) = paste("Zone", 1:15, sep = "")

columns_3 <- c("GDP_per_Land", "Rev_per_Land", "TertI_Rate")
att_3<-WHHP_att[,columns_3]
data_3 <- as.data.frame(lapply(att_3, as.numeric))
data_3 <- t(as.matrix(data_3))
colnames(data_3) = paste("Zone", 1:15, sep = "")

exp_1 <- apply(data_1, 1, scale)
rownames(exp_1) <- colnames(data_1)

exp_2 <- apply(data_2, 1, scale)
rownames(exp_2) <- colnames(data_2)

exp_3 <- apply(data_3, 1, scale)
rownames(exp_3) <- colnames(data_3)

col_fun_1 <- colorRamp2(c(-2,0,2), c("#f46d43", "#ffffbf", "#3288bd"))
col_fun_2 <- colorRamp2(c(-2,0,2), c("#f7f7f7","#de77ae", "#7fbc41"))
col_fun_3 <- colorRamp2(c(-2,0,2), c("pink","lightyellow","lightblue"))

ht_pop <- Heatmap(
  exp_1,
  name = "Pop",
  column_names_rot = 45,
  col = col_fun_1,
  show_column_names = TRUE,
  show_row_names = TRUE,
  cluster_rows = TRUE,
  cluster_columns = TRUE,
  rect_gp = gpar(col = "#f7f7f7", lwd = 1),
  column_title = "Heatmap 1",
  width = unit(5, "cm"))

ht_env <- Heatmap(
  exp_2,
  name = "Environment",
  column_names_rot = 45,
  col = col_fun_2,
  show_column_names = TRUE,
  show_row_names = TRUE,
  cluster_rows = TRUE,
  cluster_columns = TRUE,
  rect_gp = gpar(col = "#f7f7f7", lwd = 1),
  column_title = "Heatmap 2",
  width = unit(5, "cm")
)

ht_eco <- Heatmap(
  exp_3[,1:3],
  name = "Economy",
  column_names_rot = 45,
  col = col_fun_3,
  show_column_names = TRUE,
  show_row_names = TRUE,
  cluster_rows = TRUE,
  cluster_columns = TRUE,
  rect_gp = gpar(col = "#f7f7f7", lwd = 1),
  column_title = "Heatmap 3",
  width = unit(5, "cm"),
  right_annotation = rowAnnotation(
    Avg_HP_point = anno_points(st_drop_geometry(WHHP)[1:15,"Avg_HP"],
                               pch = 2,
                               gp = gpar(col = "#de77ae"))))

draw(ht_pop+ht_env+ht_eco)


###5.3.4相关热图及组合图
library(corrplot)
selected_columns <- c("Green_Rate", "GDP_per_Land", "Rev_per_Land", "FAI_per_Land","TertI_Rate","Avg_HP")
WHHP_att<-WHHP_att[,selected_columns]
numeric_data <- as.data.frame(lapply(WHHP_att, as.numeric))
data <- as.matrix(numeric_data)

cor_data <- cor(data)
corrplot(cor_data,method = "square")

###修改样式
corrplot(cor_data, order = 'hclust', addrect=2, addCoef.col = 'black', tl.pos = 'd', cl.pos = 'r', col = COL2('PiYG'))

###corrplot.mixed函数 混合绘制
corrplot.mixed(cor_data, order = 'AOE')
corrplot.mixed(cor_data, lower = 'shade', upper = 'pie', order = 'hclust')

###两个矩阵之间的相关性
library(linkET)
library(RColorBrewer)
library(dplyr)
library(ggplot2)

WHHP_att<-st_drop_geometry(WHHP)
selected_columns1 <- c("GDP_per_Land", "Rev_per_Land", "Avg_HP")
WHHP_att<-WHHP_att[1:100,selected_columns1]
numeric_data <- as.data.frame(lapply(WHHP_att, as.numeric))
data_env <- as.matrix(numeric_data)

WHHP_att<-st_drop_geometry(WHHP)
selected_columns2 <- c("Pop", "Pop_Den",
                       "Annual_AQI","Green_Rate","Den_POI",
                       "FAI_per_Land","TertI_Rate")
WHHP_att<-WHHP_att[1:100,selected_columns2]
numeric_data <- as.data.frame(lapply(WHHP_att, as.numeric))
data_spec <- as.matrix(numeric_data)

data_env[data_env == 0] <- 0.0001
data_spec[data_spec == 0] <- 0.0001

mantel <- mantel_test(data_spec, data_env,
                      spec_select = list(POP = 1:2,
                                         ENVIRONMENT = 3:5,
                                         ECONOMY = 6:7)) %>% 
  mutate(rd = cut(r, breaks = c(-Inf, 0.2, 0.4, Inf),
                  labels = c("< 0.2", "0.2 - 0.4", ">= 0.4")),
         pd = cut(p, breaks = c(-Inf, 0.01, 0.05, Inf),
                  labels = c("< 0.01", "0.01 - 0.05", ">= 0.05")))

qcorrplot(data_env,
          type = "lower", 
          diag = FALSE,
          is_corr = FALSE) + 
  geom_square() +
  geom_couple(data = mantel, 
              aes(colour = pd, 
                  size = rd), 
              curvature = nice_curvature()) +  
  scale_fill_gradientn(colours =brewer.pal(11, "RdYlGn")) + 
  scale_size_manual(values = c(0.5, 1, 2)) + 
  scale_colour_manual(values =c('#7AA15E','#B7B663','#CFCECC')) + 
  guides(size = guide_legend(title = "Mantel's r",  
                             override.aes = list(colour = "grey35"), 
                             order = 2),
         colour = guide_legend(title = "Mantel's p", 
                               override.aes = list(size = 3), 
                               order = 1),
         fill = guide_colorbar(title = "Pearson's r", order = 3))


###5.3.5平行坐标图
library(MASS)
data<-st_drop_geometry(WHHP)[,c("GDP_per_Land","Rev_per_Land", "FAI_per_Land", "TertI_Rate")]
parcoord(data)

#修改颜色
WHHP <- WHHP %>%  
  mutate(HP_level_num = case_when(
    HP_level == "低" ~ 1, 
    HP_level == "较低" ~ 2, 
    HP_level == "较高"~ 3,
    HP_level == "高" ~ 4
  ))
data <- st_drop_geometry(WHHP)[,c("GDP_per_Land", "Rev_per_Land", "FAI_per_Land", "TertI_Rate", "HP_level_num")]
cols<-c("#3288bd","#7fbc41","#ffffbf","#f46d43")
colors <- cols[data$HP_level_num]
parcoord(data, col = colors)
legend("top",title="房价水平",legend = c("低","较低","较高","高"), fill = cols,box.lwd=0,horiz=T,inset=c(0,-0.06),box.col="white")

#GGally包绘制
library(GGally)
ggparcoord(data, 
           columns = 1:4, 
           groupColumn = 5)


ggparcoord(data, 
           columns = 1:4, 
           groupColumn = 5,scale='uniminmax', showPoints =T)          


###5.4绘制冰墩墩
getEllipse <- function(Mu,Sigma,S,pntNum)
{
  invSig <- solve(Sigma)
  eigen_vec <- eigen(invSig)
  D <- eigen_vec$values
  V <- eigen_vec$vectors
  aa <- sqrt(S/D[1])
  bb <- sqrt(S/D[2])
  t <- seq(0, 2*pi, length.out = pntNum)
  ab.theta <- rbind(aa*cos(t), bb*sin(t))
  xy <- V%*%ab.theta
  x <- xy[1,]+Mu[1]
  y <- xy[2,]+Mu[2]
  res <- cbind(x,y)
}

library(sp)
t1 <- seq(-2.9, 0, length.out = 500)
t2 <- seq(0, 2.9, length.out = 500)

t <- seq(-2.9, 2.9, length.out = 1000)
x <- (16*sin(t))^3
y <- 13*cos(t)-5*cos(2*t)-2*cos(3*t)-cos(4*t)

plot(x, y,typ="l",col="white")
polygon(x,y,col=rgb(180/255,39/255,45/255),border=rgb(180/255,39/255,45/255),lwd=2)

ax.XLim=c(-5, 5)
ax.YLim=c(-5, 5)

png("icedundun.png", res=300, width=24, height=24, unit="cm")
#绘制内容
dev.off()


######冰糖外壳
bt.ex <- getEllipse(c(0,0), diag(c(1,1.3)), 3.17^2, 200)
plot(bt.ex,typ="l", col=rgb(57/255,57/255,57/255), lwd=1.8,xlim=ax.XLim, ylim=ax.YLim)

bt.ex1 <- getEllipse(c(1.7,2.6), diag(c(1.2,1.8)), 0.65^2, 200)
lines(bt.ex1, col=rgb(57/255,57/255,57/255), lwd=1.8)
lines(cbind(-bt.ex1[,1],bt.ex1[,2]), col=rgb(57/255,57/255,57/255), lwd=1.8)

bt.ex2 <- getEllipse(c(1.7,2.6), diag(c(1.2,1.8)), 0.6^2, 200)
polygon(bt.ex2[,1], bt.ex2[,2], col=rgb(1,1,1), border = rgb(1,1,1),lwd=1.8)
polygon(-bt.ex2[,1], bt.ex2[,2], col=rgb(1,1,1), border = rgb(1,1,1),lwd=1.8)

bt.ex3 <- getEllipse(c(-3.5,-1), matrix(c(1.1,.3,.3,1.1),ncol=2), .75^2, 200)
lines(bt.ex3, col=rgb(57/255,57/255,57/255), lwd=1.8)
bt.ex4 <- getEllipse(c(-3.5,-1), matrix(c(1.1,.3,.3,1.1),ncol=2), .68^2, 200)
polygon(bt.ex4[,1], bt.ex4[,2], col=rgb(1,1,1), border = rgb(1,1,1),lwd=1.8)

bt.ex5 <- getEllipse(c(3.5,1), matrix(c(1.1,.3,.3,1.1),ncol=2), .75^2, 200)
lines(bt.ex5, col=rgb(57/255,57/255,57/255), lwd=1.8)
bt.ex6 <- getEllipse(c(3.5,1), matrix(c(1.1,.3,.3,1.1),ncol=2), .68^2, 200)
polygon(bt.ex6[,1], bt.ex6[,2], col=rgb(1,1,1), border = rgb(1,1,1),lwd=1.8)

x2 <- c(-3.8,-2,-3)
y2 <- c(-.51+.13,1+.13,-1)
lines(x2, y2, col=rgb(57/255,57/255,57/255), lwd=1.8)
lines(-x2, -y2, col=rgb(57/255,57/255,57/255), lwd=1.8)

x3 <- c(-3.8,-2,-3)
y3 <- c(-.51+.03,1+.03,-1)
polygon(x3, y3, col=rgb(1,1,1), border = rgb(1,1,1),lwd=1.8)
polygon(-x3, -y3, col=rgb(1,1,1), border = rgb(1,1,1),lwd=1.8)

bt.ex7 <- getEllipse(c(0,-0.1), diag(c(1,1.6)), .9^2, 200)
x4 <- bt.ex7[,1] -1.2
y4 <- bt.ex7[,2]
y4[which(y4<0)] <- y4[which(y4<0)]*0.2
y4 <- y4-4.2
lines(x4, y4, col=rgb(57/255,57/255,57/255), lwd=2)
lines(-x4, y4, col=rgb(57/255,57/255,57/255), lwd=2)

bt.ex8 <- getEllipse(c(0,-0.1), diag(c(1,1.6)), .8^2, 200)
x5 <- bt.ex8[,1] -1.2
y5 <- bt.ex8[,2]
y5[which(y5<0)] <- y5[which(y5<0)]*0.2
y5 <- y5-4.1
polygon(x5, y5, col=rgb(1,1,1), border = rgb(1,1,1),lwd=1.8)
polygon(-x5, y5, col=rgb(1,1,1), border = rgb(1,1,1),lwd=1.8)

bt.ex9 <- getEllipse(c(0,0), diag(c(1,1.3)), 3.1^2, 200)
polygon(bt.ex9[,1], bt.ex9[,2], col=rgb(1,1,1), border = rgb(1,1,1),lwd=1.8)

######耳朵 胳膊 腿
be.ex1 <- getEllipse(c(1.7,2.6), diag(c(1.2,1.8)), .5^2, 200)
polygon(be.ex1[,1], be.ex1[,2], col=rgb(57/255,57/255,57/255), border = rgb(57/255,57/255,57/255),lwd=2)
polygon(-be.ex1[,1], be.ex1[,2], col=rgb(57/255,57/255,57/255), border = rgb(57/255,57/255,57/255),lwd=2)

ba.ex1 <- getEllipse(c(-3.5,-1), matrix(c(1.1,.3,.3,1.1),ncol=2), .6^2, 200)
polygon(ba.ex1[,1], ba.ex1[,2], col=rgb(57/255,57/255,57/255), border = rgb(57/255,57/255,57/255),lwd=2)
ba.ex2 <- getEllipse(c(3.5,1), matrix(c(1.1,.3,.3,1.1),ncol=2), .6^2, 200)
polygon(ba.ex2[,1], ba.ex2[,2], col=rgb(57/255,57/255,57/255), border = rgb(57/255,57/255,57/255),lwd=2)

x6 <- c(-3.8, -2, -3)
y6 <- c(-0.51, 1, -1)
polygon(x6, y6, col=rgb(57/255,57/255,57/255), border = rgb(57/255,57/255,57/255))
polygon(-x6, -y6, col=rgb(57/255,57/255,57/255), border = rgb(57/255,57/255,57/255))
tt <- seq(-2.9, 2.9, length.out = 1000)
x <- 16*(sin(tt))^3
y <- 13*cos(tt)-5*cos(2*tt)-2*cos(3*tt)-cos(4*tt)
x7 <- x*0.018+3.6
y7 <- y*0.018+1.1
polygon(x7, y7, col=rgb(180/255,39/255,45/255), border = rgb(180/255,39/255,45/255))

bl.ex <- getEllipse(c(0,-0.1), diag(c(1,1.6)), .7^2, 200)
x8 <- bl.ex[,1] -1.2
y8 <- bl.ex[,2]
y8[which(y8<0)] <- y8[which(y8<0)]*0.2
y8 <- y8-4.1
polygon(x8, y8, col=rgb(57/255,57/255,57/255), border = rgb(57/255,57/255,57/255),lwd=2)
polygon(-x8, y8, col=rgb(57/255,57/255,57/255), border = rgb(57/255,57/255,57/255),lwd=2)

######身体
bd.ex <- getEllipse(c(0,0), diag(c(1,1.3)), 3^2, 200)
polygon(bd.ex[,1], bd.ex[,2], col=rgb(1,1,1), border = rgb(57/255,57/255,57/255),lwd=2.5)

######脸上的彩色圆环
clist <- matrix(c(132,199,114,251,184,77,89,120,177,158,48,87,98,205, 247), ncol=3)
for(i in 1:5){
  bw.ex <- getEllipse(c(0,0), diag(c(1.6,1.3)), (2.05-0.05*i)^2, 200)
  y9 <- bw.ex[,2]
  y9[which(y9<0)] <- y9[which(y9<0)]*0.8
  y9 <- y9+0.5
  polygon(bw.ex[,1], y9, col=rgb(1,1,1), border = rgb(clist[i,1]/255, clist[i,2]/255, clist[i,3]/255),lwd=2.5)
}

######眼睛
beye.ex <- getEllipse(c(1.2,1.2),  matrix(c(1.2,-.5,-.5,1.1),ncol=2), 0.65^2, 200)
polygon(beye.ex[,1], beye.ex[,2], col=rgb(57/255,57/255,57/255), border = rgb(57/255,57/255,57/255),lwd=2)
polygon(-beye.ex[,1], beye.ex[,2], col=rgb(57/255,57/255,57/255), border = rgb(57/255,57/255,57/255),lwd=2)

beye.ex1 <- getEllipse(c(.95,1.3), diag(c(1,1)), .35^2, 200)
polygon(beye.ex1[,1], beye.ex1[,2], col=rgb(57/255,57/255,57/255), border = rgb(1,1,1),lwd=1.6)
polygon(-beye.ex1[,1], beye.ex1[,2], col=rgb(57/255,57/255,57/255), border = rgb(1,1,1),lwd=1.6)
beye.ex2 <- getEllipse(c(.95,1.3), diag(c(1,1)), .1^2, 200)
polygon(beye.ex2[,1]+0.18, beye.ex2[,2], col=rgb(1,1,1), border = rgb(57/255,57/255,57/255),lwd=.5)
polygon(-beye.ex2[,1]+.18, beye.ex2[,2], col=rgb(1,1,1), border = rgb(57/255,57/255,57/255),lwd=.5)

######嘴巴
bm.ex <- getEllipse(c(.05,.2),  matrix(c(1.2,.15,.15,.8),ncol=2), 0.69^2, 200)
polygon(bm.ex[,1], bm.ex[,2], col=rgb(57/255,57/255,57/255), border = rgb(57/255,57/255,57/255),lwd=2)
bm.ex1 <- getEllipse(c(0,.75),  matrix(c(1,0.2,0.2,.3),ncol=2), 0.4^2, 200)
polygon(bm.ex1[,1], bm.ex1[,2], col=rgb(1,1,1), border = rgb(1,1,1),lwd=2)
bm.ex2 <- getEllipse(c(0,0), diag(c(.8,.2)), .6^2, 200)
polygon(bm.ex2[,1], bm.ex2[,2], col=rgb(180/255,39/255,45/255), border = rgb(180/255,39/255,45/255),lwd=2)

######鼻子
bn.ex1 <- getEllipse(c(0,-.1), diag(c(1,1.6)), .2^2, 200)
y10 <- bn.ex1[,2]
y10[which(y10<0)] <- y10[which(y10<0)]*0.2
y10 <- -y10+.9
polygon(bn.ex1[,1], y10, col=rgb(57/255,57/255,57/255), border = rgb(57/255,57/255,57/255),lwd=2)

######冬奥会标志 五环
tt <- seq(0, 2*pi, length.out = 100)
X<- cos(tt)*.14;
Y<- sin(tt)*.14;
lines(X,Y-2.8,col=rgb(57/255,57/255,57/255),lwd=1.2)
lines(X-.3,Y-2.8,col=rgb(106/255,201/255,245/255),lwd=1.2)
lines(X+.3,Y-2.8,col=rgb(155/255,79/255,87/255),lwd=1.2)
lines(X-.15,Y-2.9,col=rgb(236/255,197/255,107/255),lwd=1.2)
lines(X+.15,Y-2.9,col=rgb(126/255,159/255,101/255),lwd=1.2)

text(0,-2.4,"BEIJING 2022")

polygon(c(.1,-.12,-.08), c(0,0-0.05,-0.15)-1.5, col=rgb(98/255,118/255,163/255), border=rgb(98/255,118/255,163/255))
polygon(c(-.08,-.35,.1), c(-0.1,-.2,-.1)-1.6, col=rgb(98/255,118/255,163/255), border=rgb(98/255,118/255,163/255))
polygon(c(-.08,-.08,.1,.1), c(-0.1,-0.15,-.2,-.15)-1.5, col=rgb(192/255,15/255,45/255), border=rgb(192/255,15/255,45/255))
lines(c(-.35,-.3,-.25,-.2,-.15,-.1,-.05,.1)+.02,c(0,.02,.04,.06,.04,.02,0,.02)-1.82,col=rgb(120/255,196/255,219/255),lwd=1.8)
lines(c(-.33,.05)+.02, c(0,-.08)-1.82, col=rgb(190/255,215/255,84/255), lwd=1.8)
lines(c(.05,-.2)+.02, c(-.08,-.15)-1.82, col=rgb(32/255,162/255,218/255), lwd=1.8)
lines(c(-.2,.05)+.02, c(-.15,-.2)-1.82, col=rgb(99/255,118/255,151/255), lwd=1.8)
