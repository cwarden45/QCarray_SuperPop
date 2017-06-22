set.seed(0)

#tryCatch(library(reshape), error=function(e){install.packages("reshape")})
library(reshape)

param.table = read.table("parameters.txt", header=T, sep="\t")
test.meta.file=as.character(param.table$Value[param.table$Parameter == "test_sample_description"]) 
combined.meta.file=as.character(param.table$Value[param.table$Parameter == "combined_sample_description"]) 
combined.vcf=as.character(param.table$Value[param.table$Parameter == "Combined_VCF"])
allele.count.table=as.character(param.table$Value[param.table$Parameter == "Combined_Allele_Counts"])
plink.prefix=as.character(param.table$Value[param.table$Parameter == "Combined_Prefix"])
reference.ped=as.character(param.table$Value[param.table$Parameter == "Reference_PED"])
pop2superpop.file=as.character(param.table$Value[param.table$Parameter == "SuperPop_Mapping"])

geno2count = function(vcf.geno){
	if(vcf.geno == "1/1"){
		return(2)
	}else if((vcf.geno == "1/0") | (vcf.geno == "0/1")){
		return(1)
	}else if(vcf.geno == "0/0"){
		return(0)
	}else{
		return(NA)
	}
}#end geno2count

allele.count = function(vcf.arr){
	return(sapply(vcf.arr, geno2count))
}#end def allele.count

gnum2gchar = function(value, ref, alt){
	allele1 = substr(value,1,1)
	allele2 = substr(value,3,3)
	geno.arr = c(allele1,allele2)

	geno.arr = gsub("0",ref,geno.arr)
	geno.arr = gsub("1",alt,geno.arr)
	geno.arr = gsub("\\.","0",geno.arr)

	return(paste(geno.arr,collapse="\t"))
}#end gnum2gchar

vcf2lgen = function(ann.arr, famID, subID){
	snpID = ann.arr[1]
	ref = ann.arr[2]
	var = ann.arr[3]
	geno.arr = ann.arr[4:length(ann.arr)]
	if((length(geno.arr) == length(famID)) & (length(famID) == length(subID))){
		geno.arr = sapply(geno.arr, gnum2gchar, ref=ref, alt=var)
		names(geno.arr) = paste(famID,subID,snpID,sep="\t")
		return(geno.arr)
	}else{
		print("Problem with annotation lengths")
		print(geno.arr)[1:10]
		print(famID)[1:10]
		print(subID)[1:10]
		print(snpID)
		print("Problem with annotation lengths")
		stop()
	}
}#end def vcf2lgen

pop2superpop=function(char, superpop.map){
	return(as.character(superpop.map$Super.Pop.Code[superpop.map$Pop.Code==char]))
}#end def pop2superpop

vcf.table = read.table(combined.vcf,sep="\t", head=T)
vcfIDs = names(vcf.table)[10:ncol(vcf.table)]

#assumes X is added at beginning due to sample ID starting with a number
xstart = vcfIDs[grep("^X",vcfIDs)]
if (length(xstart) > 0){
	print("Samples starting with 'X' identified:")
	print(paste(vcfIDs[grep("^X",vcfIDs)],collapse=","))
	print("R will add 'X' at the beginning of samples starting with numeric values")
	print("Checking with user if correct sample names were used...")
	userAns = readline(prompt="Please enter 'sub' if you would like to substitute 'S' for 'X' at the beginning of the sample ID ('sub'/'no'): ")
	userAns = tolower(userAns)
	if (userAns != "sub"){
		vcfIDs = gsub("^X","S",vcfIDs)
		print("New Sample Names (.vcf): ")
		print(vcfIDs)
	} else {
		#automatically does this if running via Rscript
		print("OK - leaving sample names alone")
	}#end else
}#end if (length(xstart) > 0)

ref.meta.table = read.table(reference.ped, sep="\t", head=T)
ref.fam = data.frame(Family.ID=as.character(ref.meta.table$Family.ID),
					Individual.ID=as.character(ref.meta.table$Individual.ID),
					Paternal.ID=as.character(ref.meta.table$Paternal.ID),
					Maternal.ID=as.character(ref.meta.table$Maternal.ID),
					Gender=as.character(ref.meta.table$Gender),
					Phenotype=as.character(ref.meta.table$Phenotype))					
ethnicity = as.character(ref.meta.table$Population)
					
super.meta = read.table(pop2superpop.file, head=T, sep="\t")
super.pop.val = sapply(ethnicity, pop2superpop, superpop.map=super.meta)
print(super.pop.val)

refIDs = as.character(ref.meta.table$Individual.ID)
										
test.table = read.table(test.meta.file, sep="\t", head=T)
print(dim(test.table))
test.samples = gsub("_",".",test.table$SampleID)
test.samples = gsub("-",".",test.samples)

if(exists("userAns")){
	if (userAns != "sub"){
		test.samples[grep("^\\d",test.samples)]=paste("S",test.samples[grep("^\\d",test.samples)],sep="")
		print("New Sample Names (changed numeric provided names): ")
		print(test.samples)
	}
}#if sample IDs started with numbers, add "S" to beginning of sample names (if done at earlier step)

test.sample.check=vcfIDs[match(test.samples,vcfIDs,nomatch=0)]
if(length(test.sample.check) != length(test.samples)){
	print("There are some unmatched test samples:")
	print(test.samples[-match(test.sample.check,test.samples,nomatch=0)])
	stop()
}#end if(length(test.sample.check) != length(test.samples))

#assumes test samples are unrelated - you can manually update this table after creation if you have other plink functions you would like to test
test.fam = data.frame(paste("unrelated",1:nrow(test.table),sep=""),
						as.character(test.samples),
						rep("0",nrow(test.table)),
						rep("0",nrow(test.table)),
						rep("0",nrow(test.table)),
						rep("0",nrow(test.table)))
names(test.fam) = names(ref.fam)

print(dim(ref.fam))
combined.fam = rbind(ref.fam, test.fam)
print(dim(combined.fam))
write.table(combined.fam,paste(plink.prefix,".fam",sep=""),
			sep="\t", quote=F, row.names=F, col.names=F)

ethnicity = c(ethnicity,rep(NA,length(test.samples)))
super.pop.val = c(super.pop.val,rep(NA,length(test.samples)))
combined.meta.table = data.frame(subject = combined.fam[,2],
									ethnicity=ethnicity,
									super.pop=super.pop.val)
write.table(combined.meta.table,combined.meta.file,
				quote=F, sep="\t", row.names=F)
				
#also create .pop file for ADMIXTURE
combined.meta.table$super.pop=as.character(combined.meta.table$super.pop)
combined.meta.table$super.pop[is.na(combined.meta.table$super.pop)]="-"
write.table(data.frame(pop=combined.meta.table$super.pop),
				paste(plink.prefix,".pop",sep=""),
				row.names=F, col.names=F, quote=F)

combined.map = data.frame(chr=vcf.table$CHROM, ID=vcf.table$ID, rep(0,nrow(vcf.table)), pos = vcf.table$POS)
write.table(combined.map,paste(plink.prefix,".map",sep=""),
				sep="\t", quote=F, row.names=F, col.names=F)

orderedIDs = c(vcfIDs, test.samples)

ordered.famID = as.character(combined.fam$Family.ID[match(orderedIDs, combined.fam$Individual.ID)])
ordered.subID = as.character(combined.fam$Individual.ID[match(orderedIDs, combined.fam$Individual.ID)])

geno.mat = vcf.table[,10:ncol(vcf.table)]
names(geno.mat) = vcfIDs
geno.mat = geno.mat[,match(orderedIDs, names(geno.mat))]
rownames(geno.mat) = vcf.table$ID

lgen.in.mat = data.frame(ID = vcf.table$ID, ref=vcf.table$REF, var=vcf.table$ALT, geno.mat)

print("extra count mat for custom analysis")
count.mat = apply(geno.mat, 2, allele.count)
count.mat = data.frame(ID = vcf.table$ID,count.mat)
write.table(count.mat,allele.count.table, sep="\t", quote=F, row.names=F)

print("creating lgen file")
lgen.arr = apply(lgen.in.mat, 1, vcf2lgen,
						famID=ordered.famID,
						subID=ordered.subID)
rownames(lgen.arr) = paste(ordered.famID,ordered.subID,sep="\t")
lgen.mat = melt(lgen.arr)
write.table(lgen.mat,paste(plink.prefix,".lgen",sep=""),
			sep="\t", quote=F, row.names=F, col.names=F)


