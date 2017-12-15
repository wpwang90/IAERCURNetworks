import arcpy
from arcpy.sa import *


#####################求出邻接矩阵#####################
inputPoint=r'C:\Users\woqie\Mac文档\研究\BU\河流公路铁路耦合系统\数据\pointXYValue.shp'

fieldObjList = arcpy.ListFields(inputPoint)

cursorsDepthid=arcpy.da.SearchCursor(inputPoint,fieldObjList[0].name)
nearFId=[];
for row1 in cursorsDepthid:
    nearFId.append(row1[0])
cursorsDepthid=arcpy.da.SearchCursor(inputPoint,fieldObjList[3].name)
nearXId=[];
for row1 in cursorsDepthid:
    nearXId.append(row1[0])

cursorsDepthid=arcpy.da.SearchCursor(inputPoint,fieldObjList[4].name)
nearYId=[];
for row1 in cursorsDepthid:
    nearYId.append(row1[0])
	
import csv
RandomTypeName='PearsonIII';
#RandomTypeName='Random';

#RunoffName='China';
RunoffName='Guangxi';

NameList='ChinaPro';
tempName='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
for totalIterRoff in range(9,20):
#csvfile = file("C:\\Users\\woqie\\Desktop\\test\\"+runoffName+"test2.csv", 'wb')
	csvfile = file('D:\\Csv\\'+NameList+RunoffName+RandomTypeName+tempName[totalIterRoff]+'.csv', 'wb')
	writer = csv.writer(csvfile)
	writer.writerow(nearFId)
	writer.writerow(nearXId)
	writer.writerow(nearYId)
	#runoffNumber=range(1,10)+[i*10 for i in range(1,31)]
	runoffNumber=[i*5 for i in range(2,59)]
	for k in range(len(runoffNumber)):
		inputRasterFile='D:\\径流数据设定\\'+NameList+'\\'+RunoffName+RandomTypeName+tempName[totalIterRoff]+'flddph'+str(runoffNumber[k])+'.tif';
		#inputRasterFile="C:\\Users\\woqie\\Mac文档\\研究\\BU\\河流公路铁路耦合系统\\数据\\fldRasterRes\\"+runoffName+"\\flddph"+runoffName+str(runoffNumber[k])+".tif"
		outRas=Raster(inputRasterFile)>5
		wwp=ExtractMultiValuesToPoints(inputPoint,outRas, "NONE")				   
		fieldObjList = arcpy.ListFields(inputPoint)
		cursorsDepthid=arcpy.da.SearchCursor(inputPoint,fieldObjList[5].name)
		nearId=[];
		for row1 in cursorsDepthid:
			nearId.append(row1[0])
		writer.writerow(nearId)
		arcpy.DeleteField_management(inputPoint, fieldObjList[5].name)
	csvfile.close()      
















#desc = arcpy.Describe(inputPoint)

# If the table has an OID, print the OID field name
#
#if desc.hasOID:
#    print("OIDFieldName: " + desc.OIDFieldName)

# Print the names and types of all the fields in the table
#
#for field in desc.fields:
#    print("%-22s %s %s" % (field.name, ":", field.type))
