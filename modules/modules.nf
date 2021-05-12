process LIMPIA {                                                                
                                                                                
conda 'bioconda::fastp'                                                         
                                                                                
publishDir "${params.bn}/cleaned", mode: 'copy', pattern: 'cleaned.*.fastq.gz'   
publishDir "${params.bn}/cleaned", mode: 'copy', pattern: 'fastp_report.*'       
echo true                                                                       
                                                                                
input:                                                                          
tuple val(SampleID), file(R1), file(R2)                            
                                                                                
output:                                                                         
path "cleaned.${SampleID}.R1.fastq.gz", emit: fastq_R1                                
path "cleaned.${SampleID}.R2.fastq.gz", emit: fastq_R2
file "fastp_report.*"                                                           
                                                                                
script:                                                                         
"""                                                                             
fastp -i $R1 -I $R2 -o cleaned.${SampleID}.R1.fastq.gz -O cleaned.${SampleID}.R2.fastq.gz --detect_adapter_for_pe --adapter_fasta ${workflow.projectDir}/qcfolder/IlluminaAdaptors.fasta --cut_tail --cut_window_size ${params.WIN_SIZE} --cut_mean_quality ${params.MEAN_QUAL} --thread ${params.THREADS} --json fastp_report.json --html fastp_report.html --report_title='fastp_report' > fastp.log
"""                                                                             
}

process getDb {                                                                 

conda 'conda-forge::wget'                                                       
publishDir "${params.cacheDir}/DBs/", mode: 'copy', pattern: '*'                  
        
input:
val(FILE)

output:

script:                                                                         
"""                                                                             
wget --no-check-certificate ${FILE}
"""                                                                             
}  


process  CONCAT {                                                              
                                                                                
publishDir "${params.bn}/concat", mode: 'copy', pattern: '{concat.*.fastq.gz}'  
                                                                                
echo true                                                                       
                                                                                
input:                                                                          
file "*"           
val(R1)                                        
                                                                                
output:                                                                         
file("concat.${R1}.fastq.gz")        
                                                                                
script:                                                                         
"""                                                                             
cat * > concat.${R1}.fastq.gz                                                      
"""                                                                             
}                                                                               


process METASPADES {                                                              
                                                                                
conda 'bioconda::spades'                                                        
                                                                                
publishDir "${params.bn}/assembly", mode: 'copy', pattern: '{mtg_assembly/contigs.fasta}'
publishDir "${params.bn}/assembly", mode: 'copy', pattern: '{mtg_assembly}'      
                                                                                
input:                                                                          
file ("concat.R1.fastq.gz")                                 
file ("concat.R2.fastq.gz")                                  
                                                                                
output:                                                                         
file("mtg_assembly/contigs.fasta")                              
                                                                                
script:                                                                         
"""                                                                             
metaspades.py -1 concat.R1.fastq.gz -2 concat.R2.fastq.gz -o mtg_assembly -t ${params.THREADS} > spades.log
"""                                                                             
}                                                                               

                                                                                
process prokka {                                                                
                                                                                
conda "${projectDir}/envs/prokka.yml"                                           
                                                                                
publishDir "${BASENAME}/prokka", mode: 'copy', pattern: '{prokka_out/*}'        
                                                                                
echo true                                                                       
                                                                                
input:                                                                          
file ("contigs.fasta") from spades_ch1                                          
                                                                                
output:                                                                         
file("prokka_out/${BASENAME}.faa") into prokka_ch_1                             
file("prokka_out/${BASENAME}.faa") into prokka_ch_2                             
file("prokka_out/${BASENAME}.gff") into prokka_ch_3                             
file("prokka_out/${BASENAME}.faa") into prokka_ch_4                             
file("prokka_out/*")                                                            
                                                                                
                                                                                
script:                                                                         
"""                                                                             
prokka contigs.fasta --outdir prokka_out --prefix ${BASENAME} > prokka.log      
"""                                                                             
}                                                                               
 
