# Setup executable variables
CLAIR3="/scratch/sb7580/HPMLProject/Clair3Proj/Clair3/clair3.py" # clair3.py
PYPY="python3"                                               # e.g. pypy3
PYTHON3="python3"                                            # e.g. python3
WHATSHAP="/ext3/miniconda3/bin/whatshap"                     # e.g. whatshap
PARALLEL="/share/apps/parallel/20201022/bin/parallel"        # e.g. parallel
SAMTOOLS="/share/apps/samtools/1.14/intel/bin/samtools"      # e.g. samtools

# Input parameters
PLATFORM="10xg"                         # e.g. {ont, hifi, ilmn}
UNIFIED_VCF_FILE_PATH="/scratch/sb7580/Data/HG002/GRCh38/UnificationOP/unified.vcf.gz"       # e.g. hg002.unified.vcf.gz
ALL_BAM_FILE_PATH="/scratch/sb7580/Data/HG002/GRCh38/NA24385_GRCh38.bam"           # e.g. hg002.bam
DEPTHS="1000"                  # e.g. 1000 (means no subsample)
ALL_REFERENCE_FILE_PATH="/scratch/sb7580/Data/HG002/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fasta"   # e.g. hg002.fasta
ALL_BED_FILE_PATH="/scratch/sb7580/Data/HG002/GRCh38/HG002_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed"           # e.g. hg002.bed
ALL_SAMPLE="HG002"                    # e.g. hg002
OUTPUT_DIR="/scratch/sb7580/Data/HG002/GRCh38/PreppedData"                   # e.g. output_folder

# Each line represent one input BAM with a matched coverage in the "DEPTH" array
## check the "Training data subsamping" section on how to apply BAM subsampling
ALL_BAM_FILE_PATH=('/scratch/sb7580/Data/HG002/GRCh38/NA24385_GRCh38.bam')

# Each line represents subsample ration to each sample, 1000 if no subsampling applies
DEPTHS=(1000)

# Each line represents one input sample name
ALL_SAMPLE=('HG002')

# Each line represents the reference file of each sample
ALL_REFERENCE_FILE_PATH=('/scratch/sb7580/Data/HG002/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fasta')

# Each line represents one BED region file for each sample
ALL_BED_FILE_PATH=('/scratch/sb7580/Data/HG002/GRCh38/HG002_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed')

# Each line represents one representation-unified VCF file for each sample
UNIFIED_VCF_FILE_PATH=('/scratch/sb7580/Data/HG002/GRCh38/UnificationOP/unified.vcf.gz')

# Chromosome prefix ("chr" if chromosome names have the "chr" prefix)
CHR_PREFIX="chr"

# array of chromosomes (do not include tge "chr" prefix) to train in all sample
## pls note that in the pretrained Clair3 models, we have excluded chr20 as a hold-out set.
CHR=(21 22)

# Number of threads to be used
THREADS=8

# Number of chucnks to be divided into for parallel processing
chunk_num=15
CHUNK_LIST=`seq 1 ${chunk_num}`

# The number of chucks to be divided for bin file generation for parallel processing
bin_chunk_num=1
BIN_CHUNK_LIST=`seq 1 ${bin_chunk_num}`

# Minimum SNP and INDEL AF required for a candidate variant
MIN_SNP_AF=0.08
MIN_INDEL_AF=0.15

# Maximum non-variant ratio for pileup model training, for pileup model training, we use variant:non-variant = 1:5
MAXIMUM_NON_VARIANT_RATIO=5

# Temporary working directories
DATASET_FOLDER_PATH="${OUTPUT_DIR}/build"
TENSOR_CANDIDATE_PATH="${DATASET_FOLDER_PATH}/tensor_can"
BINS_FOLDER_PATH="${DATASET_FOLDER_PATH}/bins"
SPLIT_BED_PATH="${DATASET_FOLDER_PATH}/split_beds"
VAR_OUTPUT_PATH="${DATASET_FOLDER_PATH}/var"

mkdir -p ${DATASET_FOLDER_PATH}
mkdir -p ${TENSOR_CANDIDATE_PATH}
mkdir -p ${BINS_FOLDER_PATH}
mkdir -p ${SPLIT_BED_PATH}
mkdir -p ${VAR_OUTPUT_PATH}

MODEL_FOLDER_PATH="/scratch/sb7580/HPMLProject/Clair3Proj/train_hg002_v100"
mkdir -p ${MODEL_FOLDER_PATH}

cd ${MODEL_FOLDER_PATH}

# A single GPU is used for model training
export CUDA_VISIBLE_DEVICES="0,1,2,3"
${PYTHON3} ${CLAIR3} TrainGPU \
    --bin_fn ${BINS_FOLDER_PATH} \
    --ochk_prefix ${MODEL_FOLDER_PATH}/pileup \
    --pileup \
    --add_indel_length False \
    --random_validation \
    --platform ${PLATFORM} \
    --num_gpus 4