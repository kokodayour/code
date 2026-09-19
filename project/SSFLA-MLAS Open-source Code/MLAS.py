from osgeo import gdal, gdal_array, gdalnumeric, ogr, osr
# from PIL import Image, ImageDraw
# import matplotlib.pyplot as plt
import numpy as np
import operator
import math
import os
import random
import sys
import time
import argparse
import copy
from Parser import opt
from scipy.ndimage import *
from scipy import signal
import pandas as pd


class myInfoFile:
    def myOpenInfoFile(self, filename):
        f = open(filename, 'w+')
        return f

    def myWriteInfoFile(self, f, info):
        # f.write('Hello, python!')
        f.writelines(info)

    def myReadInfoFile(self, f):
        return f.readlines()

    def myCloseInfoFile(self, f):
        f.close()

class myTIF:
    def __init__(self, gain=2.0000E-05, offset=-0.1):
        '''
        landsat 8
        '''
        self.gain = gain
        self.offset = offset

    def read_img_dataset(self, filename):
        dataset = gdal.Open(filename)
        return dataset

    def read_img_array(self, filename):
        dataset = self.read_img_dataset(filename)
        return dataset.ReadAsArray()

    # This function will convert the rasterized clipper shapefile
    # to a mask for use within GDAL.
    def imageToArray(self, i):
        """
        Converts a Python Imaging Library array to a
        gdalnumeric image.
        """
        a = gdalnumeric.frombuffer(i.tobytes(), 'b')
        a.shape = i.im.size[1], i.im.size[0]
        return a

    def world2Pixel(self, geoMatrix, x, y):
        """
        Uses a gdal geomatrix (gdal.GetGeoTransform()) to calculate
        the pixel location of a geospatial coordinate
        """
        ulX = geoMatrix[0]
        ulY = geoMatrix[3]
        xDist = geoMatrix[1]
        pixel = int((x - ulX) / xDist)
        line = int((ulY - y) / xDist)
        return (pixel, line)

    # #
    # #  EDIT: this is basically an overloaded
    # #  version of the gdal_array.OpenArray passing in xoff, yoff explicitly
    # #  so we can pass these params off to CopyDatasetInfo
    # #
    def OpenArray(self, array, prototype_ds=None, xoff=0, yoff=0):
        ds = gdal_array.OpenArray(array)
        if ds is not None and prototype_ds is not None:
            if type(prototype_ds).__name__ == 'str':
                prototype_ds = gdal.Open(prototype_ds)
            if prototype_ds is not None:
                gdalnumeric.CopyDatasetInfo(prototype_ds, ds, xoff=xoff, yoff=yoff)
        return ds

    def get_proj_info(self, dataset):
        '''
        projection information
        '''
        im_width = dataset.RasterXSize
        im_height = dataset.RasterYSize
        im_geotrans = dataset.GetGeoTransform()
        im_proj = dataset.GetProjection()
        im_bands = dataset.RasterCount
        return im_proj, im_geotrans, im_bands, im_width, im_height

    def write_img(self, filename, im_proj, im_geotrans, im_data, NODATA):
        '''
        save image
        '''
        list1 = ["byte", "uint8", "uint16", "int16", "uint32", "int32", "float32", "float64", "cint16", "cint32",
                 "cfloat32", "cfloat64"]
        list2 = [gdal.GDT_Byte, gdal.GDT_Byte, gdal.GDT_UInt16, gdal.GDT_Int16, gdal.GDT_UInt32, gdal.GDT_Int32,
                 gdal.GDT_Float32, gdal.GDT_Float64, gdal.GDT_CInt16, gdal.GDT_CInt32, gdal.GDT_CFloat32,
                 gdal.GDT_CFloat64]
        datatype = gdal.GDT_Float32
        if len(im_data.shape) == 3:
            im_bands, im_height, im_width = im_data.shape
        else:
            im_bands, (im_height, im_width) = 1, im_data.shape
        driver = gdal.GetDriverByName("GTiff")
        dataset = driver.Create(filename, im_width, im_height, im_bands, datatype)
        dataset.SetGeoTransform(im_geotrans)
        dataset.SetProjection(im_proj)
        if im_bands == 1:
            dataset.GetRasterBand(1).SetNoDataValue(NODATA)
            dataset.GetRasterBand(1).WriteArray(im_data)
        else:
            for i in range(im_bands):
                dataset.GetRasterBand(1).SetNoDataValue(NODATA)
                dataset.GetRasterBand(i + 1).WriteArray(im_data[i])

        del dataset


class Agent_Optimization:
    def __init__(self):
        self.myRSImg = myTIF()

        self.LUCCMap = self.read_img_asArray(os.path.join(opt.inputFolderPath, opt.LUCCName),
                                             ArrayType=int)
        self.LUCCAvailable = np.array((self.LUCCMap < 15), np.int32)
        self.LUCCArray = opt.LUCCArray
        self.LUCCTotalArray = opt.LUCCTotalArray
        self.ForbiddenLUCCArray = opt.ForbiddenLUCCArray
        self.row, self.column = self.LUCCMap.shape
        self.LUCCShape = self.LUCCMap.shape

        self.inputFolderPath = opt.inputFolderPath
        self.outputFolderPath = opt.outputFolderPath
        self.InterResultsFolderPath = opt.InterResultsFolderPath

        self.dataset = self.myRSImg.read_img_dataset(os.path.join(opt.inputFolderPath, opt.LUCCName))
        self.proj, self.geotrans, self.bands, self.width, self.height = self.myRSImg.get_proj_info(self.dataset)

        self.discountFactor = opt.discountFactor

        self.windowNumMap = self.windowNumMap_Cal(opt.windowSize)

    def read_img_asArray(self, imgPath, ArrayType=float):
        dataset = self.myRSImg.read_img_dataset(imgPath)
        Array = dataset.GetRasterBand(1).ReadAsArray().astype(ArrayType)
        del dataset
        return Array

    def MontoCarlo_cal(self, Probability):
        r = random.random()
        if Probability >= r:
            return True
        else:
            return False

    def MontoCarlo_Arraycal(self, ProbabilityMaxArray):
        random_array = np.random.rand(self.row, self.column)
        Result = (ProbabilityMaxArray >= random_array)
        del random_array
        return Result

    def Roulette_cal(self, ProbabilityArray):
        r = random.random()
        Probability = 0
        for i in range(len(ProbabilityArray)):
            Probability += ProbabilityArray[i]
            if r <= Probability:
                return i

    def Roulette_Arraycal(self, ScoreArray_3D, LUCCMap, MutiDecision_bool):
        ScoreSumArray_3D = np.sum(ScoreArray_3D, axis=0)
        ScoreSumArray_3D[ScoreSumArray_3D == 0] = 1

        randomMap = np.random.rand(self.LUCCShape[0], self.LUCCShape[1])
        ProbabilityMap = np.zeros((self.LUCCShape), float)
        Roulette_ResultMap = np.full((self.LUCCShape), 15, dtype=int)
        UnDecisionMap_bool = MutiDecision_bool.copy()

        ProbabilityArray_3D = []
        for i in range(len(self.LUCCArray)):
            ProbabilityMap = ProbabilityMap + (ScoreArray_3D[i] / ScoreSumArray_3D)
            ProbabilityArray_3D.append(ProbabilityMap)
            ChosenMap_Array = UnDecisionMap_bool & (ProbabilityMap >= randomMap)
            Roulette_ResultMap[ChosenMap_Array] = self.LUCCArray[i]
            UnDecisionMap_bool[ChosenMap_Array] = False

        Roulette_ResultMap = np.where(UnDecisionMap_bool, LUCCMap, Roulette_ResultMap)
        return Roulette_ResultMap

    # 生成数量矩阵和拓扑矩阵组
    def built_Window(self, windowSize: int):

        if windowSize < 1:
            raise ("error")
        windowLength = 2 * windowSize + 1
        quantityMatrix = np.ones((windowLength, windowLength), int)
        quantityMatrix[windowSize, windowSize] = 0

        topologicalMatrixArray = []
        for i in range(windowSize):
            topologicalMatrix = np.zeros((windowLength, windowLength), int)
            for x in range(i, windowLength - i):
                for y in range(i, windowLength - i):
                    if y == i or y == windowLength - 1 - i or x == i or x == windowLength - 1 - i:
                        topologicalMatrix[x, y] = 1
            topologicalMatrixArray.append(topologicalMatrix)
        del topologicalMatrix, windowLength
        return quantityMatrix, topologicalMatrixArray

    def Underlay_Into_Window(self, BaseMap, windowSize: int):

        if windowSize < 1:
            raise ("error")
        windowLength = 2 * windowSize + 1
        row, column = BaseMap.shape
        blankLine = np.zeros((windowSize, row))
        blankColumn = np.zeros((windowSize, column + 2 * windowSize))
        UnderlayMap = np.insert(np.insert(BaseMap, column, values=blankLine, axis=1), 0, values=blankLine, axis=1)
        UnderlayMap = np.insert(np.insert(UnderlayMap, row, values=blankColumn, axis=0), 0, values=blankColumn, axis=0)
        del blankLine, blankColumn
        return UnderlayMap

    # 计算数量环境分
    def QuantityEnv_cal_PUB(self, LandUse_Map, quantityMatrix):
        QuantityEnv = signal.convolve2d(LandUse_Map, quantityMatrix, mode='same')
        windowNumMapTemper = copy.deepcopy(self.windowNumMap)
        QuantityEnv = QuantityEnv / windowNumMapTemper
        del windowNumMapTemper
        return QuantityEnv

    def windowNumMap_Cal(self, windowSize: int):

        if windowSize < 1:
            raise ("error")
        windowLength = 2 * windowSize + 1
        windowTemper = np.ones((windowLength, windowLength))
        windowNumMap = signal.convolve2d(self.LUCCAvailable, windowTemper, mode='same')
        for x in range(self.row):
            for y in range(self.column):
                if self.LUCCAvailable[x][y] == 0:
                    windowNumMap[x][y] = 1
                else:
                    windowNumMap[x][y] -= 1
        return windowNumMap

    def OutputImage(self, OutputMap, OutputPath):
        self.myRSImg.write_img(OutputPath, self.proj, self.geotrans, OutputMap, 15)


class Fitness_Cal(Agent_Optimization):
    def __init__(self):
        super(Fitness_Cal, self).__init__()
        self.BenefitNormalizationScale = opt.BenefitNormalizationScale
        self.Weight_ObjectiveFunction_GOV = opt.Weight_ObjectiveFunction_GOV
        self.economyBenefitArray = opt.economyBenefitArray
        self.ecologyBenefitArray = opt.ecologyBenefitArray
        self.carbonBenefitArray = opt.carbonBenefitArray
        self.totalNum = 0
        self.ExpectedBenefitMapArray = self.ExpectedBenefit_cal_PUB()

    def Benefit_Cal_Economy(self, NumArray):
        economyBenefit = 0
        for i in range(len(self.LUCCTotalArray)):
            economyBenefit += NumArray[i] * self.economyBenefitArray[i]
        economyBenefit = economyBenefit * self.BenefitNormalizationScale / (
                self.totalNum * np.mean(self.economyBenefitArray))
        return economyBenefit

    def Benefit_Cal_Ecology(self, NumArray):
        ecologyBenefit = 0
        for i in range(len(self.LUCCTotalArray)):
            ecologyBenefit += NumArray[i] * self.ecologyBenefitArray[i]
        ecologyBenefit = ecologyBenefit * self.BenefitNormalizationScale / (
                self.totalNum * np.mean(self.ecologyBenefitArray))
        return ecologyBenefit

    def Benefit_Cal_Carbon(self, NumArray):
        carbonBenefit = 0
        for i in range(len(self.LUCCTotalArray)):
            carbonBenefit += NumArray[i] * self.carbonBenefitArray[i]
        carbonBenefit = carbonBenefit * self.BenefitNormalizationScale / (
                self.totalNum * np.mean(self.carbonBenefitArray))
        return carbonBenefit

    def Spatial_Benefit_Cal(self, DecisionMakingMap_GOV):
        quantityMatrix, topologicalMatrixArray = self.built_Window(1)
        QuantityEnvTotal = np.zeros((DecisionMakingMap_GOV.shape), int)
        LandUse_availableTotal = np.zeros((DecisionMakingMap_GOV.shape), int)
        for i in self.LUCCArray:
            LandUse_available_LUCC = (DecisionMakingMap_GOV == i)
            QuantityEnv = self.QuantityEnv_cal_PUB(LandUse_available_LUCC, quantityMatrix)
            QuantityEnv[~LandUse_available_LUCC] = 0
            QuantityEnvTotal = QuantityEnvTotal + QuantityEnv
            LandUse_availableTotal = LandUse_availableTotal + LandUse_available_LUCC
        QuantityBenefit = np.sum(QuantityEnvTotal) * self.BenefitNormalizationScale / np.sum(LandUse_availableTotal)

        return QuantityBenefit

    def ObjectiveFunction_cal_GOV(self, DecisionMakingMap_GOV):
        ObjectiveFunction_GOV = 0
        NumArray = []
        self.totalNum = 0
        for i in range(len(self.LUCCTotalArray)):
            num = np.sum(DecisionMakingMap_GOV == self.LUCCTotalArray[i])
            NumArray.append(num)
            self.totalNum += num

        economyBenefit = self.Benefit_Cal_Economy(NumArray)
        ecologyBenefit = self.Benefit_Cal_Ecology(NumArray)
        carbonBenefit = self.Benefit_Cal_Carbon(NumArray)
        SpatialBenefit = self.Spatial_Benefit_Cal(DecisionMakingMap_GOV)
        try:
            ObjectiveFunction_GOV = economyBenefit * self.Weight_ObjectiveFunction_GOV[0] + \
                                    ecologyBenefit * self.Weight_ObjectiveFunction_GOV[1] + \
                                    carbonBenefit * self.Weight_ObjectiveFunction_GOV[3] + \
                                    SpatialBenefit * self.Weight_ObjectiveFunction_GOV[4]
        except:
            print("error")

        return ObjectiveFunction_GOV, economyBenefit, ecologyBenefit, carbonBenefit, SpatialBenefit

    def Num_Cal(self, DecisionMakingMap_GOV):
        NumArray = []
        for i in range(len(self.LUCCTotalArray)):
            num = np.sum(DecisionMakingMap_GOV == self.LUCCTotalArray[i])
            NumArray.append(num)
        return NumArray


    def calculateFitnessArray(self, initialFrogPopulaArray):
        fitnessArray = []

        for initialFrogPopula in initialFrogPopulaArray:
            ObjectiveFunction_GOV, economyBenefit, ecologyBenefit, carbonBenefit, SpatialBenefit = self.ObjectiveFunction_cal_GOV(
                initialFrogPopula)
            fitnessArray.append(int(ObjectiveFunction_GOV))
        return fitnessArray

    def calculateFitness(self, FrogMap):
        # 面向Map的适宜度计算
        # 输入：FrogMap：青蛙，二维矩阵
        # 输出：ObjectiveFunction_GOV：青蛙适宜度，float
        ObjectiveFunction_GOV, economyBenefit, ecologyBenefit, carbonBenefit, SpatialBenefit = self.ObjectiveFunction_cal_GOV(
            FrogMap)
        return [ObjectiveFunction_GOV, economyBenefit, ecologyBenefit, carbonBenefit, SpatialBenefit]

    def ExpectedBenefit(self, LandUseType: int):
        if LandUseType not in self.LUCCTotalArray:
            return 0
        EconomyBenefit = self.economyBenefitArray[self.LUCCTotalArray.index(LandUseType)]
        EcologyBenefit = self.ecologyBenefitArray[self.LUCCTotalArray.index(LandUseType)]
        CarbonBenefit = self.carbonBenefitArray[self.LUCCTotalArray.index(LandUseType)]
        return 0.5 * EconomyBenefit + 0.25 * EcologyBenefit + 0.25 * CarbonBenefit

    def ExpectedBenefit_cal_PUB(self):
        ExpectedBenefitMapArray = []
        for i in range(len(self.LUCCArray)):
            temperArray = np.ones((self.LUCCShape), float) * self.ExpectedBenefit(self.LUCCArray[i])
            ExpectedBenefitMapArray.append(temperArray)
        return ExpectedBenefitMapArray


class Agent_PUB(Fitness_Cal):
    def __init__(self, LearningOperater: bool = False, learningObjectMap=None):
        super(Agent_PUB, self).__init__()
        self.suitPathArray_PUB = [str(os.path.join(self.inputFolderPath, x)) for x in opt.suitNameArray_PUB]

        self.Weight_U_PUB = opt.Weight_U_PUB
        self.windowSize = opt.windowSize
        self.quantityMatrix, self.topologicalMatrixArray = self.built_Window(self.windowSize)

        self.LearningOperater = LearningOperater  # 是否使用公众信念指导
        if self.LearningOperater == False:
            self.learningObjectMap = np.zeros((len(self.LUCCArray), self.LUCCShape[0], self.LUCCShape[1]), int)
        elif learningObjectMap.shape != self.LUCCShape:
            raise ("error")
        else:
            self.learningObjectMap = learningObjectMap

    # 公众适宜性分数归一化
    def suitMap_cal_PUB(self):
        SuitArray_PUB = []
        for i in range(len(self.LUCCArray)):
            suit_PUB = self.read_img_asArray(self.suitPathArray_PUB[i])
            suit_min = np.min(suit_PUB)
            suit_max = np.max(suit_PUB)
            suit_max_min = suit_max - suit_min
            suit_normalization = (suit_PUB - suit_min) / suit_max_min
            SuitArray_PUB.append(suit_normalization)
        return SuitArray_PUB

    # 拓扑环境得分计算函数
    def TopologicalEnv_cal_PUB(self, LandUse_Map, topologicalMatrixArray):
        def first_nonzero(arr, axis, invalid_val=-1):
            mask = arr != 0
            return np.where(mask.any(axis=axis), mask.argmax(axis=axis), invalid_val)

        topologicalNum = len(topologicalMatrixArray)
        TopologicalEnv = np.zeros((self.LUCCShape), float)
        TopologicalEnvArray = []
        for topologicalMatrix in reversed(topologicalMatrixArray):
            TopologicalEnvNum = signal.convolve2d(LandUse_Map, topologicalMatrix, mode='same')
            TopologicalEnvArray.append(TopologicalEnvNum)
        TopologicalEnvArray = np.array(TopologicalEnvArray).transpose(1, 2, 0)
        TopologicalEnvTemper = first_nonzero(TopologicalEnvArray, axis=2, invalid_val=-1)

        NearestScore = topologicalNum
        for i in range(topologicalNum):
            TopologicalEnv[TopologicalEnvTemper == i] = NearestScore / topologicalNum
            NearestScore -= 1
        TopologicalEnv[TopologicalEnvTemper == -1] = 0

        return TopologicalEnv

    # 邻域环境得分计算函数
    def environment_cal_PUB(self, LUCCMap, LandUseType):
        quantityMatrix, topologicalMatrixArray = self.built_Window(self.windowSize)  # 创建滑动窗口
        LandUse_available_LUCC = (LUCCMap == LandUseType)
        LandUse_Map = np.zeros((LUCCMap.shape), int)
        LandUse_Map[LandUse_available_LUCC] = 1

        QuantityEnv = self.QuantityEnv_cal_PUB(LandUse_Map, quantityMatrix)
        TopologicalEnv = self.TopologicalEnv_cal_PUB(LandUse_Map, topologicalMatrixArray)
        environment = QuantityEnv * TopologicalEnv * self.LUCCAvailable
        return environment, LandUse_Map

    def Learning_cal_PUB(self):
        if self.LearningOperater == True:
            learningObjectMapArray = []
            for i in range(len(self.LUCCArray)):
                learning_available_LUCC = (self.learningObjectMap == self.LUCCArray[i])
                learning_Map = np.zeros((self.LUCCShape), int)
                learning_Map[learning_available_LUCC] = 1
                learningObjectMapArray.append(learning_Map)
            return learningObjectMapArray
        elif self.LearningOperater == False:
            return self.learningObjectMap

    def DecisionMaking_PUB(self, ProbabilityMap, LUCCMap):

        PMaxIndex = np.argmax(ProbabilityMap, axis=2)
        PMax = np.max(ProbabilityMap, axis=2)
        landUsePMax = np.zeros(self.LUCCShape, dtype=int)
        landUseNow = copy.deepcopy(LUCCMap)
        for i in range(len(self.LUCCArray)):
            landUsePMax[PMaxIndex == i] = self.LUCCArray[i]

        DecisionMakingType = (landUseNow != 4) & (landUsePMax != 4) & (landUseNow != landUsePMax) & (self.LUCCMap < 15)
        DecisionMakingType = self.MontoCarlo_Arraycal(PMax) & DecisionMakingType
        DecisionMakingMap = landUseNow
        DecisionMakingMap[DecisionMakingType] = landUsePMax[DecisionMakingType]

        return DecisionMakingMap

    def AgentOptimization_PUB(self, LUCCMap):
        SuitArray_PUB = self.suitMap_cal_PUB()

        UnitValueSum_PUB = np.zeros((self.LUCCShape), float)  # U
        LandUseMapArray_PUB = []
        UnitValueArray_PUB = []
        ProbabilityArray_PUB = []
        Learning_PUB = self.Learning_cal_PUB()
        for i in range(len(self.LUCCArray)):
            environment_PUB, LandUse_Map = self.environment_cal_PUB(LUCCMap, self.LUCCArray[i])
            LandUseMapArray_PUB.append(LandUse_Map)
            UnitValue_PUB = self.Weight_U_PUB[0] * SuitArray_PUB[i] + self.Weight_U_PUB[1] * environment_PUB \
                            + self.Weight_U_PUB[2] * self.ExpectedBenefitMapArray[i] + self.Weight_U_PUB[
                                3] * (1 - self.discountFactor) * Learning_PUB[i]
            UnitValueArray_PUB.append(UnitValue_PUB)
            UnitValueSum_PUB = UnitValueSum_PUB + UnitValue_PUB

        for UnitValue in UnitValueArray_PUB:
            ProbabilityArray_PUB.append(UnitValue / UnitValueSum_PUB)

        ProbabilityMap = np.array(ProbabilityArray_PUB)
        ProbabilityMap = ProbabilityMap.transpose(1, 2, 0)
        del UnitValueArray_PUB, UnitValueSum_PUB, ProbabilityArray_PUB

        DecisionMakingMap_PUB = self.DecisionMaking_PUB(ProbabilityMap, LUCCMap)
        del ProbabilityMap, UnitValue_PUB, LandUse_Map

        return DecisionMakingMap_PUB, SuitArray_PUB


class Agent_DEP(Agent_PUB):
    def __init__(self, LearningOperater: bool = False, learningObjectMap=None):
        super(Agent_DEP, self).__init__(LearningOperater, learningObjectMap)
        self.suitPathArray_DEP = [str(os.path.join(self.inputFolderPath, x)) for x in opt.suitNameArray_DEP]
        self.Size_threshold = opt.Size_threshold
        self.LUCCExpansionLimit = opt.LUCCExpansionLimit
        self.LUCCExpansionScale = opt.LUCCExpansionScale
        self.windowSize = opt.windowSize
        self.Weight_U_DEP = opt.Weight_U_DEP

        self.Slope_Map = self.read_img_asArray(os.path.join(self.inputFolderPath, 'slope.tif'), ArrayType=int)
        self.UrbanBoundary_Map = self.read_img_asArray(os.path.join(self.inputFolderPath, 'UrbanBoundary.tif'),
                                                       ArrayType=int)
        self.EcologicalReserve_Map = self.read_img_asArray(os.path.join(self.inputFolderPath, 'EcologicalReserve.tif'),
                                                           ArrayType=int)
        self.BasicFarmland_Map = self.read_img_asArray(os.path.join(self.inputFolderPath, 'BasicFarmland.tif'),
                                                       ArrayType=int)

    def LandUse_Pretreat_DEP(self, LUCCMap, LandUseType: int):

        LandUse_available_LUCC = (LUCCMap == LandUseType)
        LandUse_Map = np.zeros((LUCCMap.shape), int)
        LandUse_Map[LandUse_available_LUCC] = 1
        return LandUse_Map

    def LandUseArray_Pretreat_DEP(self, LUCCMap):
        LandUse_Map_Array = []
        for i in range(len(self.LUCCArray)):
            LandUse_Map = self.LandUse_Pretreat_DEP(LUCCMap, self.LUCCArray[i])
            LandUse_Map_Array.append(LandUse_Map)
        del LandUse_Map
        return LandUse_Map_Array

    def AggregationEnv_cal_DEP(self, LandUse_Map):

        labeled, numfeatures = label(LandUse_Map)
        dilation = binary_dilation(labeled)
        K_Map = (dilation & ~LandUse_Map).astype(int)
        return K_Map

    def AggregationEnv_Array_cal_DEP(self, LandUse_Map_Array):
        def ObtainDilateBoundary(labeled):
            availableMap = (labeled == 0)
            dilation = binary_dilation(labeled)
            DilateBoundary = (dilation & availableMap)
            del availableMap, dilation
            return DilateBoundary

        def IntersectionNegation(a, b):
            return a & (~b)

        AggregationEnvArray = []

        labeled_close_bool_Array = []
        labeled_open_bool_Array = []
        labeled_origin_Boundary_bool_Array = []
        for i in range(len(self.LUCCArray)):
            labeled_origin, numfeatures = label(LandUse_Map_Array[i])
            labeled_close = binary_erosion(binary_dilation(labeled_origin)).astype(int)
            labeled_open = binary_dilation(binary_erosion(labeled_origin)).astype(int)
            labeled_origin_Boundary = ObtainDilateBoundary(labeled_origin)
            labeled_close_Boundary = ObtainDilateBoundary(labeled_close)
            labeled_close_bool_Array.append(IntersectionNegation(labeled_origin_Boundary, labeled_close_Boundary))
            labeled_open_bool_Array.append(IntersectionNegation((labeled_origin > 0), (labeled_open > 0)))
            labeled_origin_Boundary_bool_Array.append(labeled_origin_Boundary)
        del labeled_origin, numfeatures, labeled_close, labeled_open, labeled_origin_Boundary, labeled_close_Boundary

        for i in range(len(self.LUCCArray)):
            labeled_open_chosen = np.full((self.LUCCMap.shape), False, dtype=bool)
            for j in range(len(self.LUCCArray)):
                if i == j:
                    continue
                labeled_open_chosen = labeled_open_chosen | labeled_open_bool_Array[j]
            labeled_open_chosen = labeled_origin_Boundary_bool_Array[i] & labeled_open_chosen
            AggregationEnv = np.zeros((self.LUCCMap.shape), float)
            AggregationEnv[labeled_origin_Boundary_bool_Array[i]] = 0
            AggregationEnv[labeled_close_bool_Array[i]] = 1
            AggregationEnv[labeled_open_chosen] = 1
            AggregationEnvArray.append(AggregationEnv)
        del labeled_open_chosen, AggregationEnv
        return AggregationEnvArray

    def suitMap_cal_DEP(self):
        SuitArray_DEP = []
        for i in range(len(self.LUCCArray)):
            suit_DEP = self.read_img_asArray(self.suitPathArray_DEP[i])
            suit_min = np.min(suit_DEP)
            suit_max = np.max(suit_DEP)
            suit_max_min = suit_max - suit_min
            suit_normalization = (suit_DEP - suit_min) / suit_max_min
            SuitArray_DEP.append(suit_normalization)
        return SuitArray_DEP

    def ExpansionNum_Cal_DEP(self, LandUse_Map):
        LUCCMap_Num = np.sum(LandUse_Map) * self.LUCCExpansionScale / 100
        ExpansionNum = int(min(LUCCMap_Num, self.LUCCExpansionLimit))
        return ExpansionNum

    def Learning_cal_DEP(self, learningObjectMap):
        learningObjectMapArray = []
        for i in range(len(self.LUCCArray)):
            learning_available_LUCC = (learningObjectMap == self.LUCCArray[i])
            learning_Map = np.zeros((self.LUCCShape), int)
            learning_Map[learning_available_LUCC] = 1
            learningObjectMapArray.append(learning_Map)
        return learningObjectMapArray

    def DecisionMaking_DEP(self, UnitValue_DEP, LandUse_Map, LUCCMap, LandUseType: int, ExpansionNum,
                           ForbiddenAvailable):
        row, column = LandUse_Map.shape
        CoordinateFlat = np.arange(0, row * column)
        UnitValue_DEP_Temper = copy.deepcopy(UnitValue_DEP)
        UnitValue_DEP_Temper = UnitValue_DEP_Temper * ForbiddenAvailable
        UnitValue_DEP_Temper_sum = np.sum(UnitValue_DEP_Temper)
        if UnitValue_DEP_Temper_sum == 0:
            UnitValue_DEP_Temper_sum = 1
        ProbabilityMap = UnitValue_DEP_Temper / UnitValue_DEP_Temper_sum
        ProbabilityFlat = ProbabilityMap.flatten()
        if np.sum(ProbabilityFlat) == 0:
            ChosenCoordinateFlat = []
        else:
            try:
                ChosenCoordinateFlat = np.random.choice(CoordinateFlat, size=ExpansionNum, replace=False,
                                                        p=ProbabilityFlat)
            except:
                print(LandUseType)

        DecisionMakingMap = copy.deepcopy(LUCCMap)
        for i in ChosenCoordinateFlat:
            x = int(i / column)
            y = int(i % column)
            if LandUse_Map[x][y] == 1 and DecisionMakingMap[x][y] != LandUseType:
                raise ("DecisionMaking_DEP函数中x={},y={}的位置出现错误".format(x, y))
            DecisionMakingMap[x][y] = LandUseType
        del UnitValue_DEP_Temper
        return DecisionMakingMap

    def AgentOptimization_DEP(self, LUCCMap):
        DecisionMakingMap_PUB, SuitArray_PUB = self.AgentOptimization_PUB(LUCCMap)
        LUCCExpansionNumArray = []
        LandUseMapArray_DEP = []
        UnitValueArray_DEP = []
        DecisionMakingMapArray_DEP = []

        SuitArray_DEP = self.suitMap_cal_DEP()
        Learning_DEP = self.Learning_cal_DEP(DecisionMakingMap_PUB)

        # 1=允许开发 0=禁止开发
        ForbiddenAvailable = np.ones(LUCCMap.shape)
        for t in self.ForbiddenLUCCArray:
            ForbiddenAvailable = np.array((LUCCMap != t), np.int32) * ForbiddenAvailable

        LandUse_Map_Array = self.LandUseArray_Pretreat_DEP(LUCCMap)
        AggregationEnvArray_DEP = self.AggregationEnv_Array_cal_DEP(LandUse_Map_Array)

        for i in range(len(self.LUCCArray)):
            LandUse_Map = LandUse_Map_Array[i]
            AggregationEnv_DEP = AggregationEnvArray_DEP[i]
            LandUseMapArray_DEP.append(LandUse_Map)

            ExpansionNum = self.ExpansionNum_Cal_DEP(LandUse_Map)
            LUCCExpansionNumArray.append(ExpansionNum)

            UnitValue_DEP = self.Weight_U_DEP[0] * SuitArray_DEP[i] + self.Weight_U_DEP[1] * AggregationEnv_DEP + \
                            self.Weight_U_DEP[2] * (1 - self.discountFactor) * Learning_DEP[i]

            ChosenMap = ((AggregationEnv_DEP == 0) & (LandUse_Map == 0))
            UnitValue_DEP[ChosenMap] = 0
            UnitValueArray_DEP.append(UnitValue_DEP)

            DecisionMakingMap_DEP = self.DecisionMaking_DEP(UnitValue_DEP, LandUse_Map, LUCCMap, self.LUCCArray[i],
                                                            ExpansionNum,
                                                            ForbiddenAvailable)
            DecisionMakingMapArray_DEP.append(DecisionMakingMap_DEP)

        del LUCCExpansionNumArray, LandUseMapArray_DEP, UnitValueArray_DEP

        return DecisionMakingMapArray_DEP, SuitArray_DEP, SuitArray_PUB


class Agent_GOV(Agent_DEP):
    def __init__(self, LearningOperater: bool = False, learningObjectMap=None):
        super(Agent_GOV, self).__init__(LearningOperater, learningObjectMap)
        self.Weight_UnitValue_GOV = opt.Weight_UnitValue_GOV
        self.Weight_Score_GOV = opt.Weight_Score_GOV
        self.Cost = np.array(opt.Cost)

        self.quantitySum = self.row * self.column
        self.quantityStructureOptimizationArray = opt.quantityStructureOptimizationArray
        self.quantityLimitScale = opt.quantityLimitScale
        self.quantityStructureConstruction = opt.quantityStructureConstruction
        self.NumLandUse_QSO_Array = []
        self.NumLandUse_Now_Array = []
        self.ReachSituationArray = []
        for i in self.LUCCArray:
            self.ReachSituationArray.append(False)
            NumLandUse_QSO = self.quantityStructureOptimizationArray[self.LUCCArray.index(i)]
            NumLandUse_QSO_max = NumLandUse_QSO * (1 + self.quantityLimitScale / 100)
            NumLandUse_QSO_middleMax = NumLandUse_QSO * (1 + self.quantityLimitScale * 0.8 / 100)
            NumLandUse_QSO_min = NumLandUse_QSO * (1 - self.quantityLimitScale / 100)
            NumLandUse_QSO_middleMin = NumLandUse_QSO * (1 - self.quantityLimitScale * 0.8 / 100)
            self.NumLandUse_QSO_Array.append(
                [NumLandUse_QSO_max, NumLandUse_QSO_min, NumLandUse_QSO_middleMax, NumLandUse_QSO_middleMin])
        del NumLandUse_QSO, NumLandUse_QSO_max, NumLandUse_QSO_min

    def NumLandUse_Now_Cal(self, DecisionMakingMap_GOV):
        NumArray = []
        for i in range(len(self.LUCCArray)):
            num = np.sum(DecisionMakingMap_GOV == self.LUCCArray[i])
            NumArray.append(num)
        return NumArray

    def Law_Constraints_Map_GOV(self, DecisionMakingMap_GOV):
        Agree_Map_GOV = np.array(self.LUCCAvailable, float)
        Reject_Map_GOV = np.zeros((self.LUCCShape), float)

        Law_Constraints_Map_GOV = []
        for Initial_LandUseTypeIndex in range(len(self.LUCCTotalArray)):
            Law_Constraints_Map_GOV.append(np.zeros((self.LUCCShape), float))
        Law_Constraints_Map_Array = []
        for Initial_LandUseType in self.LUCCTotalArray:
            Law_Constraints_MapTemperArray = []
            for Target_LandUseType in self.LUCCTotalArray:
                if Initial_LandUseType == Target_LandUseType:
                    Law_Constraints_MapTemperArray.append(Reject_Map_GOV)
                    continue
                if (Initial_LandUseType == 4) or (Target_LandUseType == 4):
                    Law_Constraints_MapTemperArray.append(Reject_Map_GOV)  # Waters cannot be developed
                    continue
                Law_Constraints_MapTemper = Agree_Map_GOV.copy()
                if Target_LandUseType == 5:
                    Law_Constraints_MapTemper[self.UrbanBoundary_Map == 1] = 0  # Rules for non-conversion of urban construction land

                if (Initial_LandUseType == 1) & (Target_LandUseType != 2):
                    Law_Constraints_MapTemper[self.Slope_Map >= 25] = 0  # If the slope exceeds 25 degrees, convert farmland back to forests, and select woodlands as the replacement for cultivated land

                if (Initial_LandUseType in [2, 3]) & (Target_LandUseType not in [2, 3]):
                    Law_Constraints_MapTemper[self.EcologicalReserve_Map == 1] = 0  # The ecological protection area will not be developed

                if Initial_LandUseType == 1:
                    Law_Constraints_MapTemper[self.BasicFarmland_Map == 1] = 0  # Protect basic farmland
                Law_Constraints_MapTemperArray.append(Law_Constraints_MapTemper)
                del Law_Constraints_MapTemper
            Law_Constraints_Map_Array.append(Law_Constraints_MapTemperArray)
            del Law_Constraints_MapTemperArray

        for Initial_LandUseTypeIndex in range(len(self.LUCCTotalArray)):
            for Target_LandUseTypeIndex in range(len(self.LUCCTotalArray)):
                Law_Constraints_Map_GOV[Target_LandUseTypeIndex] = np.where(
                    DecisionMakingMap_GOV == self.LUCCTotalArray[Initial_LandUseTypeIndex],
                    Law_Constraints_Map_Array[Initial_LandUseTypeIndex][Target_LandUseTypeIndex],
                    Law_Constraints_Map_GOV[Target_LandUseTypeIndex])

        return Law_Constraints_Map_GOV

    def Quantity_Constraints(self, Initial_LandUseType: int, Target_LandUseType: int):
        def checkNum(LandUseType):
            Index = self.LUCCArray.index(LandUseType)
            NumNow = self.NumLandUse_Now_Array[Index]
            if NumNow <= self.NumLandUse_QSO_Array[Index][1]:
                return 1
            elif NumNow >= self.NumLandUse_QSO_Array[Index][0]:
                return 2
            else:
                return 3

        if Target_LandUseType not in self.LUCCArray:
            return 0
        if self.NumLandUse_Now_Array == []:
            raise ("error")
        if (Initial_LandUseType == 5) & (
                self.NumLandUse_Now_Array[self.LUCCArray.index(5)] <= self.quantityStructureConstruction):
            return 0
        if checkNum(Target_LandUseType) == 1:
            return 1
        elif checkNum(Target_LandUseType) == 2:
            return 0
        elif checkNum(Target_LandUseType) == 3:
            if Initial_LandUseType not in self.LUCCArray:
                return 1
            if checkNum(Initial_LandUseType) in [2, 3]:
                return 1
            elif checkNum(Initial_LandUseType) == 1:
                return 0.5

    def Quantity_Constraints_Map_GOV(self, DecisionMakingMap_GOV):
        Agree_Map_GOV = np.array(self.LUCCAvailable, float)
        Reject_Map_GOV = np.zeros((self.LUCCShape), float)

        NumArray = []
        for i in range(len(self.LUCCArray)):
            num = np.sum(DecisionMakingMap_GOV == self.LUCCArray[i])
            NumArray.append(num)

        Quantity_Constraints_Map_GOV = []
        for i in range(len(self.LUCCTotalArray)):
            if self.LUCCTotalArray[i] not in self.LUCCArray:
                Quantity_Constraints_Map_GOV.append(Agree_Map_GOV)
                continue
            NumNow = np.sum(DecisionMakingMap_GOV == self.LUCCTotalArray[i])
            if NumNow >= self.NumLandUse_QSO_Array[self.LUCCArray.index(self.LUCCTotalArray[i])][0]:
                Quantity_Constraints_Map_GOV.append(Reject_Map_GOV)
            elif NumNow >= self.NumLandUse_QSO_Array[self.LUCCArray.index(self.LUCCTotalArray[i])][2]:
                a = self.NumLandUse_QSO_Array[self.LUCCArray.index(self.LUCCTotalArray[i])][2]
                b = self.NumLandUse_QSO_Array[self.LUCCArray.index(self.LUCCTotalArray[i])][0]
                inertia = NumNow / (a - b) - b / (a - b)
                del a, b
                Quantity_Constraints_MapTemper = Agree_Map_GOV.copy()
                Quantity_Constraints_MapTemper[self.LUCCAvailable == 1] = inertia
                Quantity_Constraints_Map_GOV.append(Quantity_Constraints_MapTemper)
            if NumNow <= self.NumLandUse_QSO_Array[self.LUCCArray.index(self.LUCCTotalArray[i])][1]:
                Quantity_Constraints_Map_GOV.append(Reject_Map_GOV)
            else:
                Quantity_Constraints_Map_GOV.append(Agree_Map_GOV)
        return Quantity_Constraints_Map_GOV

    def K_Cost_Map_GOV(self, DecisionMakingMap_GOV):
        K_Cost_Map_GOV = []
        for Initial_LandUseTypeIndex in range(len(self.LUCCTotalArray)):
            K_Cost_Map_GOV.append(np.zeros((self.LUCCShape), float))

        for Initial_LandUseTypeIndex in range(len(self.LUCCTotalArray)):
            for Target_LandUseTypeIndex in range(len(self.LUCCTotalArray)):
                K_Cost_Map_GOV[Target_LandUseTypeIndex] = np.where(
                    DecisionMakingMap_GOV == self.LUCCTotalArray[Initial_LandUseTypeIndex],
                    np.ones((self.LUCCShape), float) - self.Cost[Target_LandUseTypeIndex][Initial_LandUseTypeIndex],
                    K_Cost_Map_GOV[Target_LandUseTypeIndex])
        return K_Cost_Map_GOV

    def Quantity_Update(self, Initial_LandUseType: int, Target_LandUseType: int):
        if Initial_LandUseType in self.LUCCArray:
            IndexOut = self.LUCCArray.index(Initial_LandUseType)
            self.NumLandUse_Now_Array[IndexOut] -= 1
        if Target_LandUseType in self.LUCCArray:
            IndexIn = self.LUCCArray.index(Target_LandUseType)
            self.NumLandUse_Now_Array[IndexIn] += 1

    def DecisionMaking_GOV(self, ScoreArray_3D, SingleScoreArray_3D, DecisionArray, LUCCMap_GOV):

        def SingleDecision_Cal(SingleDecision_bool, DecisionArray_bool, LUCCMap_GOV, SingleScoreArray_3D):
            SingleScoreMap = np.zeros((self.LUCCShape), float)
            DecisionMap = np.full((self.LUCCShape), 15, dtype=int)
            for i in range(len(self.LUCCArray)):
                chosen_bool = SingleDecision_bool & DecisionArray_bool[i]
                SingleScoreMap = np.where(chosen_bool, SingleScoreArray_3D[i], SingleScoreMap)
                DecisionMap = np.where(chosen_bool, DecisionArray[0], DecisionMap)
            result_bool = self.MontoCarlo_Arraycal(SingleScoreMap)
            resultMap = LUCCMap_GOV
            resultMap = np.where(result_bool, DecisionMap, resultMap)
            return resultMap

        DecisionArray_bool = []
        for i in range(len(self.LUCCArray)):
            DecisionArray_bool.append(np.full((self.LUCCShape), False, dtype=bool))

        for i in range(len(self.LUCCArray)):
            for j in range(len(DecisionArray)):
                DecisionArray_bool[i][DecisionArray[j] == self.LUCCArray[i]] = True

        DecisionSumArray_bool = np.sum(np.array(DecisionArray_bool, int), axis=0)
        MutiDecision_bool = (DecisionSumArray_bool > 1)
        SingleDecision_bool = (DecisionSumArray_bool == 1)
        NoneDecision_bool = (DecisionSumArray_bool == 0)

        for i in range(len(self.LUCCArray)):
            ScoreArray_3D[i][DecisionArray_bool[i] == False] = 0

        MutiDecision_Result = self.Roulette_Arraycal(ScoreArray_3D, LUCCMap_GOV, MutiDecision_bool)
        SingleDecision_Result = SingleDecision_Cal(SingleDecision_bool, DecisionArray_bool, LUCCMap_GOV,
                                                   SingleScoreArray_3D)

        DecisionMakingMap_GOV_Result = MutiDecision_Result.copy()
        DecisionMakingMap_GOV_Result = np.where(SingleDecision_bool, SingleDecision_Result,
                                                DecisionMakingMap_GOV_Result)
        DecisionMakingMap_GOV_Result = np.where(NoneDecision_bool, LUCCMap_GOV, DecisionMakingMap_GOV_Result)

        return DecisionMakingMap_GOV_Result

    def AgentOptimization_GOV(self, LUCCMap):
        DecisionMakingMapArray_DEP, SuitArray_DEP, SuitArray_PUB = self.AgentOptimization_DEP(LUCCMap)

        Decision_MapArray = []
        for i in range(len(DecisionMakingMapArray_DEP)):
            Decision_MapArray.append(DecisionMakingMapArray_DEP[i])

        self.NumLandUse_Now_Array = self.NumLandUse_Now_Cal(LUCCMap)

        # 政府智能体决策
        LUCCMap_GOV = copy.deepcopy(LUCCMap)
        K_Low_MapArray = self.Law_Constraints_Map_GOV(LUCCMap_GOV)
        K_Size_MapArray = self.Quantity_Constraints_Map_GOV(LUCCMap_GOV)
        K_Cost_MapArray = self.K_Cost_Map_GOV(LUCCMap_GOV)
        ScoreArray_3D = []
        SingleScoreArray_3D = []
        for i in range(len(self.LUCCArray)):
            K_Low_Map = K_Low_MapArray[self.LUCCTotalArray.index(self.LUCCArray[i])]
            K_Size_Map = K_Size_MapArray[self.LUCCTotalArray.index(self.LUCCArray[i])]
            UnitValue_Map = (SuitArray_PUB[i] * self.Weight_UnitValue_GOV[0]) + \
                            (SuitArray_DEP[i] * self.Weight_UnitValue_GOV[1])
            K_Cost_Map = K_Cost_MapArray[self.LUCCTotalArray.index(self.LUCCArray[i])]
            ScoreMap = K_Low_Map * K_Size_Map * (
                        UnitValue_Map * self.Weight_Score_GOV[0] + K_Cost_Map * self.Weight_Score_GOV[1])
            ScoreArray_3D.append(ScoreMap)
            SingleScoreArray_3D.append(K_Low_Map * K_Size_Map)
        DecisionMakingMap_GOV_Result = self.DecisionMaking_GOV(ScoreArray_3D, SingleScoreArray_3D, Decision_MapArray,
                                                               LUCCMap_GOV)

        return DecisionMakingMap_GOV_Result


if __name__ == '__main__':

    sys.setrecursionlimit(99999999)
    myRSImg = myTIF()
    myFile = myInfoFile()

    f = myFile.myOpenInfoFile(os.path.join(opt.outputFolderPath, opt.logName))

    dataset = myRSImg.read_img_dataset(os.path.join(opt.inputFolderPath, opt.LUCCName))
    proj, geotrans, bands, width, height = myRSImg.get_proj_info(dataset)

    agent_GOV = Agent_GOV(False)
    LUCCMap = agent_GOV.read_img_asArray(os.path.join(opt.inputFolderPath, opt.LUCCName),
                                         ArrayType=int)
    FitnessArray = agent_GOV.calculateFitness(LUCCMap)
    NumArray = agent_GOV.Num_Cal(LUCCMap)
    totalStart = time.time()
    Record = []
    evalution = 0
    RecordTemper = []
    for i in FitnessArray:
        RecordTemper.append(i)
    for i in NumArray:
        RecordTemper.append(i)
    Record.append(RecordTemper)

    for evalution in range(opt.epochMax):
        print("--------{}-MAS epoch--------".format(evalution + 1))
        epochStart1 = time.time()
        LUCCMap = agent_GOV.AgentOptimization_GOV(LUCCMap)

        if evalution % 5 == 0 and evalution != 0:
            agent_GOV.OutputImage(LUCCMap,
                                  os.path.join(opt.outputFolderPath, opt.InterResultsFolderPath,
                                               "MAS_E" + str(evalution) + ".tif"))
        FitnessArray = agent_GOV.calculateFitness(LUCCMap)
        NumArray = agent_GOV.Num_Cal(LUCCMap)
        RecordTemper = []
        for i in FitnessArray:
            RecordTemper.append(i)
        for i in NumArray:
            RecordTemper.append(i)
        Record.append(RecordTemper)
        epochEnd1 = time.time()

    totalEnd = time.time()

    myFile.myCloseInfoFile(f)
    agent_GOV.OutputImage(LUCCMap, os.path.join(opt.outputFolderPath, "optEnd.tif"))

    outputExcelPath = os.path.join(opt.outputFolderPath, "MASFitness.csv")
    eval = range(len(Record))
    fitness_dict = dict(zip(eval, Record))
    df_District = pd.DataFrame(fitness_dict, index=["fitness", "economyBenefit", "ecologyBenefit",
                                                    "carbonBenefit", "socialBenefit", "AgriNum", "ForestNum",
                                                    "GrassNum", "WaterNum", "ConNum", "UnUsedNum"]).transpose()
    df_District.to_csv(outputExcelPath, encoding='utf_8_sig')


