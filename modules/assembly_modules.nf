process METASPADES {                                                              
                                                                                
conda 'bioconda::spades'                                                        
                                                                                
publishDir "${params.bn}/assembly", mode: 'copy', pattern: '*.assembly'      
                                                                                
input:                                                                          
tuple val (SampleID), val(X1) , val(X2)
val (R1)                                 
val (R2)                                  
                                                                                
output:                                                                         
file("${SampleID}.assembly/contigs.fasta")                              
path("${SampleID}.assembly")
                                                                                
script:                                                                         
"""                                                                             
metaspades.py -1 ${R1} -2 ${R2} -o ${SampleID}.assembly -t ${params.THREADS} > spades.log
"""                                                                             
}                                                                               


