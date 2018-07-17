#MOLGENIS nodes=1 ppn=8 mem=18gb walltime=16:00:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string referenceGenomeHisat
#string reads1FqGz
#string reads2FqGz
#string platform
#string alignmentDir
#string hisatVersion
#string uniqueID
#string samtoolsVersion
#string rnaStrandness


if [ ${#reads2FqGz} -eq 0 ]; then
   input="-U ${reads1FqGz}"
   echo "Single end alignment of ${reads1FqGz}"
   if [[ ! -f ${reads1FqGz} ]] ; then
     echo "${reads1FqGz} does not exist"
     exit 1
   fi
   if [ "${rnaStrandness}" == "FR" ]; then
       rnaStrandness="F"
   elif [ "${rnaStrandness}" == "RF" ]; then
       rnaStrandness="R"
   fi
else
   input="-1 ${reads1FqGz} -2 ${reads2FqGz}"
   if [ "${rnaStrandness}" == "F" ]; then
       rnaStrandness="FR"
   elif [ "${rnaStrandness}" == "R" ]; then
       rnaStrandness="RF"
   fi
   echo "Paired end alignment of ${reads1FqGz} and ${reads2FqGz}"
   if [[ ! -f ${reads1FqGz} ]] ; then
      echo "${reads1FqGz} does not exist"
      exit 1
   fi
fi

#Load modules
${stage} hisat/${hisatVersion}

#check modules
${checkStage}

mkdir -p ${alignmentDir}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"
echo "Using RNA strandedness $rnaStrandness"
if [ "$rnaStrandness" == "unstranded" ]; then
    rnaStrandOption=""
else
    rnaStrandOption="--rna-strandness $rnaStrandness"
fi


if hisat -x ${referenceGenomeHisat} \
  ${input} \
  -p 8 \
  --rg-id ${internalId} \
  --rg PL:${platform} \
  --rg PU:${sampleName}_${internalId}_${internalId} \
  --rg LB:${sampleName}_${internalId} \
  --rg SM:${sampleName} \
  -S ${alignmentDir}${uniqueID}.sam $rnaStrandOption
then
 echo "returncode: $?";
  echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi


if [ ! -f ${alignmentDir}${uniqueID}.sam ]; then
    echo "${alignmentDir}${uniqueID}.sam"
    exit 1
fi

echo "## "$(date)" ##  $0 Done "
