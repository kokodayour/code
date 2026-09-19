import argparse

parser = argparse.ArgumentParser(description='SSFLA-MLAS LandUse Optimization')
parser.add_argument('--memeplexes_number', type=int, default=50, help='Population size')
parser.add_argument('--frogNum', type=int, default=32, help='Number of individuals within the population')
parser.add_argument('--circulation_N', type=int, default=10, help='Number of evolutions')
parser.add_argument('--submemep_q', type=int, default=10, help='Size of subgroups')
parser.add_argument('--epochMax', type=int, default=600, help='Epochs')
parser.add_argument('--VariationScale', type=int, default=0.001, help='Variation ratio of mutation function，0-1')
parser.add_argument('--WindowLengthRatio', type=float, default=0.3, help='The proportion of the shortest window edge length cropped in the learning operator，float，1-0，default 0')

parser.add_argument('--inputFolderPath', type=str, default=r"D:\XXX\InputFolder", help='Input folder path')
parser.add_argument('--outputFolderPath', type=str, default= r"D:\XXX\OutputFolder", help='Output folder path')
parser.add_argument('--InterResultsFolderPath', type=str, default= r"./InterResults", help='Intermediate result folder path')
parser.add_argument('--LUCCName', type=str, default= r"LUCC.tif", help='Land use map')
parser.add_argument('--logName', type=str, default= r"Optimization_log.txt", help='Log')
parser.add_argument('--CSVName', type=str, default= r"fitness.csv", help='Optimize target output')

parser.add_argument('--LUCCArray', type=list, default= [1, 2, 3, 5], help='Number of land types to be optimized')
parser.add_argument('--LUCCTotalArray', type=list, default= [1, 2, 3, 4, 5, 6] , help='Number of all land types')
parser.add_argument('--ForbiddenLUCCArray', type=list, default= [0, 4, 15], help='Land types that do not participate in optimization (including background)')

parser.add_argument('--BenefitNormalizationScale', type= int, default= 1000000 , help='Normalization upper limit of objective function')
parser.add_argument('--Weight_ObjectiveFunction_GOV', type=list, default= [0.33, 0.165, 0.165, 0.33], help='Objective function weight')
parser.add_argument('--economyBenefitArray', type=list, default= [0, 0, 0, 0, 0, 0], help='Economic objective coefficients')
parser.add_argument('--ecologyBenefitArray', type=list, default= [0, 0, 0, 0, 0, 0], help='ESV coefficients')
parser.add_argument('--carbonBenefitArray', type=list, default= [0, 0, 0, 0, 0, 0], help='Carbon coefficients')

parser.add_argument('--discountFactor', type= float, default= 0.4 , help='Learning Intensity， 0-1')

parser.add_argument('--suitNameArray_PUB', type= list, default= ["PUB_1.tif", "PUB_2.tif", "PUB_3.tif", "PUB_4.tif"] , help='Suit for public')
parser.add_argument('--windowSize', type= int, default= 3 , help='Environmental perception range， eg: 1->3*3,2->5*5')
parser.add_argument('--Weight_U_PUB', type=list, default= [0.25, 0.25, 0.25, 0.25] , help='The weight of U in public agents')

parser.add_argument('--suitNameArray_DEP', type= list, default= ["DEP_1.tif", "DEP_2.tif", "DEP_3.tif", "DEP_4.tif"] , help='Suit for department')
parser.add_argument('--Size_threshold', type= int, default= 5 , help='threshold parameter，default 25')
parser.add_argument('--LUCCExpansionLimit', type= int, default= 5000 , help='Upper limit of expanded land type grid count in a single epoch')
parser.add_argument('--LUCCExpansionScale', type= int, default= 70 , help='Upper limit of expanded land type grid proportion in a single epoch，%')
parser.add_argument('--Weight_U_DEP', type=list, default= [0.33, 0.33, 0.33] , help='The weight of U in department agents')

parser.add_argument('--Cost', type= list, default= [[0, 0.3, 0.6, 1, 0.1, 1],
                                                    [0.7, 0, 0.89, 1, 0.97, 1],
                                                    [0.6, 0.2, 0, 1, 0.65, 1],
                                                    [1, 1, 1, 0, 1, 1],
                                                    [0.85, 0.7, 0.9, 1, 0, 1],
                                                    [0.65, 0.4, 0.4, 1, 0.2, 0]] , help='Cost')
parser.add_argument('--Weight_UnitValue_GOV', type= list, default= [0.5, 0.5] , help='U-weight of agents (public, department)')
parser.add_argument('--Weight_Score_GOV', type= list, default= [0.5, 0.5] , help='Weight of Score（expected utility,Cost）')
parser.add_argument('--quantityStructureOptimizationArray', type= list, default= [1437127, 553996, 69360, 216505] , help='Upper limit of quantity structure')
parser.add_argument('--quantityStructureConstruction', type= int, default= 226505 , help='Actual value of construction land')
parser.add_argument('--quantityLimitScale', type= int, default= 10 , help='Quantity structure limitation，%')

opt = parser.parse_args()