#!/bin/bash

#To align, average, upsample, and mask the qT1 maps using fsl commands in bash
#dir variable throughout this file should always point to the root folder of the raw data at THIS LINK.


dir=~/Desktop/LGN_Layers_Data
for s in {1..3}; do #each subject
sdir=${dir}/derivatives/MP2RAGEToolboxSPM/sub-0${s}

for q in {1..4}; do #each qMRI session 
qdir=${sdir}/ses-0${q}/anat

for r in {1..5}; do #there were 5 runs at most

#For S01, the fourth session’s first run was used as the reference image. 
#For the other two Ss, it was their first session's firt run
if [ $s -eq 1 ]; then
refq=4

#one map was not used for S1 to make use of 16 maps only for all Ss
#save it in a different folder
if [ $q -eq 1 ] && [ $r -eq 1 ]; then 
odir=$qdir
else
odir=$sdir
fi

else
refq=1
odir=$sdir
fi

if [ $q -eq $refq ]; then #start aligning from the second run if this is the session that the ref image is in
refr=2
else
refr=1
fi

#For S02, run1 of the fourth session had a different orientation of the brain so it is aligned separately.
if [ $s -eq 2 ] && [ $q -eq 4 ]; then
if [ $r -eq 1 ]; then
refr=1
else
refr=2
fi
fi

refi=${sdir}/ses-0${refq}/anat/sub-0${s}_ses-0${refq}_run-1_T1map.nii.gz
ini=${qdir}/sub-0${s}_ses-0${q}_run-${r}_T1map.nii.gz
outi=${odir}/qT1_ses-0${q}_${r}in1.nii.gz
outmat=${qdir}/sub-0${s}_ses-0${q}_run-${refr}_T1map_in1.mat
echo sub-0${s}_ses-0${q}_run-${refr}_T1map … Aligning to the first map of S

if [ $r -eq $refr ]; then #first, align one run from that session
flirt -in ${ini} -ref ${refi} -interp sinc -omat ${outmat} -out ${outi}
else #then, apply the transformation matrix to other runs in that session
flirt -in ${ini} -ref ${refi} -applyxfm -init ${outmat} -interp sinc -out ${outi}
fi
done
done

#sum the aligned qT1s (16 of them)

cd ${sdir}

#Each S has different number of sets for a session so we do the summation of the qT1 maps from each set separately below:

#For S01, the fourth session’s first set was used as the reference image. Set2 of the first session had a different orientation of the brain so it is not included in the dataset or in the analysis. The 16 images that were averaged were the sets 2-5 of the fourth session, sets 1-5 of the third session, sets 1-4 of the second session (set 5 had a technical problem thus missing - qT1 map couldn’t be calculated), and sets 3-5 of the first session (set 2 had a technical problem thus missing)
if [ $s -eq 1 ]; then
fslmaths qT1_ses-04_2in1 -add qT1_ses-04_3in1 -add qT1_ses-04_4in1 -add qT1_ses-04_5in1 -add qT1_ses-03_1in1 -add qT1_ses-03_2in1 -add qT1_ses-03_3in1 -add qT1_ses-03_4in1 -add qT1_ses-03_5in1 -add qT1_ses-02_1in1 -add qT1_ses-02_2in1 -add qT1_ses-02_3in1 -add qT1_ses-02_4in1 -add qT1_ses-01_3in1 -add qT1_ses-01_4in1 -add qT1_ses-01_5in1 qT1_all

# For S02, the 16 images that were averaged were the sets 2-5 of the first session, sets 1-5 of the second session, sets 1-2 of the third session, and sets 1-5 of the fourth session
elif [ $s -eq 2 ]; then
fslmaths qT1_ses-01_2in1 -add qT1_ses-01_3in1 -add qT1_ses-01_4in1 -add qT1_ses-01_5in1 -add qT1_ses-02_1in1 -add qT1_ses-02_2in1 -add qT1_ses-02_3in1 -add qT1_ses-02_4in1 -add qT1_ses-02_5in1 -add qT1_ses-03_1in1 -add qT1_ses-03_2in1 -add qT1_ses-04_1in1 -add qT1_ses-04_2in1 -add qT1_ses-04_3in1 -add qT1_ses-04_4in1 -add qT1_ses-04_5in1 qT1_all

# For S03, the 16 images that were averaged were the sets 2-3 of the first sessions, sets 1-5 of the second session, sets 1-5 of the third session, and sets 1-4 for the fourth session
elif [ $s -eq 3 ]; then
fslmaths qT1_ses-01_2in1 -add qT1_ses-01_3in1 -add qT1_ses-02_1in1 -add qT1_ses-02_2in1 -add qT1_ses-02_3in1 -add qT1_ses-02_4in1 -add qT1_ses-02_5in1 -add qT1_ses-03_1in1 -add qT1_ses-03_2in1 -add qT1_ses-03_3in1 -add qT1_ses-03_4in1 -add qT1_ses-03_5in1 -add qT1_ses-04_1in1 -add qT1_ses-04_2in1 -add  qT1_ses-04_3in1 -add qT1_ses-04_4in1 qT1_all
fi

#Average the sum qt1 map  
fslmaths qT1_all -div 16 qT1

#and upsample its resolution
echo sub-0${s} … Upsampling the average T1 map
flirt -in qT1 -ref qT1 -applyisoxfm 0.35 -interp sinc -out qT1_us

done

###########################################################################################

#THE LGN MASKS WERE CREATED MANUALLY USING QT1_US (AVERAGED UPSAMPLED QT1 MAP)

#These masks were named qT1_us_LGN_mask.nii.gz


#Align with the standard brain of each S and mask average qt1 

#The reference image (i.e., the standard brain of each S) to align was the T1-weighted image in the very first session the S came in which is the first Binocular Rivalry session

dir=~/Desktop/LGN_Layers_Data
for s in {1..3}; do
mdir=${dir}/sub-0${s}/anat
refi=${mdir}/sub-0${s}_T1w.nii.gz
sdir=${dir}/derivatives/MP2RAGEToolboxSPM/sub-0${s}
echo sub-0${s} … Aligning to the standard T1w of the S

#register upsampled average qT1 with the standard brain of the S
flirt -in ${sdir}/qT1_us -ref $refi -dof 6 -cost mutualinfo -searchcost mutualinfo -omat ${sdir}/qT1inT1.mat -out ${mdir}/qT1inT1
#register the LGN mask with the standard brain of the subject using the transformation matrix above
flirt -in ${sdir}/qT1_us_LGN_mask.nii.gz -ref $refi -applyxfm -init ${sdir}/qT1inT1.mat -out ${mdir}/mask_LGN.nii.gz

#split the LGN mask into right and left
fslmaths ${mdir}/mask_LGN.nii.gz -bin -roi 104 -1 -1 -1 -1 -1 -1 -1 ${mdir}/mask_rLGN.nii.gz
fslmaths ${mdir}/mask_LGN.nii.gz -sub ${mdir}/mask_rLGN.nii.gz ${mdir}/mask_lLGN.nii.gz


#THESE DATA FILES CAN BE FOUND IN THIS PACKAGE TO BE PROCESSED IN MATLAB (nifti data)
#mask the LGN in the average qT1 map
fslmaths ${mdir}/qT1inT1 -mas ${mdir}/mask_rLGN.nii.gz ${mdir}/qT1inT1_rLGN
fslmaths ${mdir}/qT1inT1 -mas ${mdir}/mask_lLGN.nii.gz ${mdir}/qT1inT1_lLGN
done

################ ALIGN AND MASK EACH QT1 MAP ######################################################

# To see how many qT1 maps are needed for a good performance in separating the M and P sections with the same analysis on the average qT1
#We need to align each map to the standard brain of each S

dir=~/Desktop/LGN_Layers_Data
for s in {1..3}; do
mdir=${dir}/sub-0{s}/anat
refi=${mdir}/sub-01_T1w.nii.gz
sdir=${dir}/derivatives/MP2RAGE-Toolbox/sub-0${s}

cd ${sdir}
#for each qT1 map used in the average qT1
i=0;
for q in *in1.nii.gz; do #the qT1s that were aligned to the first qT1 for each S
i=$[i+1] #count the map number
echo sub-0${s} T1 map $i … Upsampling and aligning with standard T1w of each S

#upsample first 
flirt -in $q -ref $q -applyisoxfm 0.35 -interp sinc -out US_${q}
#register with the standard brain of the subject, using the matrix from registering the upsampled average qT1 before
flirt -in US_${q} -ref $refi -applyxfm -init ${sdir}/qT1inT1.mat -out ${mdir}/qT1inT1_${i}

cd $mdir
#mask the LGN in each qT1 map
#THESE DATA FILES CAN BE FOUND IN THIS PACKAGE TO BE PROCESSED IN MATLAB (qT1_subsamples.mat data)
fslmaths qT1inT1_${i} -mas mask_rLGN.nii.gz qT1inT1_${i}_rLGN
fslmaths qT1inT1_${i} -mas mask_lLGN.nii.gz qT1inT1_${i}_lLGN
done
done