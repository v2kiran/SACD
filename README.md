# SACD

## OverView
This module allows you to read an SACD ISO Audio file, list the track\Album and artist information. It can also help you to extract individual audio tracks in dsd format.
Based on the number of Audio channels recorded in the ISO file you can extract the Audio tracks in 2-channel or multi channel configuration.
The output directory can be the same as the ISO file or a custom user specified directory.

## What is an SACD
SACD was Sony and Philips's unsuccessful foray into the world of high-resolution audio. SACD uses a one-bit, high-resolution DSD system that, when used throughout the entire recording process, can produce a stunning audio sound with many times more resolution and much more realistic sound than a compact disc. Also, most SACDs were recorded in stereo rather than in 5.1 surround. [More Details Here](https://hometheaterreview.com/super-audio-compact-disc-sacd/).


## Clone Module

```powershell
#Clone the repo in c:\temp
cd c:\temp
git clone https://github.com/v2kiran/SACD.git
```
OR

If you have powershell 5.1 you can install PSLiteDB from the [PowerShell Gallery](https://www.powershellgallery.com/)
```powershell
Install-Module -Name SACD -Scope CurrentUser
```

***

## New to PowerShell?
If you never used Powershell before you may get this error when you try to use the module:
**"execution of scripts is disabled on this system"**
Check this [link](https://stackoverflow.com/questions/4037939/powershell-says-execution-of-scripts-is-disabled-on-this-system)

Other Resources:
[Official microsoft Documentation](https://docs.microsoft.com/en-us/powershell/index?view=powershell-5.1)

***


## Import Module
```powershell
Import-Module c:\temp\SACD -verbose
```

***

## List Audio Tracks
```powershell
List-SACDTrack -Path "C:\Audio\Police.iso" | Format-Table -Autosize

Count Track                                Artist     Album                                Channels
----- -----                                ------     -----                                --------
    1 Roxanne                              The Police Every Breath You Take - The Classics 2,6
    2 Can't Stand Losing You               The Police Every Breath You Take - The Classics 2,6
    3 Message In A Bottle                  The Police Every Breath You Take - The Classics 2,6
    4 Walking On The Moon                  The Police Every Breath You Take - The Classics 2,6
    5 Don't Stand So Close To Me           The Police Every Breath You Take - The Classics 2,6
    6 De Do Do Do, De Da Da Da             The Police Every Breath You Take - The Classics 2,6
    7 Every Little Thing She Does Is Magic The Police Every Breath You Take - The Classics 2,6
    8 Invisible Sun                        The Police Every Breath You Take - The Classics 2,6
    9 Spirits In The Material World        The Police Every Breath You Take - The Classics 2,6
   10 Every Breath You Take                The Police Every Breath You Take - The Classics 2,6
```

The SACD "Police.iso" contains 10 tracks which have been recorded in 2 different speaker configurations:
- 2-channel
- 6-channel

During extraction you can choose which configuration you want the tracks to be in.
***

## Extract 2-channel Audio Tracks
Extract tracks in 2-channel speaker configuration along with a cuesheet. COnvert any DST to DSD format.
The output directory is the same as the ISO file.


```powershell
$ISOFile = "C:\Audio\Police.iso"
Extract-SACDTrack -Path $ISOFile -Channels Two -OutputFormat PhilipsDSDIFF -ConvertDSTtoDSD -ExportCueSheet -Verbose

# The above command can also be written as :
Extract-SACDTrack -Path $ISOFile -ConvertDSTtoDSD -ExportCueSheet -Verbose
```
This works because the default values for the "Channels" parameter is "2-channel" and that for the "Outputformat" is "PhilipsDSDIFF"
***

## Extract multi-channel Audio Tracks
Extract tracks in 6-channel speaker configuration along with a cuesheet. Convert any DST to DSD format.


```powershell
$ISOFile = "C:\Audio\Police.iso"
Extract-SACDTrack $ISOFile -Channels multi -ConvertDSTtoDSD -Verbose
```
multi-channel can mean any of the following speaker configurations 5 6 or 7 channels. The actual number of audio channels of the tracks depends upon the SACD ISO file
***

## Output to a custom directory.
```powershell
$ISOFile = "C:\Audio\Police.iso"
Extract-SACDTrack -Path $ISOFile -Destination "C:\AudioOutput\Police" -ConvertDSTtoDSD -Verbose
```
Destination directory will be automatically created if it dosent already exist.

***

## Various Output formats
Philips DSDIFF is the default output format but you may specify any of the following formats during extraction.

```powershell
$ISOFile = "C:\Audio\Police.iso"

# Output as Sony DSF
Extract-SACDTrack $ISOFile -OutputFormat SonyDSF -ConvertDSTtoDSD -Verbose

# Output as Raw ISO
Extract-SACDTrack $ISOFile -OutputFormat RAWISO -ConvertDSTtoDSD -Verbose
```

***

## Batch Processing
 you can use the pipeline to process multiple SACD ISO files in different sub directories

```powershell
# List track information
Get-ChildItem -Path 'M:\Music' -Filter *.iso -Recurse |
    List-SACDTrack | 
      Format-Table Count,Track,Channels,Album -GroupBy Artist

  Artist: Steely Dan

Count Track              Channels Album
----- -----              -------- -----
    1 Babylon Sisters    2        Gaucho
    2 Hey Nineteen       2        Gaucho
    3 Glamour Profession 2        Gaucho
    4 Gaucho             2        Gaucho
    5 Time Out Of Mind   2        Gaucho
    6 My Rival           2        Gaucho
    7 Third World Man    2        Gaucho


   Artist: The Police

Count Track                                Channels Album
----- -----                                -------- -----
    1 Roxanne                              2,6      Every Breath You Take - The Classics
    2 Can't Stand Losing You               2,6      Every Breath You Take - The Classics
    3 Message In A Bottle                  2,6      Every Breath You Take - The Classics
    4 Walking On The Moon                  2,6      Every Breath You Take - The Classics
    5 Don't Stand So Close To Me           2,6      Every Breath You Take - The Classics
    6 De Do Do Do, De Da Da Da             2,6      Every Breath You Take - The Classics
    7 Every Little Thing She Does Is Magic 2,6      Every Breath You Take - The Classics
    8 Invisible Sun                        2,6      Every Breath You Take - The Classics
    9 Spirits In The Material World        2,6      Every Breath You Take - The Classics
   10 Every Breath You Take                2,6      Every Breath You Take - The Classics


# Extract Tracks
Get-ChildItem -Path 'M:\Music' -Filter *.iso -Recurse |
    Extract-SACDTrack -ConvertDSTtoDSD -Verbose
```
This works because the path parameter of the List\ExtractSACD cmdlet is automatically bound to output from the "Get-ChildItem" cmdlet.

***