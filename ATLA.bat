@echo off
setlocal enabledelayedexpansion

REM Get Present Working Directory
set "DOWNLOAD_LOCATION=%CD%"

REM Set the path to the version text file
set "versionFile=version.txt"

REM Initialize the version variable
set "version="

REM Check if the version file exists
if exist "!versionFile!" (
  REM Read the version from the file
  set /p version=<"!versionFile!"
) else (
  REM Define the pattern to search for
  @REM set "folder_pattern=ATLA v[0-9]\.[0-9]\.[0-9]"
  set "folder_pattern=ATLA"

  REM Use a FOR loop to check for matching folders
  for /d %%d in ("!DOWNLOAD_LOCATION!\*") do (
    echo Checking folder: "%%~nxd"
    echo Folder pattern: "%folder_pattern%"
    @REM echo %%~nxd | findstr /r /c:"ATLA v[0-9]*\.[0-9]*\.[0-9]*" > nul
    echo %%~nxd | findstr /r /c:"ATLA" > nul
    if not errorlevel 1 (
      echo An existing ATLA folder was detected. Deleting "%%~nxd"
      rmdir /s /q "%%~nxd"
      if not exist "%%d" (
        echo "%%~nxd" was deleted successfully.
      ) else (
        echo Error: Unable to delete "%%~nxd".
      )
    ) 
  )
)

REM Replace with your GitHub username and repository name
set "USERNAME=Giridharaprasath"
set "REPO=ATLA-UnrealEngine5"

REM GitHub API URL to get the latest release
set "API_URL=https://api.github.com/repos/%USERNAME%/%REPO%/releases/latest"

REM API Response File Name
set "RESPONSE_FILENAME=release.json"

REM Make a GET request to the API and save the response to a temporary file
curl -s -o %RESPONSE_FILENAME% %API_URL%

REM Check if the request was successful
if !ERRORLEVEL!==0 (
  REM Parse the JSON response to get the latest release version
  for /f "tokens=2 delims=:" %%a in ('type release.json ^| findstr /r "\"tag_name\""') do (
    set "latest_version=%%~a"
    set "latest_version=!latest_version:~2,-1!"
    set "latest_version=!latest_version:~0,-1!" REM Remove trailing quote
  )

  REM If the loop finishes without finding the latest version, display an error
  if not defined latest_version (
    echo Error: Unable to get the latest release version.
  ) else (
    echo !latest_version!
  )
) else (
  REM Display an error message
  echo Error: Unable to fetch the latest release. Make sure the repository exists or check your internet connection.
)

REM Deleting release API response file
set "file_to_delete=!DOWNLOAD_LOCATION!\!RESPONSE_FILENAME!"

REM Check if the file exists before attempting to delete
if exist "!file_to_delete!" (
    del "!file_to_delete!"
    echo Response API File deleted successfully.
) else (
    echo The file does not exist.
)

echo '!latest_version!' '!version!'

if not "!version!"=="!latest_version!" (
  echo An update is available. Downloading the latest release.

  REM Replace Latest Release URL
  set "GITHUB_RELEASE_URL=https://github.com/!USERNAME!/!REPO!/releases/download/!latest_version!/ATLA.!latest_version!.zip"

  REM Replace with the desired download location and filename
  set "FILENAME=ATLA.zip"
  echo "!FILENAME!"

  REM Create the download location directory if it doesn't exist
  mkdir "%DOWNLOAD_LOCATION%" 2>nul

  REM Use curl to download the release
  curl -L -o "!DOWNLOAD_LOCATION!\!FILENAME!" "!GITHUB_RELEASE_URL!"

  REM Check if the download was successful
  if %ERRORLEVEL%==0 (
    echo Download completed successfully.
    echo Please hold until the removal of the ZIP archive is complete.
  ) else (
    echo Error: Unable to download the release.
  )

  REM unzipping the file

  REM Replace with the path to the zip file you want to unzip
  set "ZIP_FILE=!DOWNLOAD_LOCATION!\!FILENAME!"
  echo !ZIP_FILE!

  REM Replace with the destination directory where you want to extract the files
  set "DESTINATION_DIR=!DOWNLOAD_LOCATION!"

  REM Check if the destination directory exists; if not, create it
  if not exist "!DESTINATION_DIR!" (
    mkdir "!DESTINATION_DIR!"
  )

  echo "'!ZIP_FILE!', '!DESTINATION_DIR!'"

  REM Use PowerShell to unzip the file
  powershell -nologo -noprofile -command "& {Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('!ZIP_FILE!', '!DESTINATION_DIR!')}"

  REM Check if the unzip operation was successful
  if %ERRORLEVEL%==0 (
    echo Unzip completed successfully.
  ) else (
    echo Error: Unable to unzip the file.
  )

  REM Deleting zip file
  set "file_to_delete=!DOWNLOAD_LOCATION!\!FILENAME!"

  REM Check if the file exists before attempting to delete
  if exist "!file_to_delete!" (
      del "!file_to_delete!"
      echo File deleted successfully.
  ) else (
      echo The file does not exist.
  )

  echo !latest_version!> !versionFile!
)

REM Exe Launch Location
set "EXE_LOCATION=!DOWNLOAD_LOCATION!\ATLA\Windows\ATLAProject.exe"

REM Launching exe File
start "" "%EXE_LOCATION%"

endlocal