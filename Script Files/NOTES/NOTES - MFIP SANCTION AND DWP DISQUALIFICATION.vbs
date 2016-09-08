'Required for statistical purposes==========================================================================================
name_of_script = "NOTES - MFIP SANCTION AND DWP DISQUALIFICATION.vbs"
start_time = timer
STATS_counter = 1               'sets the stats counter at one
STATS_manualtime = 180          'manual run time in seconds
STATS_denomination = "C"        'C is for each case
'END OF stats block=========================================================================================================

'LOADING FUNCTIONS LIBRARY FROM GITHUB REPOSITORY===========================================================================
IF IsEmpty(FuncLib_URL) = TRUE THEN	'Shouldn't load FuncLib if it already loaded once
	IF run_locally = FALSE or run_locally = "" THEN	   'If the scripts are set to run locally, it skips this and uses an FSO below.
		IF use_master_branch = TRUE THEN			   'If the default_directory is C:\DHS-MAXIS-Scripts\Script Files, you're probably a scriptwriter and should use the master branch.
			FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/master/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		Else											'Everyone else should use the release branch.
			FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/RELEASE/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		End if
		SET req = CreateObject("Msxml2.XMLHttp.6.0")				'Creates an object to get a FuncLib_URL
		req.open "GET", FuncLib_URL, FALSE							'Attempts to open the FuncLib_URL
		req.send													'Sends request
		IF req.Status = 200 THEN									'200 means great success
			Set fso = CreateObject("Scripting.FileSystemObject")	'Creates an FSO
			Execute req.responseText								'Executes the script code
		ELSE														'Error message
			critical_error_msgbox = MsgBox ("Something has gone wrong. The Functions Library code stored on GitHub was not able to be reached." & vbNewLine & vbNewLine &_
                                            "FuncLib URL: " & FuncLib_URL & vbNewLine & vbNewLine &_
                                            "The script has stopped. Please check your Internet connection. Consult a scripts administrator with any questions.", _
                                            vbOKonly + vbCritical, "BlueZone Scripts Critical Error")
            StopScript
		END IF
	ELSE
		FuncLib_URL = "C:\BZS-FuncLib\MASTER FUNCTIONS LIBRARY.vbs"
		Set run_another_script_fso = CreateObject("Scripting.FileSystemObject")
		Set fso_command = run_another_script_fso.OpenTextFile(FuncLib_URL)
		text_from_the_other_script = fso_command.ReadAll
		fso_command.Close
		Execute text_from_the_other_script
	END IF
END IF
'END FUNCTIONS LIBRARY BLOCK================================================================================================

DIM Resolution_date 'DIM this so that the "IF's" date calculation below to return a value and for case noting to have a variable place holder.

'DIALOGS----------------------------------------------------------------------------------------------------
BeginDialog case_number_dialog, 0, 0, 171, 70, "Case number dialog"
  EditBox 80, 5, 60, 15, MAXIS_case_number					
  DropListBox 80, 25, 80, 15, "Select one..."+chr(9)+"Apply sanction/disq."+chr(9)+"Cure santion/disq.", action_type
  ButtonGroup ButtonPressed
    OkButton 55, 45, 50, 15
    CancelButton 110, 45, 50, 15
  Text 30, 10, 45, 10, "Case number: "
  Text 5, 30, 70, 10, "Select an action type:"
EndDialog

BeginDialog MFIP_Sanction_DWP_Disq_Dialog, 0, 0, 346, 330, "MFIP Sanction - DWP Disqualification"
  DropListBox 65, 5, 65, 15, "Select one..."+chr(9)+"imposed"+chr(9)+"pending", sanction_status_droplist
  EditBox 265, 5, 50, 15, HH_Member_Number
  DropListBox 65, 25, 110, 15, "Select one..."+chr(9)+"CS"+chr(9)+"ES"+chr(9)+"Dual (ES & CS)"+chr(9)+"No show to orientation"+chr(9)+"Minor mom truancy", sanction_type_droplist
  EditBox 265, 25, 50, 15, number_occurances
  DropListBox 65, 45, 65, 15, "Select one..."+chr(9)+"10%"+chr(9)+"30%"+chr(9)+"100%", Sanction_Percentage_droplist
  EditBox 265, 45, 65, 15, Date_Sanction
  DropListBox 90, 65, 240, 45, "Select one..."+chr(9)+"Failed to attend ES overview"+chr(9)+"Failed to develop employment plan"+chr(9)+"Non-compliance with employment plan"+chr(9)+"< 20, failed education requirement"+chr(9)+"Failed to accept suitable employment"+chr(9)+"Quit suitable employment w/o good cause"+chr(9)+"Failure to attend MFIP orientation"+chr(9)+"Non-cooperation with child support", sanction_reason_droplist
  EditBox 90, 85, 240, 15, sanction_information
  EditBox 90, 105, 140, 15, ES_counselor_name
  EditBox 265, 105, 65, 15, ES_counselor_phone
  EditBox 90, 125, 240, 15, other_sanction_notes
  EditBox 90, 145, 240, 15, Impact_Other_Programs
  EditBox 90, 165, 240, 15, Vendor_Information
  CheckBox 10, 185, 300, 10, "*Click Here* IF sanction # is between 3 to 6, AND the sanction is for consecutive months", consecutive_sanction_months
  Text 10, 200, 325, 10, "**Last day to cure (10 days or 1 day prior to the effective month - this will be in the case note)**"
  CheckBox 10, 225, 130, 10, "Update sent to Employment Services", Update_Sent_ES_Checkbox
  CheckBox 10, 240, 130, 10, "Update sent to Child Care Assistance", Update_Sent_CCA_Checkbox
  CheckBox 10, 260, 80, 10, "Case has been FIAT'd", Fiat_check
  CheckBox 10, 275, 140, 10, "Mandatory vendor form mailed to client", mandatory_vendor_check
  CheckBox 150, 225, 190, 10, "Sent MFIP sanction for future closed month SPEC/LETR", Sent_SPEC_WCOM
  CheckBox 150, 250, 130, 10, "TIKL to change sanction status ", TIKL_next_month
  CheckBox 150, 275, 145, 10, "If you want script to write to SPEC/WCOM", notating_spec_wcom
  EditBox 130, 305, 95, 15, worker_signature
  ButtonGroup ButtonPressed
    OkButton 235, 305, 50, 15
    CancelButton 290, 305, 50, 15
  Text 215, 10, 50, 10, "HH Member #:"
  Text 10, 10, 55, 10, "Sanction status:"
  Text 5, 30, 60, 10, "Type of sanction:"
  Text 185, 30, 75, 10, "Number of occurences:"
  Text 20, 50, 40, 10, "Sanction %:"
  Text 155, 50, 105, 10, "Effective Date of Sanction/Disq.:"
  Text 5, 70, 80, 10, "Reason for the sanction:"
  Text 5, 90, 80, 10, "Sanction info from/how:"
  Text 5, 110, 65, 10, "CS/ES Counselor:"
  Text 235, 110, 25, 10, "Phone:"
  Text 5, 130, 70, 10, "Other sanction notes:"
  Text 5, 150, 85, 10, "Impact to other programs:"
  Text 5, 170, 65, 10, "Vendor information:"
  GroupBox 5, 215, 340, 85, "Check all that apply:"
  Text 160, 235, 160, 10, "(See TE10.20 for info on when to use this notice)"
  Text 160, 260, 175, 10, "(If the sanction status will change for next month)"
  Text 160, 285, 125, 10, "(Check only if MFIP/DWP is approved)"
  Text 65, 310, 60, 10, "Worker signature:"
EndDialog

BeginDialog MFIP_sanction_cured_dialog, 0, 0, 381, 135, "MFIP sanction/DWP disqualification cured"
  DropListBox 90, 5, 70, 15, "Select One..."+chr(9)+"MFIP"+chr(9)+"DWP", select_program
  DropListBox 300, 5, 70, 15, "Select one..."+chr(9)+"Letter"+chr(9)+"Phone Call"+chr(9)+"Email"+chr(9)+"Client Not Notified", notified_via
  EditBox 90, 25, 70, 15, sanction_lifted_month
  EditBox 300, 25, 70, 15, compliance_date
  DropListBox 90, 50, 280, 15, "Select one..."+chr(9)+"Client complied with Employment Services"+chr(9)+"Client complied with Child Support"+chr(9)+"Client complied with Employment Services AND Child Support ", cured_reason
  EditBox 90, 70, 280, 15, action_taken
  EditBox 90, 90, 280, 15, other_notes
  EditBox 90, 110, 170, 15, worker_signature
  ButtonGroup ButtonPressed
    OkButton 265, 110, 50, 15
    CancelButton 320, 110, 50, 15
  Text 35, 75, 50, 10, "Actions taken:"
  Text 235, 10, 60, 10, "Notified Client Via:"
  Text 10, 30, 75, 10, "Month Sanction Lifted:"
  Text 20, 115, 60, 10, "Worker signature:"
  Text 5, 50, 80, 10, "Sanction Cured Reason:"
  Text 5, 95, 80, 10, "Other Notes/Comments:"
  Text 185, 30, 115, 10, "Date Client Came into Compliance:"
  Text 30, 10, 55, 10, "Select program:"
EndDialog

'THE SCRIPT----------------------------------------------------------------------------------------------------
'Connects to BlueZone & grabs case number
EMConnect ""
CALL MAXIS_case_number_finder(MAXIS_case_number)

'Grabbing counselor name and phone from database if applicable
IF collecting_ES_statistics = true AND MAXIS_case_number <> "" THEN
		'Setting constants
		Const adOpenStatic = 3
		Const adLockOptimistic = 3

		'Creating objects for Access
		Set objConnection = CreateObject("ADODB.Connection")
		Set objRecordSet = CreateObject("ADODB.Recordset")

		'Opening DB
	objConnection.Open "Provider = Microsoft.ACE.OLEDB.12.0; Data Source = " & ES_database_path
		'This looks for an existing case number and edits it if needed
		set rs = objConnection.Execute("SELECT * FROM ESTrackingTbl WHERE ESCaseNbr = " & MAXIS_case_number & "")
		IF NOT(rs.eof) THEN ES_counselor_name = rs("ESCounselor")
	objConnection.Close
	set rs = nothing
END IF
		
'Main dialog: user will input case number and initial month/year if not already auto-filled 										
DO										
	DO									
		err_msg = ""							'establishing value of varaible, this is necessary for the Do...LOOP	
		dialog case_number_dialog				'main dialog'				
		If buttonpressed = 0 THEN stopscript	'script ends if cancel is selected'							
		IF len(MAXIS_case_number) > 8 or isnumeric(MAXIS_case_number) = false THEN err_msg = err_msg & vbCr & "* You must enter a valid case number."		'mandatory field			
		If action_type = "Select one..." THEN err_msg = err_msg & vbCr & "* You must select an action type."									'mandatory field			
		IF err_msg <> "" THEN MsgBox "*** NOTICE!!! ***" & vbNewLine & err_msg & vbNewLine		'error message including instruction on what needs to be fixed from each mandatory field if incorrect						
	LOOP UNTIL err_msg = ""									'loops until all errors are resolved
	CALL check_for_password(are_we_passworded_out)			'function that checks to ensure that the user has not passworded out of MAXIS, allows user to password back into MAXIS						
Loop until are_we_passworded_out = false					'loops until user passwords back in					

If action_type = "Apply sanction/disq."	then 
	Do
		'Shows dialog
		DO
			err_msg = ""						
			Dialog MFIP_Sanction_DWP_Disq_Dialog
			cancel_confirmation
			IF sanction_status_droplist = "Select one..." THEN err_msg = err_msg & vbCr & "You must select a sanction status type."
			IF HH_Member_Number = "" THEN err_msg = err_msg & vbCr & "You must enter a HH member number."
			IF sanction_type_droplist = "Select one..." THEN err_msg = err_msg & vbCr & "You must select a sanction type."
			IF number_occurances = "" THEN err_msg = err_msg & vbCr & "You must enter the number of the sanction occurrence."		
			IF IsDate(Date_Sanction) = FALSE THEN 
				err_msg = err_msg & vbCr & "You need to enter a valid date of sanction (MM/DD/YYYY)."
				'logic for figuring out if its the first of the month, if it's not, then it gives a more define date requirement
			ELSEIF datepart("d", Date_Sanction) <> 1 THEN  
				err_msg = "You need to enter a valid date of sanction (MM/DD/YYYY), with DD = to first of the sanction month)"
			END IF
			IF Sanction_Percentage_droplist = "Select one..." THEN err_msg = err_msg & vbCr & "You must select a sanction percentage."
			IF sanction_information = "" THEN err_msg = err_msg & vbCr & "You must enter information about how the sanction information was received."
			IF IsDate(Date_Sanction) = FALSE THEN err_msg = err_msg & vbCr & "You must type a valid date of sanction."
			IF sanction_reason_droplist = "Select One..." THEN err_msg = err_msg & vbCr & "You must select a sanction percentage."
			IF worker_signature = "" THEN err_msg = err_msg & vbCr & "You must sign your case note."
			IF err_msg <> "" THEN MsgBox "*** NOTICE!!! ***" & vbCr & err_msg & vbCr & vbCr & "Please resolve for the script to continue."		
		LOOP UNTIL err_msg = ""
		CALL check_for_password(are_we_passworded_out)			'function that checks to ensure that the user has not passworded out of MAXIS, allows user to password back into MAXIS						
	Loop until are_we_passworded_out = false					'loops until user passwords back in					


	'TIKL to change sanction status (check box selected)
	If TIKL_next_month = checked THEN 
	'navigates to DAIL/WRIT 
		Call navigate_to_MAXIS_screen ("DAIL", "WRIT")	
		
		TIKL_date = dateadd("m", 1, date)		'Creates a TIKL_date variable with the current date + 1 month (to determine what the month will be next month)
		TIKL_date = datepart("m", TIKL_date) & "/01/" & datepart("yyyy", TIKL_date)		'Modifies the TIKL_date variable to reflect the month, the string "/01/", and the year from TIKL_date, which creates a TIKL date on the first of next month.
		
		'The following will generate a TIKL formatted date for 10 days from now.
		Call create_MAXIS_friendly_date(TIKL_date, 0, 5, 18) 'updates to first day of the next available month dateadd(m, 1)
		'Writes TIKL to worker
		Call write_variable_in_TIKL("A pending sanction was determined last month.  Please review case, and resolve or impose the sanction.")
		'Saves TIKL and enters out of TIKL function
		transmit
		PF3
	END If
		
	'This return the date the client has to be in compliance or comply by, and the date that workers need to inform client to cooperate by this date.
	'This date is 10 days from the effective date if it is ES, No Show for Orientation, and/or Minor Mom Truancy, otherwise it is last day of the month prior to the effective month.
	'consecutive months between 3 - 6 months, if they are consecutive months, client has up to the last day of the month prior to the effective date to resolve the sanction.
	IF consecutive_sanction_months = checked then
		Resolution_date = DateAdd("d", -1, Date_Sanction)
	ELSEIf (sanction_type_droplist = "ES") or (sanction_type_droplist = "No show to orientation") or (sanction_type_droplist = "Minor mom truancy") then
		Resolution_date = DateAdd("d", -10, Date_Sanction)
	ELSEIf (sanction_type_droplist = "CS") then
		Resolution_date = DateAdd("d", -1, Date_Sanction)
	End If
	
	'case noting the droplist and editboxes
	start_a_blank_CASE_NOTE
	Call write_variable_in_case_note("***" & Sanction_Percentage_droplist & " " & sanction_type_droplist & " SANCTION " & sanction_status_droplist  & " for MEMB " & HH_Member_Number & " eff: " & Date_Sanction & "***")
	CALL write_bullet_and_variable_in_case_note("HH member number", HH_Member_Number)
	Call write_bullet_and_variable_in_case_note("Sanction status", sanction_status_droplist)
	CALL write_bullet_and_variable_in_case_note("Type of Sanction", sanction_type_droplist)
	CALL write_bullet_and_variable_in_case_note("Number of occurences", number_occurances)
	CALL write_bullet_and_variable_in_case_note("Sanction Percent is", Sanction_Percentage_droplist)
	CALL write_bullet_and_variable_in_case_note("Effective date of sanction/disqualification", Date_Sanction)
	CALL write_bullet_and_variable_in_case_note("Sanction information received from", sanction_information)
	CALL write_bullet_and_variable_in_case_note("CS/ES Counselor", ES_counselor_name & " " & ES_counselor_phone)
	CALL write_bullet_and_variable_in_case_note("Reason for the sanction", sanction_reason_droplist)
	CALL write_bullet_and_variable_in_case_note("Other sanction notes", other_sanction_notes)
	CALL write_bullet_and_variable_in_case_note("Impact to other programs", Impact_Other_Programs)
	CALL write_bullet_and_variable_in_case_note("Vendoring information", Vendor_Information)
	CALL write_bullet_and_variable_in_case_note("Last day to cure", Resolution_date)
	
	'case noting check boxes if checked
	IF Update_Sent_ES_Checkbox = 1 THEN CALL write_variable_in_case_note("* Status update information was sent to Employment Services.")
	IF Update_Sent_CCA_Checkbox = 1 THEN CALL write_variable_in_case_note("* Status update information was sent to Child Care Assistance.")
	IF TIKL_next_month = 1 THEN Call write_variable_in_case_note("* A TIKL was set to update the case from pending to imposed for the 1st of the next month.") 'There was a huge space, I closed up the space
	IF FIAT_check = 1 THEN CALL write_variable_in_case_note("* Case has been FIATed.")
	IF mandatory_vendor_check = 1 THEN CALL write_variable_in_case_note("* A mandatory vendor form has been mailed to the sanctioned individual.") 'There was a huge space, I closed up the space
	IF Sent_SPEC_WCOM = 1 THEN CALL write_variable_in_case_note ("* Sent MFIP sanction for future closed month SPEC/WCOM to the sanctioned individual.")'Changed the SPEC/MEMO to SPEC/WCOM
	CALL write_variable_in_case_note("---")
	CALL write_variable_in_case_note(worker_signature)
	
	If notating_spec_wcom = checked THEN 
		Call navigate_to_MAXIS_screen ("SPEC", "WCOM")
		EMReadscreen CASH_check, 2, 7, 26  'checking to make sure that notice is for MFIP or DWP
		EMReadScreen Print_status_check, 7, 7, 71 'checking to see if notice is in 'waiting status'
		'checking program type and if it's a notice that is in waiting status (waiting status will make it editable)
		If(CASH_check = "MF" AND Print_status_check = "Waiting") OR (CASH_check = "DW" AND Print_status_check = "Waiting") THEN 
			EMSetcursor read_row, 13
			EMSendKey "x"
			Transmit
			PF9
			EMSetCursor 03, 15
			'WCOM required by workers to informed client what who they need to contact, the contact info, and by when they need to resolve the sanction.
			Call write_variable_in_SPEC_MEMO("")
			Call write_variable_in_SPEC_MEMO("Please contact your " & sanction_type_droplist & " worker: " & ES_counselor_name & " at " & ES_counselor_phone & ", on how to cure this sanction.")
			Call write_variable_in_SPEC_MEMO("")
			Call write_variable_in_SPEC_MEMO("You need to be in compliance on/by " & Resolution_date & ".")
			Call write_variable_in_SPEC_MEMO("")
			PF4
			PF3
		ELSE 
			Msgbox "There is not a pending notice for this cash case. The script was unable to update your SPEC/WCOM notation."
		END if
	END If
		
	'Updating database if applicable
	IF collecting_ES_statistics = true THEN
		IF Sanction_Percentage_droplist = "100%" THEN ESActive = "No" 'updating ESActive when case is sanctioned out
		Sanction_Percentage_droplist = replace(Sanction_Percentage_droplist, "%", "") 'clearing the % as the DB is numeric only                               
		CALL write_MAXIS_info_to_ES_database(MAXIS_case_number, HH_Member_Number, ESMembName, Sanction_Percentage_droplist, ESEmpsStatus, ESTANFMosUsed, ESExtensionReason, ESDisaEnd, ESPrimaryActivity, ESDate, ESSite, ESCounselor, ESActive, insert_string)
	END IF
END IF 

If action_type = "Cure santion/disq." then 
	'Shows dialog
	DO
		DO
			err_msg = ""
			Dialog MFIP_sanction_cured_dialog
			cancel_confirmation 
			IF IsNumeric(MAXIS_case_number) = FALSE then err_msg = err_msg & vbnewLine & "* You must type a valid numeric case number."
			If select_program = "Select one..." then err_msg = err_msg & vbnewLine & "* You must select a cash program."
			If sanction_lifted_month = "" then err_msg = err_msg & vbnewLine & "* Enter the month the sanction was lifted."
			If isdate(compliance_date) = False then err_msg = err_msg & vbnewLine & "* Enter the date client went into compliance."
			IF cured_reason = "Select one..." then err_msg = err_msg & vbnewLine & "* You must select 'Reason for Sanction being Cured.'"
			IF notified_via = "Select one..." then err_msg = err_msg & vbnewLine & "* How was the client notified?"
			IF worker_signature = "" then err_msg = err_msg & vbnewLine & "* You must sign your case note."
			IF err_msg <> "" THEN MsgBox "*** NOTICE!!! ***" & vbNewLine & err_msg & vbNewLine		'error message including instruction on what needs to be fixed from each mandatory field if incorrect						
		LOOP UNTIL err_msg = ""									'loops until all errors are resolved
		CALL check_for_password(are_we_passworded_out)			'function that checks to ensure that the user has not passworded out of MAXIS, allows user to password back into MAXIS						
	Loop until are_we_passworded_out = false					'loops until user passwords back in					

	'adding a case note header variable depending on which cash program is selected
	If select_program = "MFIP" then case_note_header = "~~$~~MFIP SANCTION CURED~~$~~"
	If select_program = "DWP" then case_note_header = "~~$~~DWP DISQUALIFICATION CURED~~$~~"
	
	'Writes the case note
	start_a_blank_CASE_NOTE
	CALL write_variable_in_case_note (case_note_header)                                         'Writes title in Case note
	CALL write_bullet_and_variable_in_case_note("Month Sanction Cured", sanction_lifted_month)                 'Writes Month the Sanction was lifted
	CALL write_bullet_and_variable_in_case_note("Client Came Into Compliance On", compliance_date)             'Writes the Date the Client came into Compliance
	CALL write_bullet_and_variable_in_case_note("Sanction Cured Reason", cured_reason)                         'Writes the reason why the sanction was cured
	CALL write_bullet_and_variable_in_case_note("Actions Taken", action_taken)                                 'Writes any actions taken
	CALL write_bullet_and_variable_in_case_note("Other Notes/Comments", other_notes)                           'Writes any other notes/comment
	CALL write_bullet_and_variable_in_case_note("Client was notified Via", notified_via)                       'Writes the way the client was notified that their sanction was lifted
	CALL write_variable_in_case_note ("---")   
	CALL write_variable_in_CASE_NOTE(worker_signature)                                                         'Writes worker signature in note
End if
script_end_procedure ("")