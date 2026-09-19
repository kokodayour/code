# -*- coding: utf-8 -*-
import numpy as np
import random
from osgeo import gdal, gdal_array, gdalnumeric, ogr, osr
from PIL import Image, ImageDraw
import numpy as np
import operator
import math
import os
import random
import sys
import copy
import argparse
from multiprocessing import Pool
from MLAS import *
from Parser import opt
import traceback
import pandas as pd


class Frog(Agent_GOV):
    def __init__(self):
        super(Frog, self).__init__()
        self.memeplexes_number = opt.memeplexes_number
        self.frogNum = opt.frogNum
        self.submemep_q = opt.submemep_q
        self.circulation_N = opt.circulation_N
        self.epochMax = opt.epochMax
        self.TotalNum = self.memeplexes_number * self.frogNum
        self.VariationScale = opt.VariationScale

        self.memeplexes = np.zeros((self.memeplexes_number, self.frogNum, self.row, self.column))
        self.mem_fitness = np.zeros((self.memeplexes_number, self.frogNum))
        self.frog_g = copy.deepcopy(self.LUCCMap)
        self.WindowLengthRatio = opt.WindowLengthRatio
        self.ForbiddenMap = self.ForbiddenMap_Cal()

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

        self.Slope_Map = self.read_img_asArray(os.path.join(self.inputFolderPath, 'slope.tif'), ArrayType=int)
        self.UrbanBoundary_Map = self.read_img_asArray(os.path.join(self.inputFolderPath, 'UrbanBoundary.tif'),
                                                       ArrayType=int)
        self.EcologicalReserve_Map = self.read_img_asArray(os.path.join(self.inputFolderPath, 'EcologicalReserve.tif'),
                                                           ArrayType=int)
        self.BasicFarmland_Map = self.read_img_asArray(os.path.join(self.inputFolderPath, 'BasicFarmland.tif'),
                                                       ArrayType=int)

    def ForbiddenMap_Cal(self):
        ForbiddenMap = np.full((self.LUCCMap.shape), False, dtype=bool)
        for i in self.ForbiddenLUCCArray:
            ForbiddenMap = ForbiddenMap | (self.LUCCMap == i)
        return np.array(~ForbiddenMap, np.int32)


    def Variogram(self, VariationWindow, VariationWindowAvailable):
        def Quantity_Constraints_Cal(LUCCMap):
            Quantity_Constraints_Array = []
            for i in range(len(self.LUCCArray)):
                NumNow = np.sum(LUCCMap == self.LUCCArray[i])
                if NumNow >= self.NumLandUse_QSO_Array[i][0]:
                    Quantity_Constraints_Array.append(False)
                elif NumNow <= self.NumLandUse_QSO_Array[i][1]:
                    Quantity_Constraints_Array.append(False)
                else:
                    Quantity_Constraints_Array.append(True)
            return Quantity_Constraints_Array

        row, column = VariationWindow.shape
        VariogramMap_Output = copy.deepcopy(VariationWindow)
        numAll = np.sum(VariationWindowAvailable)

        ConstraintsMap = np.array((VariogramMap_Output != 5), dtype=int)
        VariationWindowAvailable = VariationWindowAvailable & self.ForbiddenMap & ConstraintsMap
        Quantity_Constraints = Quantity_Constraints_Cal(VariationWindow.copy())
        Probablilities_Array = self.suitMap_cal_DEP()
        Quantity_Constraints_Array = np.random.rand(len(self.LUCCArray))
        Quantity_Constraints_Array[Quantity_Constraints == False] = 0
        Quantity_Constraints_ArraySum = np.sum(Quantity_Constraints_Array)
        Quantity_Constraints_Array = np.array(
            (Quantity_Constraints_Array / Quantity_Constraints_ArraySum) * numAll * self.VariationScale, int)

        LandUse_Map_Array = self.LandUseArray_Pretreat_DEP(VariogramMap_Output)
        AggregationEnvArray_DEP = self.AggregationEnv_Array_cal_DEP(LandUse_Map_Array)
        for i in range(len(self.LUCCArray)):
            if Quantity_Constraints[i] == False:
                continue
            Probablilities = Probablilities_Array[i]
            AggregationEnv_DEP = AggregationEnvArray_DEP[i]
            Probablilities[AggregationEnv_DEP != 1] = 0
            Probablilities = Probablilities * VariationWindowAvailable
            ProbablilitiesSum = np.sum(Probablilities)
            Probablilities = Probablilities / ProbablilitiesSum
            num_elements_to_choose = Quantity_Constraints_Array[i]
            chosen_indices = np.random.choice(range(VariogramMap_Output.size), size=num_elements_to_choose,
                                              p=Probablilities.ravel())
            VariogramMap_Output.ravel()[chosen_indices] = self.LUCCArray[i]
        return VariogramMap_Output

    def initialFrogPopula(self):
        initialFrogPopulaArray = []
        initialFrogPopulaArray.append(self.LUCCMap)
        for i in range(self.TotalNum - 1):
            LUCCMap_Variogram = self.Variogram(self.LUCCMap, self.LUCCAvailable)
            initialFrogPopulaArray.append(LUCCMap_Variogram)
        return initialFrogPopulaArray

    def descendOrderArray(self, populationsArray, fitnessArray):
        fitnessArrayIndex = sorted(range(len(fitnessArray)), key=lambda x: fitnessArray[x], reverse=True)
        TemperFrogPopulaArray = []
        for i in fitnessArrayIndex:
            TemperFrogPopulaArray.append(populationsArray[i])
        TemperFitnessArray = fitnessArray.copy()
        TemperFitnessArray.sort(reverse=True)

        return TemperFrogPopulaArray, TemperFitnessArray

    def constructSubmemep(self, current_memep, current_fitnessArray):
        indexArray = [i for i in range(len(current_memep))]
        chosen_indexArray = random.sample(indexArray, self.submemep_q)
        chosen_memep = []
        chosen_fitnessArray = []
        for i in chosen_indexArray:
            chosen_memep.append(current_memep[i])
            chosen_fitnessArray.append(current_fitnessArray[i])
        chosen_memep, chosen_fitnessArray = self.descendOrderArray(chosen_memep, chosen_fitnessArray)

        return chosen_memep, chosen_fitnessArray

    def error_call_back(self, err):
        print(f"error：{str(err)}")
        traceback.print_exc()

    def call_back(self, memeplexes_sub, mem_fitness_sub, im):
        # 更新社群
        self.memeplexes[im] = memeplexes_sub
        self.mem_fitness[im] = mem_fitness_sub

    def renewFrog_g(self, a):
        self.frog_g = a

    def localSearch_sub(self, im):
        memeplexes_sub = self.memeplexes[im].copy()
        mem_fitness_sub = self.mem_fitness[im].copy()

        for iN in range(self.circulation_N):
            submemep, sub_fitnessArray = self.constructSubmemep(memeplexes_sub, mem_fitness_sub)

            sub_best = submemep[0]
            sub_worst = submemep[-1]
            sub_fitness_worst = sub_fitnessArray[-1]

            new_position, Fitness_NW, LearningForm = self.updateWorst(sub_best, sub_worst, sub_fitness_worst)
            index = np.where(mem_fitness_sub == sub_fitnessArray[-1])
            memeplexes_sub[index] = new_position
            mem_fitness_sub[index] = Fitness_NW


        return (memeplexes_sub, mem_fitness_sub)

    def windowConstruct(self, length):
        point1 = random.randint(0, length - 1)
        point2 = random.randint(0, length - 1)
        pointStart = min(point1, point2)
        pointEnd = max(point1, point2)
        if pointEnd - pointStart <= self.WindowLengthRatio * length:
            return self.windowConstruct(length)
        else:
            return pointStart, pointEnd

    def ConstuctLearningMap(self, local_best, global_best):
        core_index_row1, core_index_row2 = self.windowConstruct(self.row)
        core_index_column1, core_index_column2 = self.windowConstruct(self.column)
        window_update_L = local_best[core_index_row1:core_index_row2, core_index_column1:core_index_column2]
        window_update_g = global_best[core_index_row1:core_index_row2, core_index_column1:core_index_column2]
        LearningMap_L = np.zeros((self.LUCCShape), int)
        LearningMap_g = np.zeros((self.LUCCShape), int)
        LearningMap_L[core_index_row1:core_index_row2, core_index_column1:core_index_column2] = window_update_L
        LearningMap_g[core_index_row1:core_index_row2, core_index_column1:core_index_column2] = window_update_g
        return LearningMap_L, LearningMap_g

    def updateWorst(self, local_best, local_wrost, sub_fitness_worst):
        LearningMap_L, LearningMap_g = self.ConstuctLearningMap(local_best, self.frog_g)

        agent_GOV = Agent_GOV(True, LearningMap_L)
        new_worst = agent_GOV.AgentOptimization_GOV(local_wrost.copy())
        Fitness_NW = (self.calculateFitness(new_worst))[0]

        if Fitness_NW > sub_fitness_worst:
            return new_worst, Fitness_NW, 1
        else:
            agent_GOV = Agent_GOV(True, LearningMap_g)
            new_worst = agent_GOV.AgentOptimization_GOV(local_wrost.copy())
            Fitness_NW = (self.calculateFitness(new_worst))[0]
            if Fitness_NW > sub_fitness_worst:
                return new_worst, Fitness_NW, 2
            else:
                new_worst = self.Variogram(local_wrost.copy(), self.LUCCAvailable)
                Fitness_NW = (self.calculateFitness(new_worst))[0]
                return new_worst, Fitness_NW, 3


    def learningOperator(self, populationsArray, fitnessArray):

        for j in range(self.frogNum):
            for k in range(self.memeplexes_number):
                self.memeplexes[k][j] = (populationsArray[k + self.memeplexes_number * j])
                self.mem_fitness[k][j] = (fitnessArray[k + self.memeplexes_number * j])

        for im in range(self.memeplexes_number):
            t = self.localSearch_sub(im)
            self.memeplexes[im] = np.array(t[0])
            self.mem_fitness[im] = np.array(t[1])
            del t

        Output_populationsArray = self.memeplexes.reshape(self.TotalNum, self.row, self.column)
        Output_fitnessArray = self.mem_fitness.reshape(self.TotalNum).tolist()

        return Output_populationsArray, Output_fitnessArray


if __name__ == '__main__':
    sys.setrecursionlimit(99999999)
    myRSImg = myTIF()
    myFile = myInfoFile()

    f = myFile.myOpenInfoFile(os.path.join(opt.outputFolderPath, opt.logName))

    dataset = myRSImg.read_img_dataset(os.path.join(opt.inputFolderPath, opt.LUCCName))
    proj, geotrans, bands, width, height = myRSImg.get_proj_info(dataset)

    frog = Frog()
    totalStart = time.time()
    populationsArray = frog.initialFrogPopula()
    fitnessArray = frog.calculateFitnessArray(populationsArray)

    Record = []
    evalution = 0
    show_fitness = []

    for evalution in range(opt.epochMax):
        print("----------{}-SSFLA-MLAS Epoch----------".format(evalution + 1))
        epochStart1 = time.time()
        populationsArray, fitnessArray = frog.descendOrderArray(populationsArray, fitnessArray)
        frog.renewFrog_g(populationsArray[0])
        if evalution % 5 == 0 and evalution != 0:
            frog.OutputImage(populationsArray[0], os.path.join(opt.outputFolderPath, opt.InterResultsFolderPath,
                                                               "GE_E" + str(evalution) + ".tif"))
        FitnessSingleArray = frog.calculateFitness(populationsArray[0])
        NumArray = frog.Num_Cal(populationsArray[0])
        RecordTemper = []
        for i in FitnessSingleArray:
            RecordTemper.append(i)
        for i in NumArray:
            RecordTemper.append(i)
        Record.append(RecordTemper)
        populationsArray, fitnessArray = frog.learningOperator(populationsArray, fitnessArray)
        epochEnd1 = time.time()

    print("--------Finish--------")
    populationsArray, fitnessArray = frog.descendOrderArray(populationsArray, fitnessArray)
    FitnessSingleArray = frog.calculateFitness(populationsArray[0])
    NumArray = frog.Num_Cal(populationsArray[0])
    RecordTemper = []
    for i in FitnessSingleArray:
        RecordTemper.append(i)
    for i in NumArray:
        RecordTemper.append(i)
    Record.append(RecordTemper)
    totalEnd = time.time()
    myFile.myCloseInfoFile(f)
    frog.OutputImage(populationsArray[0], os.path.join(opt.outputFolderPath, "optEnd.tif"))

    outputExcelPath = os.path.join(opt.outputFolderPath, "LeapFrogFitness.csv")
    eval = range(len(Record))
    fitness_dict = dict(zip(eval, Record))
    df_District = pd.DataFrame(fitness_dict, index=["fitness", "economyBenefit", "ecologyBenefit", 
                                                    "carbonBenefit", "socialBenefit", "AgriNum", "ForestNum",
                                                    "GrassNum", "WaterNum", "ConNum", "UnUsedNum"]).transpose()
    df_District.to_csv(outputExcelPath, encoding='utf_8_sig')