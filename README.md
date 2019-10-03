# m3u-ps1 (script to be uploaded soon)
Powershell script to write (to STDOUT) extended M3U info for MP3 files recursively found within and beneath the current directory.

Example Usage:

Step 1: Open a Powershell window and change to the topmost directory that contains your MP3 files within/beneath it:

`cd c:\users\myname\music`

Step 2: Execute the script (with no arguments) to output info for all MP3 files:

`\path\to\m3u.ps1`

-or-

Step 2: Execute the script to output info for all MP3 files that were created in the last 'n' days:

`\path\to\m3u.ps1 7`

-or-

Step 2: Execute the script to output info for all MP3 files that contain specific text within their full path\name:

`\path\to\m3u.ps1 'The Doors'`

If desired, redirect the script's output to a file.
