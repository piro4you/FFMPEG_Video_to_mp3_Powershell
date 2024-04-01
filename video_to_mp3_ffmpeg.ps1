#show PS version
$PSVersionTable.PSVersion

#check for "-d" flag that
#"-d" flag DELETES original files after making .mp3 files 
if ($args -contains '-d'){
    $delete_original = $true
}
else {
    $delete_original = $false
}

#check for "-n" flag 
#"-n" flag turns off fool check, that checks if the file is, supposedly, the video you want to make audio
#the formats checked are ".webm", ".mp4", ".mkv", ".aac", ".waw"
#effectively, if used with "-d" flag, may cause deletion of files unintendent for deletion
if ($args -contains '-n'){
    $not_safe = $true
}
else {
    $not_safe = $false
}

$list_of_supported_filetypes = ".webm", ".mp4", ".mkv", ".aac", ".waw"

#main loop
#executes ls and does operatoins for every file in the folder
foreach($file in Get-ChildItem -File){
    #check if the file is not ".mp3"
    if ($file.Extension -ne '.mp3'){

        #fool check
        #checks if files that will undergo the ffmpeg are supposedly the video ones
        #if the file's extension is not in the list, continue to the next file
        if (!$not_safe){
            if ($file.Extension -notin $list_of_supported_filetypes){
                continue
            }
        }
        
        $file.Name

        #creates the name with ".mp3" extension based on original name, replacing the extension
        $output_file_name = $file.FullName -replace $file.Extension, ".mp3"

        #these are arguments for the ffmpeg
        #it shows nothing but fatal errors and progress of "encoding"
        $ffmpeg_arguments = @(
            "-i", "`"$($file.FullName)`"",
            "-hide_banner",
            "-loglevel fatal",
            "-stats",
            "-vn",
            "-y",
            "`"$output_file_name`""
        )

        #Starts ffmpeg and waits until complete
        Start-Process -FilePath "ffmpeg.exe" -ArgumentList $ffmpeg_arguments -NoNewWindow -Wait
        
        #TODO
        #write informing user if the ffmpeg finished making .mp3

        #delete the file after turnning it to .mp3 
        if($delete_original){
            Remove-Item -LiteralPath "$($file.FullName)"          
        }      
    }
}
