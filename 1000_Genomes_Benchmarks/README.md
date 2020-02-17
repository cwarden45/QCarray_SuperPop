Please note that the code is written as if it was part of the "[Extra_Analysis](https://github.com/cwarden45/HPV_type_paper-archived_samples/tree/master/Downstream_R_Code/Extra_Analysis)" subfolder on the L1 Amplicon-Sequencing GitHub page.  For example, this would be similar to the "[Ancestry_Analysis](https://github.com/cwarden45/HPV_type_paper-archived_samples/tree/master/Downstream_R_Code/Extra_Analysis/Ancestry_Analysis)" subfolder on that page.

Lower Call Rate (<95%) Validation of Super-Populations for 1000 Genomes Samples
-----------------

The bootstrap simulation tended to assign more samples to each group compared to ADMIXTURE (configured to assign super-populations based on contributions greater than 50% or 80%). The bootstrap simulation also showed a potential advantage in recovering AMR assignments in the validation set: 

### Bootstrap Simulation (>95% Confidence, 98.4% Match Overall, 89.8% Match AMR, 915 / 924 assignments)

<table>
  <tbody>
    <tr>
	<th align="center"></th>
	<th align="center">1KG-AFR</th>
  <th align="center">1KG-AMR</th>
  <th align="center">1KG-EAS</th>
  <th align="center">1KG-EUR</th>
  <th align="center">1KG-SAS</th>
    </tr>
    <tr>
	<td align="center"><b>Predicted-AFR</b></td>
	<td align="center"><b>181</b></td>
	<td align="center"><i>2</i></td>
	<td align="center">0</td>
	<td align="center">0</td>
	<td align="center">0</td>
    </tr>
    <tr>
	<td align="center"><b>Predicted-AMR</b></td>
	<td align="center">0</td>
	<td align="center"><b>132</b></td>
	<td align="center">0</td>
	<td align="center">0</td>
	<td align="center">0</td>
    </tr>
    <tr>
	<td align="center"><b>Predicted-EAS</b></td>
	<td align="center">0</td>
	<td align="center">0</td>
	<td align="center"><b>267</b></td>
	<td align="center">0</td>
	<td align="center">0</td>
    </tr>
    <tr>
	<td align="center"><b>Predicted-EUR</b></td>
	<td align="center">0</td>
	<td align="center"><i>13</i></td>
	<td align="center">0</td>
	<td align="center"><b>283</b></td>
	<td align="center">0</td>
    </tr>
    <tr>
	<td align="center"><b>Predicted-SAS</b></td>
	<td align="center">0</td>
	<td align="center">0</td>
	<td align="center">0</td>
	 <td align="center">0</td>
	<td align="center"><b>37</b></td>
    </tr>
</tbody>
</table>

### ADMIXTURE (>80% Proportion, 99.4% Match Overall, 93.2% Match AMR, 813 / 924 assignments)


<table>
  <tbody>
    <tr>
	<th align="center"></th>
	<th align="center">1KG-AFR</th>
  <th align="center">1KG-AMR</th>
  <th align="center">1KG-EAS</th>
  <th align="center">1KG-EUR</th>
  <th align="center">1KG-SAS</th>
    </tr>
    <tr>
	<td align="center"><b>Predicted-AFR</b></td>
	<td align="center"><b>166</b></td>
	<td align="center">0</td>
	<td align="center">0</td>
	<td align="center">0</td>
	<td align="center">0</td>
    </tr>
    <tr>
	<td align="center"><b>Predicted-AMR</b></td>
	<td align="center">0</td>
	<td align="center"><b>68</b></td>
	<td align="center">0</td>
	<td align="center">0</td>
	<td align="center">0</td>
    </tr>
    <tr>
	<td align="center"><b>Predicted-EAS</b></td>
	<td align="center">0</td>
	<td align="center">0</td>
	<td align="center"><b>266</b></td>
	<td align="center">0</td>
	<td align="center">0</td>
    </tr>
    <tr>
	<td align="center"><b>Predicted-EUR</b></td>
	<td align="center">0</td>
	<td align="center"><i>5</i></td>
	<td align="center">0</td>
	<td align="center"><b>274</b></td>
	<td align="center">0</td>
    </tr>
    <tr>
	<td align="center"><b>Predicted-SAS</b></td>
	<td align="center">0</td>
	<td align="center">0</td>
	<td align="center">0</td>
	 <td align="center">0</td>
	<td align="center"><b>34</b></td>
    </tr>
</tbody>
</table>

### ADMIXTURE (>50% Proportion, 95.6% Match Overall, 70.1% Match AMR, 902 / 924 assignments)

<table>
  <tbody>
    <tr>
	<th align="center"></th>
	<th align="center">1KG-AFR</th>
  	<th align="center">1KG-AMR</th>
 	 <th align="center">1KG-EAS</th>
 	 <th align="center">1KG-EUR</th>
 	 <th align="center">1KG-SAS</th>
    </tr>
    <tr>
	<td align="center"><b>Predicted-AFR</b></td>
	<td align="center"><b>181</b></td>
	<td align="center"><i>2</i></td>
	<td align="center">0</td>
	<td align="center">0</td>
	<td align="center">0</td>
    </tr>
    <tr>
	<td align="center"><b>Predicted-AMR</b></td>
	<td align="center">0</td>
	<td align="center"><b>94</b></td>
	<td align="center">0</td>
	<td align="center">0</td>
	<td align="center">0</td>
    </tr>
    <tr>
	<td align="center"><b>Predicted-EAS</b></td>
	<td align="center">0</td>
	<td align="center">0</td>
	<td align="center"><b>267</b></td>
	<td align="center">0</td>
	<td align="center">0</td>
    </tr>
    <tr>
	<td align="center"><b>Predicted-EUR</b></td>
	<td align="center">0</td>
	<td align="center"><i>38</i></td>
	<td align="center">0</td>
	<td align="center"><b>283</b></td>
	<td align="center">0</td>
    </tr>
    <tr>
	<td align="center"><b>Predicted-SAS</b></td>
	<td align="center">0</td>
	<td align="center">0</td>
	<td align="center">0</td>
	 <td align="center">0</td>
	<td align="center"><b>37</b></td>
    </tr>
</tbody>
</table>

1KG = 1000 Genomes ethnicity assignment. Only QC-array matched probes used for assignments.

**Also, please notice that this is different than the two ADMIXTURE proportions reported in the HPV L1 Amplicon-Sequencing paper (80% and 50%, versus 80% and 20%).**  The reason is that these are supposed to be relatively homogenous populations, while we can encounter individuals with more mixed ancestry in the patient population.

Lower Call Rate (<95%) Validation of Admixed American (AMR) Populations for 1000 Genomes Samples
-----------------

Using an additional set of 1000 Genomes samples (n=156), we tested the ability of ADMIXTURE and the bootstrap simulation to assign Colombian (CLM, n=45), Mexican from Los Angeles (MXL, n=33), Peruvian (PEL, n=43), and Puerto Rican (PUR, n=35) populations to the AMR group.  The accuracy varied between populations:

### Bootstrap Simulation (>95% Confidence, 147 / 156 assignments)

### ADMIXTURE (>80% Proportion, 73 / 156 assignments)

### ADMIXTURE (>50% Proportion, 134 / 156 assignments)


1KG = 1000 Genomes ethnicity assignment. Match = concordance defined at super-population level.  Only QC-array matched probes used for assignments.

**Also, please notice that this is different than the two ADMIXTURE proportions reported in the HPV L1 Amplicon-Sequencing paper (80% and 50%, versus 80% and 20%).**  The reason is that these are supposed to be relatively homogenous populations, while we can encounter individuals with more mixed ancestry in the patient population.
