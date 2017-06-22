set.seed(0)
mean.pop = function(arr, pop){
	return(tapply(arr,pop,mean, na.rm=T))
}

num.sim = 1000

param.table = read.table("parameters.txt", header=T, sep="\t")
combined.meta.file=as.character(param.table$Value[param.table$Parameter == "combined_sample_description"]) 
allele.count.table=as.character(param.table$Value[param.table$Parameter == "Combined_Allele_Counts"])
output.file=as.character(param.table$Value[param.table$Parameter == "Bootstrap_Ethnicity_Assignments"])

allele.mat = read.table(allele.count.table, head=T, sep="\t")
snpIDs = allele.mat[,1]

meta.table = read.table(combined.meta.file, head=T, sep="\t")
test.samples = as.character(meta.table$subject[is.na(meta.table$super.pop)])
ref.samples = as.character(meta.table$subject[!is.na(meta.table$super.pop)])
pop.code = as.character(meta.table$super.pop[!is.na(meta.table$super.pop)])

test.alleles = allele.mat[,match(test.samples, names(allele.mat))]
rownames(test.alleles) = snpIDs

ref.alleles = allele.mat[,match(ref.samples,names(allele.mat))]

ref.pop.freq = t(apply(ref.alleles, 1, mean.pop, pop = pop.code))

min.dist = c()
AFR.bootstrap = rep(0,ncol(test.alleles))
AMR.bootstrap = rep(0,ncol(test.alleles))
EAS.bootstrap = rep(0,ncol(test.alleles))
EUR.bootstrap = rep(0,ncol(test.alleles))
SAS.bootstrap = rep(0,ncol(test.alleles))

for (i in 1:ncol(test.alleles)){
	print(names(test.alleles)[i])
	sample.coordin = c(test.alleles[,i])
	sample.dist = as.matrix(dist(t(data.frame(test=sample.coordin, ref.pop.freq))))
	test.dist = min(sample.dist[2:nrow(sample.dist),1])
	min.dist[i] = rownames(sample.dist)[sample.dist[,1] == test.dist]
	
	for (j in 1:num.sim){
		bootstrap.index = sample(1:nrow(test.alleles), nrow(test.alleles), replace = T)
		temp.sample = test.alleles[bootstrap.index,i]
		temp.ref = ref.pop.freq[bootstrap.index,]

		sample.dist = as.matrix(dist(t(data.frame(test=temp.sample, temp.ref))))
		test.dist = min(sample.dist[2:nrow(sample.dist),1])
		boot.assignment = rownames(sample.dist)[sample.dist[,1] == test.dist]
		
		if (boot.assignment == "AFR"){
			AFR.bootstrap[i] = AFR.bootstrap[i] + 1
		}else if(boot.assignment == "AMR"){
			AMR.bootstrap[i] = AMR.bootstrap[i] + 1
		}else if(boot.assignment == "EAS"){
			EAS.bootstrap[i] = EAS.bootstrap[i] + 1
		}else if(boot.assignment == "EUR"){
			EUR.bootstrap[i] = EUR.bootstrap[i] + 1
		}else if(boot.assignment == "SAS"){
			SAS.bootstrap[i] = SAS.bootstrap[i] + 1
		}else{
			stop(paste("problem with assignment",boot.assignment))
		}
	}#end for (j in 1:num.sim)
}#end for (i in 1:length(test.samples))

AFR.bootstrap = 100 * AFR.bootstrap / num.sim
AMR.bootstrap = 100 * AMR.bootstrap / num.sim
EAS.bootstrap = 100 * EAS.bootstrap / num.sim
EUR.bootstrap = 100 * EUR.bootstrap / num.sim
SAS.bootstrap = 100 * SAS.bootstrap / num.sim

write.table(data.frame(sample=names(test.alleles), min.overall.dist = min.dist,
			AFR.bootstrap=AFR.bootstrap, AMR.bootstrap=AMR.bootstrap,
			EAS.bootstrap =EAS.bootstrap, EUR.bootstrap=EUR.bootstrap,
			SAS.bootstrap=SAS.bootstrap),
			output.file, sep="\t", row.names=F, quote=F)

