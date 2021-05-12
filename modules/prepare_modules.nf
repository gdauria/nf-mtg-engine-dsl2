process LIMPIA {                                                                
                                                                                
conda 'bioconda::fastp'                                                         
                                                                                
publishDir "${params.bn}/cleaned", mode: 'copy', pattern: 'cleaned.*.fastq.gz'   
publishDir "${params.bn}/cleaned", mode: 'copy', pattern: 'fastp_report.*'       
                                                                                
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


process  CONCAT {                                                              
                                                                                
publishDir "${params.bn}/concat", mode: 'copy', pattern: '{concat.*.fastq.gz}'  
                                                                                
input:                                                                          
file "*"           
val(R)                                        
                                                                                
output:                                                                         
file("concat.${R}.fastq.gz")        
                                                                                
script:                                                                         
"""                                                                             
cat * > concat.${R}.fastq.gz                                                      
"""                                                                             
}                                                                               


                                                                                

