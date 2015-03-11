#@transcription_filepaths(session_parameters.analysis_directory$, session_parameters.analysis_directory$, session_parameters.experimental_task$, session_parameters.testwave$)
#wordList_dir$ = transcription_filepaths.wordList_dir$

#procedure transcription_filepaths(.drive$, .audio_drive$, .task$, .testwave$)
procedure transcription_parameters
	
	# Where is the non-audio data located?
	.data_dir$ = session_parameters.analysis_directory$ + "/" + session_parameters.experimental_task$ + "/" + session_parameters.testwave$
	
	# Segmentations ready to be transcribed from
	.segmentDirectory$ = .data_dir$ + "/Segmentation/TextGrids"
	
	# Where transcriptions and transcription logs go
	.textGridDirectory$ = .data_dir$ + "/Transcription/TranscriptionTextGrids"
	.logDirectory$ = .data_dir$ + "/Transcription/TranscriptionLogs"

	# Where extracted "snippet" collections go
	.transSnippetDirectory$ = .data_dir$ + "/Transcription/ExtractedSnippets"
	
	# Word List table columns
	if session_parameters.experimental_task$ == "RealWordRep"
		.wl_trial  = 1
		.wl_trial$ = "TrialNumber"
		.wl_word   = 3
		.wl_word$  = "Word"
	elsif session_parameters.experimental_task$ == "NonWordRep"
		.wl_trial  = 1
		.wl_trial$ = "TrialNumber"
		.wl_word   = 3
		.wl_word$  = "Orthography"
	elsif session_parameters.experimental_task$ == "GFTA"
		.wl_trial  = 1
		.wl_trial$ = "word"
		.wl_word   = 3
		.wl_word$  = "ortho"
	endif
endproc

#### PROCEDURE to load the transcription log file or create the transcription log Table object.
procedure transcription_log(.method$, .task$, .experimental_ID$, .initials$, .directory$, .n_1, .n_2, .n_3)
	# Description of the Nonword Transcription Log.
	# A table with one row and the following columns (values).
	# - NonwordTranscriber (string): the initials of the nonword
	#     transcriber.
	# - StartTime (string): the date & time that the transcription began.
	# - EndTime (string): the date & time that the transcription ended.
	# - NumberOfCVs (numeric): the number of trials (rows) in the Word
	#     List table whose target sequence is a CV.
	# - NumberOfCVsTranscribed (numeric): the number of CV-trials that
	#     have been transcribed.
	# - NumberOfVCs (numeric): the number of trials (rows) in the Word
	#     List table whose target sequence is a VC.
	# - NumberOfVCsTranscribed (numeric): the number of VC-trials that
	#     have been transcribed.
	# - NumberOfCCs (numeric): the number of trials (rows) in the Word
	#     List table whose target sequence is a CC.
	# - NumberOfCCsTranscribed (numeric): the number of CC-trials that
	#     have been transcribed.
	# Numeric and string constants for the NonwordTranscription Log.

	# Numeric and string constants for the NWR transcription log

	.transcriber     = 1
	.transcriber$    = "Transcriber"
	.start           = 2
	.start$          = "StartTime"
	.end             = 3
	.end$            = "EndTime"

	if .task$ = "NonWordRep"
		.cvs             = 4
		.cvs$            = "NumberOfCVs"
		.cvs_transcribed  = 5
		.cvs_transcribed$ = "NumberOfCVsTranscribed"
		.vcs             = 6
		.vcs$            = "NumberOfVCs"
		.vcs_transcribed  = 7
		.vcs_transcribed$ = "NumberOfVCsTranscribed"
		.ccs             = 8
		.ccs$            = "NumberOfCCs"
		.ccs_transcribed  = 9
		.ccs_transcribed$ = "NumberOfCCsTranscribed"

		# Concatenate column names argument for the Create Table command
		.column_names$ = "'.transcriber$' '.start$' '.end$' '.cvs$' '.cvs_transcribed$' '.vcs$' '.vcs_transcribed$' '.ccs$' '.ccs_transcribed$'"
	elif .task$ = "GFTA"
		.trials = 4
		.trials$ = "NumberOfTrials"
		.trials_transcribed = 5
		.trials_transcribed$ = "NumberOfTrialsTranscribed"
		.score = 6
		.score$ = "Score"
		.transcribeable = 7
		.transcribeable$ = "TranscribeableTokens"

		# Concatenate column names argument for the Create Table command
		.column_names$ = "'.transcriber$' '.start$' '.end$' '.trials$' '.trials_transcribed$' '.score$' '.transcribeable$'"
	endif

	# Filename constants
	selectObject(audio.praat_obj$)

	.basename$ = .task$ + "_" + .experimental_ID$ + "_" + .initials$ + "transLog"
	.filename$ = .basename$ + ".txt"
	.filepath$ = .directory$ + "/" + .filename$
	.exists = fileReadable(.filepath$)

	## Pseudo-methods

	if .method$ == "check"
		# Do nothing. The checking already happened above. But we make a
		# pseudomethod called "check" so we can describe what happens when
		# only the above code is executed.
	endif

	if .method$ == "load"
		if .exists
			Read Table from tab-separated file: .filepath$
		else
			# Initialize the values of the Nonword Transcription Log.
			Create Table with column names: .basename$, 1, .column_names$

			@currentTime
			select Table '.basename$'

			Set string value: 1, .transcriber$, .initials$
			Set string value: 1, .start$, currentTime.t$
			Set string value: 1, .end$, currentTime.t$

			if .task$ = "NonWordRep"
				Set numeric value: 1, .cvs_transcribed$, 0
				Set numeric value: 1, .vcs_transcribed$, 0
				Set numeric value: 1, .ccs_transcribed$, 0

				Set numeric value: 1, .cvs$, .n_1
				Set numeric value: 1, .vcs$, .n_2
				Set numeric value: 1, .ccs$, .n_3
			elif .task$ = "GFTA"
				Set numeric value: 1, .trials_transcribed$, 0
				Set numeric value: 1, .trials$, .n_1
				Set numeric value: 1, .score$, 0
				Set numeric value: 1, .transcribeable$, 77
			endif
		endif
		.praat_obj$ = selected$()
	endif
endproc


#### PROCEDURE to load the transcription textgrid file or create the TextGrid object.
procedure transcription_textgrid(.method$, .task$, .experimental_ID$, .initials$, .directory$)
	if .task$ = "NonWordRep"
		# Numeric and string constants for the NWR transcription textgrid
		.target1_seg = 1
		.target2_seg = 2
		.prosody = 3
		.notes = 4

		.target1_seg$ = "Target1Seg"
		.target2_seg$ = "Target2Seg"
		.prosody$ = "ProsodyScore"
		.notes$ = "TransNotes"
		.level_names$ = "'.target1_seg$' '.target2_seg$' '.prosody$' '.notes$'"
		.pointTiers$ = .notes$
	elif .task$ = "GFTA"
		# Numeric and string constants for the GFTA transcription textgrid
		.prosodicPos = 1
		.phonemic = 2
		.score = 3
		.notes = 4

		.prosodicPos$ = "ProsodicPos"
		.phonemic$ = "Phonemic"
		.score$ = "Score"
		.notes$ = "TransNotes"

		.level_names$ = "'.prosodicPos$' '.phonemic$' '.score$' '.notes$'"
		.pointTiers$ = "'.score$' '.notes$'"
	endif

	.filename$ = .task$ + "_" + .experimental_ID$ + "_" + .initials$ + "trans"
	.filepath$ = .directory$ + "/" + .filename$ + ".TextGrid"
	.exists = fileReadable(.filepath$)

	## Pseudo-methods

	if .method$ == "check"
		# Do nothing. The checking already happened above. But we make a
		# pseudomethod called "check" so we can describe what happens when
		# only the above code is executed.
	endif

	if .method$ == "load"
		if .exists
			Read from file: .filepath$
			.praat_obj$ = selected$()
		else
			# Initialize the textgrid
			selectObject(audio.praat_obj$)
			To TextGrid: .level_names$, .pointTiers$

			select TextGrid 'audio.researchID$'_Audio
			Rename: .filename$
			.praat_obj$ = selected$()
		endif
	endif
endproc