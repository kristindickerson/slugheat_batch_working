README.md

This is a rough draft for batch mode functionality for SlugHeat.

inputs:
	
	Create a folder that houses all your .mat, .tap, .par, and .pen files. Ensure that all penetrations you are running require the same input parameters, as defined in 		your .par file that needs to also be in the same subfolder. Place that folder within the subfolder /batch_inputs/. When prompted, the command window will ask you the 		name of the name of this subfolder that you created.

		EX: if your .mat, .tap, .par, and .pen are in 'Folder_With_My_Files'

  	You can either have a folder with one penetration and many .par files or loop through a folder with one .par file and many penetrations. Ensure your folder set up is 		one of these two options. Then when prompted in the command window, 

   		write:

				loop par 
    				or
				loop pen

	When prompted in the command window, 

		write:

				Folder_With_My_Files

	Next, the command window will ask if you are using .mat or .pen files. If you have .mat files, when prompted

		write:

			.mat
			or
			.pen

	Next, the command window will ask if you are using a heat pulse and if so, whether to use the power (J/m) defined in the penetration files (.pen and .mat) or parameter 	file (.par). 
 	If you want to use power defined in the penetration files, 

		write:

			pen
			or
			par
   			or
			none

outputs:

	a subfolder will be created for each penetration in the folder '/outputs/'. this includes .res, .log, and .par files created by SlugHeat

	a summary excel file is created and place in the folder '/outputs/' with a summary of key results (e.g., heat flow, average k, thermal gradient) for all penetrations run in the current batch run

	No plots are made and no sensitivity analysis is run
