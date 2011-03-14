# This function takes two arguments. The option to change
# and a description.
# The changed value is stored in the variable
# BB_RET_VALUE which is set to an empty string at the beginning
# of the function.
change_cmd()
{
    typeset input
    typeset TEMP=$1
    BB_RET_VALUE=

    pretty_top
    top_info_line
echo -en "${BBOPTIONCOLOR}The current $2 is
${BBMAINCOLOR}$1${BBOPTIONCOLOR}.
${BBOPTIONCOLOR}If you wish to change it, enter the new command below.
${BBOPTIONCOLOR}To cancel, press [enter] without writing anything."
dashed_line
echo -e "${BBINPUTCOLOR}${bb_conf_menu_entry} |> ${BBCOLOROFF}"
    read -e input

    if [[ -z "${input}" ]]
    then
	BB_RET_VALUE=$TEMP
    else
	BB_RET_VALUE=$input
        BB_ADVANCED_CONFIG_MODIFIED=1
    fi
}
