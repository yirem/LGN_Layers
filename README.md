# LGN_layers

The processed data and codes for: 

Yildirim, I., Hekmatyar, K., & Schneider, K. A. (under revision). Evaluating quantitative and functional MRI as potential techniques to identify the layers in the human lateral geniculate nucleus. Invited resubmission to NeuroImage in July, 2022.

The raw nifti data for these analysis will be available at THIS LINK.

data: 	
	The processed nifti files (aligned to the regular T1w of each S)
	To be used by the MATLAB codes (the files that were masked for each LGN)

	fMRI:	
		The eye-specific visual stimulation viewed in a MONOCULAR or DICHOPTIC fashion
		The GLM results (i.e., t stat) for Left Eye (LE) and Right Eye (RE) separately and contrasted against each other for each condition
		The LGN masks that were functionally adjusted based on Visual Hemifield Stimulation fMRI data
		The LGN masks that are showing voxels with significant ocular preference when the data from both tasks were combined in a higher-level GLM

	qT1:	
		T1 maps
		The LGN masks manually outlined from the upsampled average T1 map (see FSLcodes in qMRI folder)


	T1:	
		Regular T1-weighted image of the S that was used as the standard brain for the S

qMRI:
	FSLcodes*: To process raw qMRI data on bash
	i_MATLABcodes: 2-component Gaussian model and the fraction of M voxels calculated
	ii_MATLABcodes: AIC/BIC compared for the 1- vs 2-component Gaussian models
	iii_MATLABcodes: Random subsampling of the T1 maps to apply the same analysis in i_MATLABcodes
	iv_MATLABcodes: Graphs showing the proportion of M identified by the random subsamples 

fMRI:
	i_MATLABcodes: The GLM results (i.e., t stat) for Left Eye (LE) vs Right Eye (RE) contrast were used to calculate the ocular preference of the LGN voxels and stored together
	ii_MATLABcodes: Correlations in the ocular preference values for monocular and dichoptic conditions (with scatterplots) and Chi-square comparison of variance for the classification of the voxels with the two tasks


*In the original qMRI analysis, the images were not defaced as in the raw data. This is due to many scans being aligned. Alignments were much better with the whole images that were not skull stripped. However, because of ethical procedures, we shared the defaced raw images.
