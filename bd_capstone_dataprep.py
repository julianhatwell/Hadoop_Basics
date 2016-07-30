from pathlib import WindowsPath, PureWindowsPath
import csv

fileloc = 'C:/Dev/Study/Hadoop/big_data_capstone_datasets_and_scripts/'
folders = ('chat', 'combined', 'flamingo')

for folder in folders:
    folder = folder + '-data'
    path = WindowsPath(fileloc + folder)
    if folder == 'chat-data':
        pattern = '*with_header.csv'
    else: pattern = '*.csv'
    files = sorted(path.glob(pattern))
    allData = dict()
    for file in files:
        filePath = PureWindowsPath(file)
        fname = filePath.stem
        filePath = WindowsPath(file)
        cols = dict()
        with filePath.open() as f:
            dialect = csv.Sniffer().sniff(f.read(1024))
            f.seek(0)
            dataReader = csv.reader(f, dialect)
            rownum = 0
            for row in dataReader:
                rownum = rownum + 1
                if rownum == 1:
                    colNames = row
                    for col in colNames:
                        cols[col] = []
                else:
                    for i in range(len(row)):
                        cols[colNames[i]].append(row[i])
        allData[fname] = cols




# , "-data")


# htmDF = pd.read_csv('./HitsTimeMoney.csv')
# htmDF.head(n = 5)



# import pandas as pd
# from pyspark.mllib.clustering import KMeans, KMeansModel
# from numpy import array
# from pyspark import SparkConf, SparkContext
# from pyspark.sql import SQLContext
# import sys
#
#
# htm = htmDF[['totalMoneySpent','totalTimeSpent','hitRatio', 'numTeams', 'aveStrength']]
# htm.shape
# sqlContext = SQLContext(sc)
# cxDF = sqlContext.createDataFrame(htm)
# parseData = cxDF.rdd.map(lambda line: array([line[0], line[1], line[2], line[3], line[4]])) #totalMoneySpent totalTimeSpent hitRatio numTeams
#
# htm_km = KMeans.train(parseData, 3, maxIterations=20, runs=20, initializationMode="random")
#
# print(htm_km.centers)
