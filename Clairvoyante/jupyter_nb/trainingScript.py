import sys
sys.path.append('../')
import numpy as np
import time
import pickle
from random import randrange
import tensorflow.compat.v1 as tf 
tf.disable_v2_behavior()
import clairvoyante.utils_v2 as utils
import clairvoyante.clairvoyante_v2 as cv
import clairvoyante.param as param
from matplotlib import pyplot as plt
from argparse import ArgumentParser
def calculateAccuracy(predicted, labels, top2=True, verbose=False):
    
    top1Count = 0
    top2Count = 0
    # Evaluating on bases
    for predictV, annotateV in zip(predicted[0], labels[:,0:4]):
        sortPredictV = predictV.argsort()[::-1]    
        if np.argmax(annotateV) == sortPredictV[0]:
            top1Count += 1
            top2Count += 1
        elif np.argmax(annotateV) == sortPredictV[1]: 
            top2Count += 1
    
    if verbose:
        # Evaluating on zygosity
        zygosityEval = np.zeros((2,2))
        for predictV, annotateV in zip(predicted[1], labels[:,4:6]):
            zygosityEval[np.argmax(annotateV)][np.argmax(predictV)] += 1

        variantTypeEval = np.zeros((4,4))
        for predictV, annotateV in zip(predicted[2], labels[:,6:10]):
            variantTypeEval[np.argmax(annotateV)][np.argmax(predictV)] += 1

        indelLengthEval = np.zeros((6,6))
        for predictV, annotateV in zip(predicted[3], labels[:,10:16]):
            indelLengthEval[np.argmax(annotateV)][np.argmax(predictV)] += 1
    
    return float(top1Count)*100/len(predicted[0]), float(top2Count)*100/len(predicted[0]) 

def plotGraph(losses, t1Acc, t2Acc, name="Training"):
    
#     print(len(losses))
#     print(t1Acc.shape)
#     print(t2Acc.shape)
    
    epochs = np.arange(len(losses))
    plt.figure()
    plt.plot(epochs, losses, label= name + " loss")
    plt.legend()
    plt.savefig(name+" Loss History.jpg")
    
    plt.figure()
    plt.plot(epochs, t1Acc, label= name + " top1 accuracy")
    plt.plot(epochs, t2Acc, label= name + " top2 accuracy")
    plt.legend()
    plt.savefig(name+" Acc History.jpg")
    

# training the model. The code train on all variants and validate on the first 10% variant sites
def trainingAbstraction(epochs, model, savePath, modelName, initLr, reduceAfter, total, batchSize, threshold, constantLr=True):
    
    numValItems = int(total * 0.1 + 0.499)
    trainingLosses = []
    trainingAccuraciesT1 = []
    trainingAccuraciesT2 = []
    validationLosses = []
    validationAccuraciesT1 = []
    validationAccuraciesT2 = []
    bestValAcc = 0
    numBatches = total // trainBatchSize
    valXArray, _, _ = utils.DecompressArray(XArrayCompressed, 0, numValItems, total)
    valYArray, _, _ = utils.DecompressArray(YArrayCompressed, 0, numValItems, total)
    print("Number of variants for validation: %d" % len(valXArray))

    trainingStart = time.time()
    
    print("Start at learning rate: %.2e" % m.setLearningRate(initLr))
    
    for currentEpoch in range(epochs):
        epochStartTime = time.time()
        epochTrainingLoss = 0
        epochValidationLoss = 0
        datasetPtr = 0
        
        trainingBase = [] 
        trainingZ = []
        trainingT = [] 
        trainingL = []
        trainingLabels = np.empty((trainBatchSize, 16), dtype=float)

        testingBase = [] 
        testingZ = []
        testingT = [] 
        testingL = []

        if currentEpoch % reduceAfter == 0 and not constantLr:
            m.setLearningRate()


        for batch in range(numBatches):
            # Fetching data from compressed arrays in the tensor.bin file
            XBatch, _, endFlag = utils.DecompressArray(XArrayCompressed, datasetPtr, trainBatchSize, total)
            YBatch, _, _ = utils.DecompressArray(YArrayCompressed, datasetPtr, trainBatchSize, total)
            epochTrainingLoss += m.train(XBatch, YBatch)[0]/trainBatchSize
            trainPredObject = m.predict(XBatch)
            trainingBase.append(trainPredObject[0])
            trainingZ.append(trainPredObject[1])
            trainingT.append(trainPredObject[2])
            trainingL.append(trainPredObject[3])
            datasetPtr += trainBatchSize


        trainingBase = np.concatenate(trainingBase[:])
        trainingZ = np.concatenate(trainingZ[:])
        trainingT = np.concatenate(trainingT[:])
        trainingL = np.concatenate(trainingL[:])

        trainingLosses.append(float(epochTrainingLoss)/numBatches)
        trainingLabels, _, _ = utils.DecompressArray(YArrayCompressed, 0, total, total)    
        epochTrainingAccuracies = calculateAccuracy((trainingBase, trainingZ, trainingT, trainingL), trainingLabels)
        trainingAccuraciesT1.append(epochTrainingAccuracies[0]/100)
        trainingAccuraciesT2.append(epochTrainingAccuracies[1]/100)

        epochValidationLoss = m.getLoss(valXArray, valYArray)
        validationLosses.append(epochValidationLoss)
        validationBase, validationZ, validationT, validationL = m.predict(valXArray)
        epochValidationAccuracies = calculateAccuracy((validationBase, validationZ, validationT, validationL), valYArray)
        validationAccuraciesT1.append(epochValidationAccuracies[0]/100)
        validationAccuraciesT2.append(epochValidationAccuracies[1]/100)

        if bestValAcc < epochTrainingAccuracies[0]:
            bestValAcc = epochValidationAccuracies[0]
#             print("Saving new model")
            m.saveParameters(savePath + modelName)

        epochEndTime = time.time()
        print("|".join(
            [
            f"Epoch: {currentEpoch+1}",
            "EpochTime: %.2fs" % (epochEndTime - epochStartTime),
            "TrainingLoss: %.2f" % float(epochTrainingLoss/numBatches),
            "TrainingAccuracy:%2.3f, %2.3f" % epochTrainingAccuracies,
            "ValidationLoss: %.2f" % float(epochValidationLoss/numValItems),
            "ValidationAccuracy:%2.3f, %2.3f" % epochValidationAccuracies, 
            ]))
        
        if epochValidationAccuracies[0] > threshold:
            print("TTA 92: %.2fs"%(time.time() - trainingStart))
            break



if __name__ == "__main__":


    
    with open("/scratch/mu2047/Project/Clairvoyante/Clairvoyante/training/tensor.bin", "rb") as fh:
        total = pickle.load(fh)
        XArrayCompressed = pickle.load(fh)
        YArrayCompressed = pickle.load(fh)
        posArrayCompressed = pickle.load(fh)
        
    datasetSize = total
    print("The size of training dataset: {}".format(total))

    m = cv.Clairvoyante()
    m.init()
    savePath = "./savedModels/"
    t1Threshold = 92
    epochs = 500
        
    parser = ArgumentParser()
    parser.add_argument('--batch_size', type=int, default=4096)
    parser.add_argument('--model_name', type=str, default='ConstantLR,initLR=0.001')
    parser.add_argument('--reduce_after', type=int, default=10)
    parser.add_argument('--init_lr', type=float, default=0.001)
    parser.add_argument('--constant_lr', type=bool, default=True)
    
    args = parser.parse_args()
    
    trainBatchSize = args.batch_size
    modelName = args.model_name
    reduceAfter = args.reduce_after 
    initLr = args.init_lr
    constant_lr = args.constant_lr

    print("Inside trainingScript")
    print(args)
    
    trainingAbstraction(epochs, m, savePath, modelName, initLr, reduceAfter, datasetSize, trainBatchSize, t1Threshold, constant_lr)
    plotGraph(trainingLosses, trainingAccuraciesT1, trainingAccuraciesT2, modelName + " Training")
    plotGraph(trainingLosses, trainingAccuraciesT1, trainingAccuraciesT2, modelName + " Testing ")