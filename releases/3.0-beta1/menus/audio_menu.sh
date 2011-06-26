convert_and_burn_from_files()
{
    # Burn Audio from music files
    convert_if_exist '*.mp3'
    convert_if_exist '*.ogg'
    convert_if_exist '*.flac'
    burning --audio
}

burn_m3u_playlist()
{
    m3u_read
    convert_and_burn_from_files
}

audio_menu()
{
    bbmenu bb_am_menu_title audiomenu
} # audio_menu
