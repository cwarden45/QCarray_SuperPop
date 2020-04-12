param.table = read.table("parameters.txt", header=T, sep="\t")
combined.meta.file=as.character(param.table$Value[param.table$Parameter == "combined_sample_description"]) 
plink.prefix=as.character(param.table$Value[param.table$Parameter == "Combined_Prefix"])
output.file=as.character(param.table$Value[param.table$Parameter == "ADMIXTURE_SuperPop_Assignments"]) 
K=as.numeric(as.character(param.table$Value[param.table$Parameter == "ADMIXTURE_K"]))
min.freq=as.numeric(as.character(param.table$Value[param.table$Parameter == "ADMIXTURE_Min_Prop"]))

mean.pop = function(arr, pop){
	return(tapply(arr,pop,mean))
}#end mean.pop

max.freq = function(arr, ids){
	assignments = as.character(ids[arr == max(arr)])
	if(length(assignments)==1){
		return(assignments)
	}else{
		return(paste(assignments, collapse=","))
	}
}#end max.freq

mixed.freq = function(arr, ids, cutoff){
	assignments = as.character(ids[arr > cutoff])
	if(length(assignments)==1){
		return(assignments)
	}else{
		return(paste(assignments, collapse=","))
	}
}#end max.freq

admixture.assignment.table = read.table(paste(plink.prefix,".",K,".Q",sep=""), head=F, sep=" ")
colnames(admixture.assignment.table)=rep("",ncol(admixture.assignment.table))

meta.table = read.table(combined.meta.file, head=T, sep="\t")
sample.order = read.table(paste(plink.prefix,".fam",sep=""), head=F, sep=" ")

pop.code = meta.table$super.pop[match(sample.order[,2],meta.table$subject)]
test.samples = sample.order[,2][is.na(pop.code)]
test.mat = admixture.assignment.table[is.na(pop.code),]
test.mat = round(test.mat, digits=2)
colnames(test.mat) = c("AFR","AMR","EAS","EUR","SAS")

#check if starting labels look OK
ref.assignment.table = admixture.assignment.table[!is.na(pop.code),]
ref.pop.code = meta.table$super.pop[!is.na(pop.code)]

ref.pop.freq = apply(ref.assignment.table, 2, mean.pop, pop = ref.pop.code)
print("Average Frequency per Column:")
print(ref.pop.freq)

expected.order = apply(ref.pop.freq, 2, max.freq, ids=rownames(ref.pop.freq))
if (paste(expected.order,collapse=",") != paste(colnames(test.mat),collapse=",")){
	print(paste("WARNING: It looks like order of ethnicities should be:",
				paste(expected.order,collapse=" ")))
	print("Using revised sample labeling - please revise code if you wish to use a different set of labels")
	colnames(test.mat) = expected.order
}
#colnames(test.mat) = c("AFR","AMR","EAS","EUR","SAS")

max.assignment = apply(test.mat, 1, max.freq, ids=colnames(test.mat))
mixed.assignment = apply(test.mat, 1, mixed.freq, ids=colnames(test.mat), cutoff = min.freq)

write.table(data.frame(sample=test.samples,
						test.mat,
						max.assignment, mixed.assignment),
			output.file,
			sep="\t", quote=F, row.names=F)
