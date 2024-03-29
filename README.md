# LGN_Layers

The processed data and codes for: 

Yildirim, I., Hekmatyar, K., & Schneider, K. A. (2022). Evaluating quantitative and functional MRI as potential techniques to identify the subdivisions in the human lateral geniculate nucleus. BioRxiv. https://doi.org/10.1101/2022.11.16.516765

Yildirim, I., Austin, A. J., & Schneider, K. A. (manuscript in prep). Segregating the eye-specific regions of the human lateral geniculate nucleus using non-negative matrix factorization.

The raw nifti data* for these analysis is available at https://openneuro.org/datasets/ds004187.

This repository contains folders:

	data: 	
		The processed nifti files (aligned to the regular T1w of each S and masked for each LGN)
		To be used by the MATLAB codes

		fMRI:	
			The eye-specific visual stimulation viewed in a MONOCULAR or DICHOPTIC fashion (ses-06 and ses-07 in raw data respectively)
			The GLM results (i.e., t stat) for Left Eye (LE) and Right Eye (RE) contrasted against each other for each condition
			The LGN masks that were functionally adjusted based on Visual Hemifield Stimulation fMRI data (ses-05 in raw data)
			The LGN masks that are showing voxels with significant ocular preference when the data from both tasks were combined in a higher-level GLM

		qT1:	
			Average T1 maps
			The LGN masks manually outlined from the upsampled average T1 map (see FSLcodes in qMRI folder)

	qMRI:
		FSLcodes*: To process raw qMRI data on bash
		i_MATLABcodes: 2-component Gaussian model and the fraction of M voxels calculated
		ii_MATLABcodes: AIC/BIC compared for the 1- vs 2-component Gaussian models
		qT1_subsamples.mat: data for iii_MATLABcodes, includes all the 16 individual T1 maps for each S's each LGN
		iii_MATLABcodes: Random subsampling of the T1 maps to apply the same analysis in i_MATLABcodes
		iv_MATLABcodes: Graphs showing the proportion of M identified by the random subsamples
		v_MATLABcodes: Graphs showing the classification accuracy for voxels being M or P with the subsamples vs the entire sample 

	fMRI:
		i_MATLABcodes: The GLM results (i.e., t stat) for Left Eye (LE) vs Right Eye (RE) contrast were used to calculate the ocular preference of the LGN voxels and stored together
		ii_MATLABcodes: Correlations in the ocular preference values for monocular and dichoptic conditions (with scatterplots) and Chi-square comparison of variance for the classification of the voxels with the two tasks
		j_MATLABcodes: The code for running orthonormal projective nonnegative matrix factorization (OPNMF) on the eye-specific fMRI data. The data is in the same folder in .mat version. The opnmf package at https://github.com/asotiras/brainparts needs to be downloaded.
		jj_MATLABcodes: Correlations in the ocular preference values, calculated by the OPNMF, for monocular and dichoptic conditions and Chi-square comparison of variance for the classification of the voxels with the two tasks
  


*In the original qMRI analysis, the images were not defaced as in the raw data. This is due to many scans being aligned. Alignments were much better with the whole images that were not skull stripped. However, because of ethical procedures, we shared the defaced raw images.
