#!/usr/bin/env nextflow                                                         

//setting DSL2

nextflow.enable.dsl=2
                                                                                
DBFOLDER     = workflow.projectDir                                              
NEXTERAADAPT = "${DBFOLDER}/qcfolder/IlluminaAdaptors.fasta"                    
PHIX         = "${DBFOLDER}/qcfolder/phix.fasta"                                
THREADS      = params.THREADS                                                   
MANIFEST     = params.manifest                                                  
BASENAME     = params.bn                                                        
WORKFLOW     = workflow.workDir                                                 
                                                                                
WIN_SIZE     = params.WIN_SIZE                                                  
MEAN_QUAL    = params.MEAN_QUAL                                                 
MAX_LEN1     = params.MAX_LEN1                                                  
MAX_LEN2     = params.MAX_LEN2                                                  
                                                                                
evaluefun4   = params.evaluefun4                                                
minidenfun4  = params.minidenfun4                                               
blocksize    = params.blocksize                                                 
evaluehmmer5 = params.evaluehmmer5                                              
                                        
include {LIMPIA } from './modules/prepare_modules'
include {getDb as getDbKEGG; getDb as getDbEGGNOG; getDb as getDbPFAM} from './modules/annotation_modules'
include {CONCAT as CONCATR1; CONCAT as CONCATR2} from './modules/prepare_modules'
include {METASPADES} from './modules/assembly_modules'

println """                                                                    
METAGENOMICS = +                                                                
===================================                                             
System parameters:                                                              
- THREADS               : ${THREADS}                                            
- DBFOLDER              : ${DBFOLDER}                                           
- NEXTERAADAPT          : ${NEXTERAADAPT}                                       
- PHIX                  : ${PHIX}                                               
- THREADS               : ${THREADS}                                            
- PROJECTDIR            : $projectDir                                           
- WORKFLOW              : $WORKFLOW                                             
- CACHEDIR              : ${params.CACHEDIR}
                                                                                
Project parameters:                                                             
- BASENAME              : ${BASENAME}                                           
- MANIFEST              : ${MANIFEST}                                           
- MODE                  : $params.mode
- ASSEMBLER             : $params.assembler
                                                                                
QC Parameters                                                                   
- WIN_SIZE              : ${WIN_SIZE}                                           
- MEAN_QUAL             : ${MEAN_QUAL}                                          
- MAX_LEN1              : ${MAX_LEN1}                                           
- MAX_LEN2              : ${MAX_LEN2}                                           
                                                                                
Annotation                                                                      
- evaluefun4            : ${evaluefun4}                                         
- minidenfun4           : ${minidenfun4}                                        
- blocksize             : ${blocksize}                                          
- evaluefun5            : ${evaluehmmer5}                                       
                                                                                
         """.stripIndent() 



workflow {

  samples_channel = Channel                                                                     
    .fromPath( "$MANIFEST" )                                                    
    .splitCsv(header:true)                                                      
    .map { row -> tuple (row.SampleID,                                          
      file(row.R1),                                                           
      file(row.R2))}                                                          


  getDbKEGG(Channel
              .fromList(['https://atenea.fisabio.san.gva.es/syb/keggdb.dmnd', 'kegg.dmnd']))  
  getDbEGGNOG(Channel
              .fromList(['https://atenea.fisabio.san.gva.es/syb/eggnog.dmnd', 'eggnog.dmnd']))
  getDbPFAM ( 
    Channel
      .fromList([
         'https://atenea.fisabio.san.gva.es/syb/Pfam-A.hmm', 'Pfam-A.hmm'],[
         'https://atenea.fisabio.san.gva.es/syb/Pfam-A.hmm.dat', 'Pfam-A.hmm.dat']))


  LIMPIA(samples_channel) 

  if (params.mode == "CO"){
     CONCATR1(LIMPIA.out.fastq_R1.collect(), "R1")
     CONCATR2(LIMPIA.out.fastq_R2.collect(), "R2")
     if (params.assembler == "SPADES"){
        METASPADES("Coassembly", CONCATR1.out, CONCATR2.out)
     }

  } else {

      if (params.mode == "SEQ") {
         METASPADES(samples_channel, LIMPIA.out.fastq_R1, LIMPIA.out.fastq_R2)
      }

  }

}

