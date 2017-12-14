# QCarray Ethnicity Predictions

Code for Predicting Ethnicity from QCarray Samples

### Known-Ethnicity Set ###

1000 Genomes Omni2.5 SNP chip data (**ALL.chip.omni_broad_sanger_combined.20140818.snps.genotypes.vcf**) was downloaded from ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/supporting/hd_genotype_chip/

1000 Genomes pedigree (**20130606_g1k.ped**) file was downloaded from ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20130606_sample_info/20130606_g1k.ped

For convenience, a set of QCarray-matched probes for 50 unrelated individuals per [super-population](http://www.internationalgenome.org/category/population/) (`1KG_250_superpop.vcf`) will be uploaded with submission of the manuscript (along with pedigree `1KG_250_superpop.ped`, Super-Population mapping file `super_pop_code_mappings.txt`, and script to create these files `1KG_QCarray_ref_set.py`).

### Order to Run Scripts ###

Scripts use a parameter file (set as `parameters.txt` in code).  Please see below for description of parameters.

Most dependencies are available in this [Docker image](https://hub.docker.com/r/cwarden45/hpv-project/).

0) Genotypes need to be defined and exported from GenomeStudio.  Please add the following columns to the FinalReport: "Allele1 - Plus", "Allele2 - Plus", "Chr", "Position", "B Allele Freq", and "Log R Ratio" (the last two used for QC plots but not strictly needed for ethnicity assignments).  In GenomeStudio 2.0, Final Reports can be exported using **Analysis --> Reports --> Report Wizard**

The cluster file to define QCarray genotypes is available here: https://support.illumina.com/array/array_kits/infinium-qc-array-kit/downloads.html .

The .csv manifest file can also be downloaded from this location (used to extract matched Omni 2.5 probes for 1000 Genomes samples).  

For QC statistics, the Call Rate can also be exported (after being calculated, from "Samples Table"), but a call rate will also be calculated in `create_geno_mat.R`.

1) `create_geno_mat.R`  This function will also create a folder with BAF/LRR values (although those are for QC figures, and are not needed for ethnicity assignments).  Within an R session, you can run `source("create_geno_mat.R")`. Running `Rscript create_geno_mat.R` via command line should also do the trick (just make sure your sample names don't start with numbers, or be OK with automatically adding "S" to the sample name).

2) `python create_combined_vcf.py` Please note that you would need to comment the header to make standard format .vcf (the output is formatted for the next script in R)

3) `vcf_to_plink.R` Assumes reference already filtered for matched probes (while plink files only needed to compare ADMIXTURE assignments, this script also creates allele count table used for bootstrap assignments). As above, enter `source("vcf_to_plink.R")` or run `Rscript vcf_to_plink.R`.

4) Run `plink --lfile $Combined_Prefix --make-bed --out $Combined_Prefix --noweb` to create binary .bed file (fill in `$Combined_Prefix` with that is used in parameter file - probably `combined`)

5) Run `admixture $Combined_Prefix.bed 5 --supervised` to create .P and .Q ancestry output text files (fill in `$Combined_Prefix` with that is used in parameter file - probably `combined`.  Note .bed extension is needed this time (and K=5, since that is the number of 1000 Genomes super-populations).

6) `ADMIXTURE_assignments.R` As above, enter `source("ADMIXTURE_assignments.R")` or run `Rscript ADMIXTURE_assignments.R`.

Optional Extra Step (if you want to compare and/or require consistent ADMIXTURE supervised assignments):

S1) `bootstrap_full_distance.R`

As above, enter `source("bootstrap_full_distance.R")` or run `Rscript bootstrap_full_distance.R`.

### Dependencies ###

GenomeStudio: https://support.illumina.com/array/array_software/genomestudio/downloads.html

R: https://cran.r-project.org/

'reshape' R package: https://cran.r-project.org/package=reshape

'png' R package: https://cran.r-project.org/package=png

Can install using `install.packages(c('reshape','png'))` within R.  Already installed if running R within the [Docker image](https://hub.docker.com/r/cwarden45/hpv-project/).

plink: http://zzz.bwh.harvard.edu/plink/

ADMIXTURE: https://www.genetics.ucla.edu/software/admixture/

### Parameter Values ###
| Parameter | Value|
|---|---|
|GenomeStudio_FinalReport|Path to FinalReport from GenomeStudio|
|test_sample_description|Name of QC Array Sample Description File (to re-label samples with descriptive names: **SampleID** is the desired name, **SentrixBarcode_Position** is the ID in the FinalReport, which is the merging of "SentrixBarcode_A" and "SentrixPosition_A" with an underscore).  It is a set of "test" files in the sense that the 1000 Genomes samples have known ethnicities, and the code assumes the QC Array samples have unknown ethnicities.|
|combined_sample_description|Name of Combined Description File (`test_sample_description` table with added reference sample population information)|
|QCarray_Geno_Table|Matrix of alleles for QCarray Samples|
|Reference_VCF|VCF file for samples with known ethnicities (see **Known-Ethnicity Set** above)|
|Reference_PED|Reference plink-format pedigree (.ped) file|
|Combined_VCF|VCF File with matched probes for reference (known ethnicities, 1000 Genomes Omni 2.5) and test (unknown ethnicities, QC array) samples|
|Combined_Prefix|Prefix for other combined plink file names ([Combined_Prefix].fam, [Combined_Prefix].map, [Combined_Prefix].fam), [Combined_Prefix].lgen, [Combined_Prefix].pop)|
|Combined_Allele_Counts|Table with numeric counts (0, 1, or 2) for reference and test samples|
|SuperPop_Mapping|Tab-delimited text file mapping super-populations to populations (provided as `super_pop_code_mappings.txt`)|
|ADMIXTURE_Ethnicity_Assignments|Table of Ethnicity Assignments made using ADMIXTURE|
|ADMIXTURE_K|Value of K used when running ADMIXTURE (number of expected groups, K=5 for super-populations)|
|ADMIXTURE_Min_Prop|Minimum estimated proportion to report for ADMIXTURE mixed ethnicity|
|Bootstrap_Ethnicity_Assignments|Table of Ethnicity Assignments made using bootstrap confidence for allele counts|
