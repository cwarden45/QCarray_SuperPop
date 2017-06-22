library("png")

lrrBafFolder = "LRR_BAF"
RcallRate="R_call_rate.txt"
LRR_variation_file="LRR_SD_per_sample.txt"

param.table = read.table("parameters.txt", header=T, sep="\t")
meta.file=as.character(param.table$Value[param.table$Parameter == "test_sample_description"])
final.report=as.character(param.table$Value[param.table$Parameter == "GenomeStudio_FinalReport"])
geno.file=as.character(param.table$Value[param.table$Parameter == "QCarray_Geno_Table"])

dir.create(lrrBafFolder)

calc.call.rate = function(arr){
	return(100*length(arr[arr != "-"])/length(arr))
}#end calc.call.rate

meta.table = read.delim(meta.file, head=T, sep="\t")

report.table = read.table(final.report, skip=9,sep="\t", head=T)

snpID = unique(report.table$SNP.Name)
print(length(snpID))
snpChr = paste("chr",report.table$Chr,sep="")
snpChr = snpChr[match(snpID, report.table$SNP.Name)]
snpChr[snpChr == "chrMT"] = "chrM"
snpPos = report.table$Position
snpPos = snpPos[match(snpID, report.table$SNP.Name)]

geno.mat = data.frame(snpID,snpChr,snpPos)

sample.call.rate = tapply(report.table$Allele1...Plus, report.table$Sample.ID, calc.call.rate)			
call.rate.table = data.frame(SampleID = meta.table$SampleID[match(names(sample.call.rate),meta.table$SentrixBarcode_Position)],
							SentrixBarcode_Position=names(sample.call.rate),
							overall.call.rate = sample.call.rate)
call.rate.table = call.rate.table[match(meta.table$SentrixBarcode_Position, call.rate.table$SentrixBarcode_Position),]
							
labelColors =rep("black",nrow(meta.table))
labelColors[call.rate.table$overall.call.rate < 90]="orange"
labelColors[call.rate.table$overall.call.rate < 85]="brown"
labelColors2 =rep("gray",nrow(meta.table))
labelColors2[call.rate.table$overall.call.rate < 90]="orange"
labelColors2[call.rate.table$overall.call.rate < 85]="brown"

chrY.call.rate = c()
LRR.plots = c()
LRR.SD=c()

for (i in 1:nrow(meta.table)){
	sample.label = gsub("-",".",meta.table$SampleID)[i]
	sample.label = gsub("_",".",sample.label)
	print(sample.label)
	chipID = as.character(meta.table$SentrixBarcode_Position[i])
	
	patient.mat = report.table[as.character(report.table$Sample.ID) == chipID,]
	patient.mat = patient.mat[match(snpID, patient.mat$SNP.Name),]
	
	geno1 = patient.mat$Allele1...Plus
	geno2 = patient.mat$Allele2...Plus
	
	geno = paste(geno1,geno2,sep="")
	geno.mat = data.frame(geno.mat,geno)
	
	patient.mat = patient.mat[-grep("-",geno),]
	print(dim(patient.mat))
	
	LRR.SD[i]=sd(patient.mat$Log.R.Ratio,na.rm=T)
	
	lrr.baf.table = data.frame(patient.mat$SNP.Name, patient.mat$Log.R.Ratio, patient.mat$B.Allele.Freq)
	colnames(lrr.baf.table) = c("Name",paste(sample.label,".Log R Ratio",sep=""),paste(sample.label,".B Allele Freq",sep=""))
	lrr.baf.file = paste(lrrBafFolder,"/",sample.label,"_LRR_BAF.txt",sep="")
	write.table(lrr.baf.table, lrr.baf.file, sep="\t", quote=F, row.names=F)
	
	chrY.call.rate[i] = nrow(patient.mat[patient.mat$Chr == "Y",])
	
	ab.min =abs(min(patient.mat$Log.R.Ratio))
	thresh = max(ab.min, max(patient.mat$Log.R.Ratio))
	
	patient.mat = patient.mat[patient.mat$Chr != "XY",]
	
	chr.index = levels(as.factor(as.character(patient.mat$Chr)))
	chr.index[chr.index == "X"] = 23
	chr.index[chr.index == "Y"] = 24
	chr.index[chr.index == "MT"] = 25
	chr.index[chr.index == "0"] = 26
	chr.index = as.numeric(chr.index)
	
	chr.char = levels(as.factor(as.character(patient.mat$Chr)))
	chr.char = chr.char[order(chr.index)]
	patient.mat$Chr = factor(patient.mat$Chr, levels = chr.char)
	chr.char[chr.char == "0"] = "control"
	chr.char[chr.char == "MT"] = "M"
	chr.char = paste("chr",chr.char,sep="")
	
	sample.label = gsub("\\.","-",sample.label)
	
	LRR.plots[i] = paste(lrrBafFolder,"/",sample.label,"_LRR_per_chr.png",sep="")
	png(LRR.plots[i])
	plot(patient.mat$Chr, patient.mat$Log.R.Ratio, col=labelColors2[i],
		main=paste("LRR Distribution for ",sample.label,sep=""), las=2,
		ylim = c(-4,4), names=chr.char, cex.main=2)
	abline(h=0, col="black")
	dev.off()
}#end for (i in 1:nrow(meta.table))

write.table(data.frame(SampleID=meta.table$SampleID, LRR.SD=LRR.SD),
			LRR_variation_file, sep="\t", quote=F, row.names=F)

colnames(geno.mat) = c("snpID","chr","pos",gsub("-",".",meta.table$SampleID))
write.table(geno.mat, geno.file, sep="\t", quote=F, row.names=F)

### extra QC figures ###

probe.chr = report.table$Chr[match(snpID,report.table$SNP.Name)]
num.chrY.probes = length(snpID[probe.chr=="Y"])

png("chrY_call_rate.png")
par(mar=c(10,5,5,5))
barplot(names=meta.table$SampleID, chrY.call.rate, ylim=c(0,num.chrY.probes), las=2,
		ylab="Number of Called Probes", col=labelColors)
dev.off()

call.rate.table = data.frame(call.rate.table,
							chrY.call.rate=100 * chrY.call.rate / num.chrY.probes)
write.table(call.rate.table, RcallRate, quote=F, sep="\t", row.names=F)

sentrixIDs= gsub("_R\\d{2}C\\d{2}","",as.character(meta.table$SentrixBarcode_Position))
chipIDs = levels(as.factor(sentrixIDs))

for (chipID in chipIDs){
	pdf(paste(chipID,"LRR_per_sample_per_chr.pdf",sep="_"))
	
	chip.meta = meta.table[sentrixIDs == chipID,]
	chip.LRR = LRR.plots[sentrixIDs == chipID]
	par(mar=rep(0,4), mfrow=c(4,6))
	for(i in 1:nrow(chip.meta)){
		png.obj = readPNG(chip.LRR[i])
		plot(NA, xlim=0:1, ylim=0:1, xaxt="n",yaxt="n")
		rasterImage(png.obj, 0,0,1,1)
	}#end for(i in 1:nrow(meta.table))
	dev.off()
}#end def for (chipID in chipIDs)
