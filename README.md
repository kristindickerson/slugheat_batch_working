README.md

This is a rough draft for batch mode functionality for SlugHeat.

To run:

1. Edit the yaml file (slugheat_batch.yaml) as desired in a text editor, 

   	`loop: 'pens'
   		# 'pens': loop through pen files with a single set of parameters OR 'pars': loop through par files with a single penetration
	data_folder: 'Folder_With_My_Files'
		# name of input folder where all .pen or .mat files for batch mode are located. This should be a subfolder within "/batch_inputs/"
	penfile_type: '.mat'
		# '.mat': using .mat files as input files OR '.pen': using .pen files as input files
	hp_file: 'par'
		# 'par': heat pulse defined in the .par file OR 'pen': heat pulse defined in the .pen file OR 'none': not using a heat pulse`

3. In matlab command window:
	
 	`slugheat_batch(slugheat_batch.yaml)`


inputs:
	
1. You must create a folder that houses all your .mat, .tap, .par, and .pen files. Ensure that all penetrations you are running require the same input parameters, as defined in your .par file that needs to also be in the same subfolder. Place that folder within the subfolder /batch_inputs/. When prompted, the command window will ask you the name of the name of this subfolder that you created.

	EX: if your .mat, .tap, .par, and .pen are in 'Folder_With_My_Files'

2. You can either have a folder with one penetration and many .par files or loop through a folder with one .par file and many penetrations. Ensure your folder set up isn one of these two options. 
outputs:

	a subfolder will be created for each penetration in the folder '/outputs/'. this includes .res, .log, and .par files created by SlugHeat

	a summary excel file is created and place in the folder '/outputs/' with a summary of key results for each **penetration** (e.g., heat flow, average k, thermal gradient) for all penetrations run in the current batch run

	a summary excel file is created and place in the folder '/outputs/' with a summary of key results for each **sensor** (e.g., depth, temperature, thermal conductivity) for all penetrations run in the current batch run

	No plots are made and no sensitivity analysis is run
