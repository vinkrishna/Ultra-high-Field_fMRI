
#STEP 0: Intensity normalization in SPM : Bias correction
SPM - Segment
Select the option- Save bias corrected.
# two way bias correction seems better. This means output of the first correction, will become input for the later.


#Distortion correction: http://www.fmrib.ox.ac.uk/primers/intro_primer/ExBox20/IntroBox20.html 
cd /home/meng/Documents/ketamine/BIDS/Day1/sub-zr784901DK/topup

#STEP 1: Create acqparams.txt file
0 -1 0 0.0288753
0 1 0 0.0288753


#STEP 2: Extract volumes from AP-PA Phase encodings. 
echo "Creating one AP volume"
fslroi sub-zr784901DK_run-01_AP-j.nii.gz ap 0 1
echo "Creating one PA volume"
fslroi sub-zr784901DK_task-rest_acq-multiband_run-01_bold.nii.gz pa 0 1
fslmerge -t AP_PA.nii.gz ap.nii.gz pa.nii.gz


#STEP3: create AP-PA fieldcoefs
topup --imain=AP_PA --datain=acqparams.txt --config=b02b0.cnf --out=topup_AP_PA
#location of b02b0.cnf: /usr/share/fsl/5.0/etc/flirtsch


#STEP 4: apply on a single scan : PA here
applytopup --imain=ap,pa --topup=topup_AP_PA --datain=acqparams.txt --inindex=1,2 --out=hifi_nodif


#STEP 5: Check the quality of the distortion correction
echo "BET on T1"
bet struct.nii struct_brain.nii.gz
echo "registering EPI to the T1 space"
epi_reg --epi=hifi_nodif.nii.gz --t1=struct.nii.gz --t1brain=struct_brain.nii.gz --out=diff2struct
fslview struct.nii.gz diff2struct.nii.gz diff2struct_fast_wmedge.nii.gz


# STEP6: apply on the RS_01 4D scans
applytopup --imain=sub-zr784901DK_task-rest_acq-multiband_run-01_bold.nii.gz --topup=topup_AP_PA --datain=acqparams.txt --inindex=2 --out=rs_01_topup












§EXTRA
Guide for freesurfer:
https://surfer.nmr.mgh.harvard.edu/fswiki/HighFieldRecon

recon-all -i $result_dir/$i/T1.nii -all -sd /users/ClusterUser/vkumar/col/T1/Freesurfer -s $i 
#-openmp 8 : to use all the cores. 
https://github.com/vinkrishna/Freesurfer_scripts/blob/master/run_freesurfer_t1.sh