#!/bin/bash


#
# link_files creates symlinks from the picked files in the file array
# to BBBURNDIR if the number has a corresponding file.
#
link_files() {
    cd $BBBURNDIR
    for filenum in $CHOSEN_FILES; do
	if [[ "$filenum" -lt "$FILE_NUMBER" && "$filenum" -gt 0 ]]; then
            ln -s "${FILE_ARRAY[$filenum]}" .
            echo "${filenum} -> ${FILE_ARRAY[$filenum]} linked."
	else
            echo -e "\n$filenum does not match a file. Wrong input?\n"
	fi
    done
    echo -e "\nFiles linked to $BBBURNDIR\n"
}

#
# Same as function above but removed files from data directory.
#
delete_files() {
    cd $BBBURNDIR
    for filenum in $CHOSEN_FILES; do
	if [[ "$filenum" -lt "$FILE_NUMBER" && "$filenum" -gt 0 ]]; then
            rm "${FILE_ARRAY[$filenum]}"
            echo "${filenum} -> ${FILE_ARRAY[$filenum]} deleted."
	else
            echo -e "\n$filenum does not match a file. Wrong input?\n"
	fi
    done
    echo -e "\nFiles deleted from $BBBURNDIR\n"
}

#
# get_files_to_link simply recieves a list of number that corresponds
# to files in the file array. This list is used in link_files above.
# If user cancels by just pressing enter, I_WANT_TO_QUIT is set and
# the function aborts.
#
get_files_to_link() {
    echo 'Which files to you wish to link to the data folder?'
    echo 'Enter one or more numbers, separated by a space'
    echo 'or just press [ENTER] to abort.'
    echo '([d] means the entry is a directory, [f] means it is a file)'
    read -p 'File(s): ' CHOSEN_FILES
    if [[ -z "$CHOSEN_FILES" ]]; then
	I_WANT_TO_QUIT=1
	echo 'No input, aborting...'
	wait_for_enter
    else
	I_WANT_TO_QUIT=0
    fi
}

#
# Same as function above, only this deletes specific files instead of linking them. 
#
get_files_to_delete() {
    echo 'Which files to you wish to delete from the data folder?'
    echo 'Enter one or more numbers, separated by a space'
    echo 'or just press [ENTER] to abort.'
    echo '([d] means the entry is a directory, [f] means it is a file)'
    read -p 'File(s): ' CHOSEN_FILES
    if [[ -z "$CHOSEN_FILES" ]]; then
	I_WANT_TO_QUIT=1
	echo 'No input, aborting...'
	wait_for_enter
    else
	I_WANT_TO_QUIT=0
    fi
}



#
# print_folder_contents reads a directory name to look for files in.
# If the filename exists and is not empty an array is created where
# a number works as a key for a file (array[4] = file.txt).
# If the entry is empty, the variable I_WANT_TO_QUIT is set and the
# process will be aborted.
# If the entry is not empty but not valid, the user will be asked to
# re-enter the directory name.
# This function can also take the directory to look for files in as an argument.
#
print_folder_contents() {

    typeset -i COL_COUNTER=0

    if [[ -z "$1" ]]; then
	read -p 'Enter path to look for files in or press [ENTER] to cancel: ' FILE_PATH
    else
	FILE_PATH="$1"
    fi

    if [[ -e "$FILE_PATH" && -n "$FILE_PATH" ]]; then
	while read file_name; do
            FILE_ARRAY[$FILE_NUMBER]=$FILE_PATH/$file_name
	    
	    # Print output in three columns
	    if [[ "$COL_COUNTER" -eq 3 ]]; then
		echo
		COL_COUNTER=0
	    fi
		if [[ -d "$FILE_PATH/$file_name" ]]; then
		    echo -n " $FILE_NUMBER: $file_name [d] "
		else
		    echo -n " $FILE_NUMBER: $file_name [f] "
		fi
		((FILE_NUMBER++))
		((COL_COUNTER++))
	done < <(ls -1 $FILE_PATH)
	echo -e '\n'
	STEP_SUCCEEDED=1
	I_WANT_TO_QUIT=0
    elif [[ -z "$FILE_PATH" ]]; then
	echo "No input, aborting..."
	wait_for_enter
	STEP_SUCCEEDED=1
	I_WANT_TO_QUIT=1
    else
	echo -e "\nDirectory does not exist, please enter a correct path.\n"
	wait_for_enter
	STEP_SUCCEEDED=0
	I_WANT_TO_QUIT=0
    fi
}

#
# Script start
#

file_manager() {
    
    typeset -i FILE_NUMBER	# Number of files in list to link
    typeset FILE_PATH		# Path to look for files in
    typeset FILE_ARRAY		# Array with chosen files
    typeset CHOSEN_FILES	# Number of the chosen files
    typeset -i STEP_SUCCEEDED   # Did the current task succeed?
    typeset -i I_WANT_TO_QUIT   # User wants to abort
    typeset FM_MODE="$1"

    while true; do
	
	STEP_SUCCEEDED=0
	FILE_NUMBER=1
	I_WANT_TO_QUIT=0
        
	while [[ "$STEP_SUCCEEDED" -eq 0 ]]; do
	    if [[ "$FM_MODE" == "add" ]]; then
		print_folder_contents
	    elif [[ "$FM_MODE" == "remove" ]]; then
		print_folder_contents "$BBBURNDIR"
	    else
		echo "Mode '$FM_MODE' not implemented, aborting"
		wait_for_enter
		STEP_SUCCEEDED=1
		I_WANT_TO_QUIT=1
	    fi
	done
	
	if [[ "$I_WANT_TO_QUIT" -eq 1 ]]; then
            break
	else
            I_WANT_TO_QUIT=0
	    if [[ "$FM_MODE" == "add" ]]; then
		get_files_to_link
	    elif [[ "$FM_MODE" == "remove" ]]; then
		get_files_to_delete
	    fi
	    if [[ "$I_WANT_TO_QUIT" -eq 1 ]]; then
		break
            else
		if [[ "$FM_MODE" == "add" ]]; then
		    link_files
		elif [[ "$FM_MODE" == "remove" ]]; then
		    delete_files
		fi
				
		read -p 'Link/delete more files (y/n): ' ANSWER
		
		if [[ "$ANSWER" = "n" ]]; then
		    break;
		fi
            fi
	fi
    done
}
