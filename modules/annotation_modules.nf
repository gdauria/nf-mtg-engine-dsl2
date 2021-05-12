process getDb {                                                                 
                                                                                
conda 'conda-forge::curl'                                                       
publishDir "${params.cacheDir}/DBs/", mode: 'copy', pattern: '{*}'                
                                                                                
input:                                                                          
tuple val(FILE), val(FILEOUT)                                           
                                     
output:                                                                         
file("${FILEOUT}")

                                                                                
script:                                                                         
"""                                                                             
curl --silent --insecure ${FILE} --output ${FILEOUT}
"""                                                                             
}                                                                               
     

process prokka {                                                                
                                                                                
conda "${projectDir}/envs/prokka.yml"                                           
                                                                                
publishDir "${BASENAME}/prokka", mode: 'copy', pattern: '{prokka_out/*}'        
                                                                                
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
 
