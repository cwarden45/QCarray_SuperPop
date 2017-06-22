import sys
import re
import os

parameterFile = "parameters.txt"

refVCF = ""
testGeno = ""
combinedVCF = ""

inHandle = open(parameterFile)
lines = inHandle.readlines()
			
for line in lines:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	lineInfo = line.split("\t")
	param = lineInfo[0]
	value = lineInfo[1]

	if param == "Reference_VCF":
		refVCF = value

	if param == "QCarray_Geno_Table":
		testGeno = value
		
	if param == "Combined_VCF":
		combinedVCF = value
		
if (refVCF == "") or (refVCF == "[required]"):
	print "Need to enter a value for 'Reference_VCF'!"
	sys.exit()
	
if (testGeno == "") or (testGeno == "[required]"):
	print "Need to enter a value for 'QCarray_Geno_Table'!"
	sys.exit()

if (combinedVCF == "") or (combinedVCF == "[required]"):
	print "Need to enter a value for 'Combined_VCF'!"
	sys.exit()
	
genoHash = {}

inHandle = open(testGeno)
line = inHandle.readline()

lineCount = 0
testIDs = ""
while line:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	lineCount +=1
	
	if lineCount == 1:
		line = re.sub("_",".",line)
		lineInfo = line.split("\t")
		snpID = lineInfo.pop(0)
		chr = lineInfo.pop(0)
		pos = lineInfo.pop(0)
		
		hashKey = chr + "\t" + pos
		testIDs = "\t".join(lineInfo)
	else:
		lineInfo = line.split("\t")
		snpID = lineInfo.pop(0)
		chr = re.sub("chr","",lineInfo.pop(0))
		if chr == "M":
			chr = "MT"
		pos = lineInfo.pop(0)
		
		hashKey = chr + "\t" + pos
		genoHash[hashKey] = snpID + "\t" + "\t".join(lineInfo)

	line = inHandle.readline()
	
inHandle.close()

outHandle = open(combinedVCF, "w")
inHandle = open(refVCF)

line = inHandle.readline()

skipCount = 0

while line:
	line = re.sub("\n","",line)
	line = re.sub("\r","",line)
	
	commentResult = re.search("^#",line)
	labelResult = re.search("^#CHROM",line)
	
	if commentResult:
		if labelResult:
			line = re.sub("^#CHROM","CHROM",line)
			text = line + "\t" + testIDs + "\n"
			outHandle.write(text)
		else:
			text = line + "\n"
			outHandle.write(text)
	else:
		lineInfo = line.split("\t")
		chr = lineInfo.pop(0)
		pos = lineInfo.pop(0)
		rsID = lineInfo.pop(0)
		ref = lineInfo.pop(0)
		var = lineInfo.pop(0)
		qual = lineInfo.pop(0)
		filter = lineInfo.pop(0)
		info = lineInfo.pop(0)
		format = lineInfo.pop(0)

		hashKey = chr + "\t" + pos
		if hashKey in genoHash:
			genoText = genoHash[hashKey]
			genoInfo = genoText.split("\t")
			qcID = genoInfo.pop(0)
			
			mixedFlag = 0
			for i in range(0,len(genoInfo)):
				geno = genoInfo[i]
				allele1 = geno[0]
				if allele1 == ref:
					allele1 = "0"
				elif allele1 == var:
					allele1 = "1"
				elif allele1 == "-":
					allele1 = "."
				else:
					allele1 = "."
					allele2 = "."
					mixedFlag = 1
					
				allele2 = geno[1]
				if allele2 != ".":
					if allele2 == ref:
						allele2 = "0"
					elif allele2 == var:
						allele2 = "1"
					elif allele2 == "-":
						allele2 = "."
					else:
						mixedFlag = 1
					
				genoInfo[i] = allele1 + "/" + allele2

			if mixedFlag == 0:
				genoText = "\t".join(genoInfo)
				text = chr + "\t" + pos + "\t" + qcID + "\t" + ref + "\t" + var + "\t" + qual + "\t" + filter + "\t" + info + "\t" + format + "\t" + "\t".join(lineInfo) + "\t" + genoText + "\n"
				outHandle.write(text)
			else:
				print "Skipping " + qcID + " since reference alleles don't match"
				skipCount +=1
		else:
			print "Skipping line because not found in QCarray samples (doesn't count towards inconsistent variant allele count)"
			print "To save time, it would probably be better to have a filtered reference..."
	line = inHandle.readline()
	
print str(skipCount) + " lines were skipped due to discrepancies with variant allele"