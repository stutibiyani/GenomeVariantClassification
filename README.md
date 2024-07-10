# Optimization of Deep Learning models for Genomic Variant Calling on Distributed Environment with GPUs

## Description
Deoxyribonucleic acid (DNA) is the chemical compound that contains the instructions needed to develop and direct the activities of nearly all living organisms. Genome is an organism’s complete set of DNA. A human genome is approximately made up of 3 billion DNA base pairs. Genomics is the study of the genome including the interactions of genes with each other and the person’s environments[1]. However, there exists major computational bottlenecks and inefficiencies throughout the genome analysis pipeline. Variant identification and classification is an important task of genome analysis that gives doctors and scientists information about an organism's response to certain infections, drugs, and conditions they are gentically predisposed to. There have been variety of algorithms and tools developed to call generic and specific variants like GATK, Haplotype etc. However, these tools are extremely time consuming and ineficient when run in CPUs. This led to the rise of deep neural network based variant callers like DeepVariant from Google. These still have scope for improvement as training the models for good accuracy across different data requires training using multiple read aligned and variant called genomes with very large number of samples.
Our objective in this project is to optimize the variant classification process on current deep learning models to reduce the inefficiencies and computational bottlenecks. 

Deliverables from this project:
1. Analysed [Clairvoyante](https://www.nature.com/articles/s41467-019-09025-z) to identify the pitfalls and challenges in training the model. 
2. Analysed [Clair3](https://www.biorxiv.org/content/10.1101/2021.12.29.474431v2) and then used Data Parallelism to improve the performance of the model.

## Repository Structure

This repository is divided into three main folders:
* _**Clairvoyante**_: A CNN model using python2 and tensorflow 1. 
* _**Clair3GPU**_: An RNN model using python3, tensorflow 2 and 4 GPUs. (Implements Data Parallelism)
* _**Clair3CPU**_: An RNN model using python3 and tensorflow 2. (CPU version of Clair3GPU)

## Training Steps
### Clairvoyante

1. Data Preparation
```
wget 'http://www.bio8.cs.hku.hk/testingData.tar'
tar -xf testingData.tar
cd dataPrepScripts
sh PrepDataBeforeDemo.sh
```
2. Training the model <br>
Follow `jupyter_nb/demo.ipynb` 

### Clair3 (CPU and GPU)

1. Data Preparation
Data Sources <br>
[Clair3 Data: HG001 BAM](https://github.com/genome-in-a-bottle/giab_data_indexes/blob/master/NA12878/alignment.index.NA12878_10Xgenomics_ChromiumGenome_LongRanger2.1_GRCh37_GRCh38_09302016) <br>
[Clair3 Data: HG002 BAM](https://github.com/genome-in-a-bottle/giab_data_indexes/blob/master/AshkenazimTrio/alignment.index.AJtrio_10Xgenomics_ChromiumGenome_GRCh37_GRCh38_06202016.HG002)

```
cd dataPrepScripts
sh PrepDataBeforeDemo.sh
```
2. Training the model <br>
Execute `sbatch train_batch_hg001.sh` <br>
Please change the name of the file according to the read sample you want to use for training - `hg001` or `hg002`.

## Results
![HPML Final Project (1)](https://user-images.githubusercontent.com/35299590/208579346-ba79deb8-056f-4b04-8906-28bde030efbe.png)
![HPML Final Project (2)](https://user-images.githubusercontent.com/35299590/208579355-7cf4a600-2af1-4d90-8e44-d3d99bb488f4.png)
![HPML Final Project (3)](https://user-images.githubusercontent.com/35299590/208579357-d2d20655-ab55-427f-9cf6-88f03d753e06.png)
![HPML Final Project (4)](https://user-images.githubusercontent.com/35299590/208579362-96717996-310f-449b-bfeb-c834cab86ffc.png)
![HPML Final Project (5)](https://user-images.githubusercontent.com/35299590/208579568-a6b3c1dc-f6dc-498f-851b-73d2e4fdf9c2.png)

## Observations

### Clairvoyante
1. The model converged to a 92% validation accuracy after ~50 epochs. The convergence was not stable even with a very small learning rate, indicating that the model structure is succiptible to overfitting.
2. With an increase in learning rate and a scheduler to reduce the learning rate periodically, the model performace degraded massively and could not achieve an acceptable validation accuracy. 
3. The authors do mention a higher learning rate being a pitfall, but their claim suggests a breakdown in performace would happen a lot earlier than the results we got. 

### Clair3
1. After 30 epochs, model achieves a validation F1 score of 98% on CPU and 95% on 4 GPUs with DataParallel. 
2. Given the very large size of the data set, parallelizing the training across GPUs with by distributing data decreases the time per epoch by 50% and hence the execution time for 30 epochs is also halved.
3. Accuracy scales more slowly on GPUs with DataParallel than it does on CPUs. The time to reach 94% is approximately 1682 seconds on 4 GPUs while the same is 928.9 seconds on CPU despite the time per epoch being significantly lesser with DataParallel.
