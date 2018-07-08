using namespace  system.collections

$Script:SACD = Join-Path -Path $PSScriptRoot -ChildPath Apps\sacd_extract.exe

function List-SACDTrack
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory, 
            ValueFromPipeline,
            ValueFromPipelineByPropertyName, 
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias("FullName")]
        [String]
        $Path

    )

    Begin
    {

    }
    Process
    {
        #Read and store the raw output from sacd.exe
        $iso_output = &$SACD   -P -i"$Path"
    
        $sacd_Info = Split-Path -Path $Path -Parent | Join-Path -ChildPath 'SACD_Info.txt'
        Write-Verbose "Writing SACD Info to:`t [$sacd_info]"
        $iso_output | Out-File -LiteralPath $sacd_Info -Force -ErrorAction Stop

        #Parse the raw output from sacd_extract.exe
        $Album = ($iso_output | Select-String  -Pattern "Title:\s+" | select -ExpandProperty Line -First 1).split(":")[1].trim()
        $Artist = ($iso_output | Select-String  -Pattern "Artist:\s+" | select -ExpandProperty Line -First 1).split(":")[1].trim()
        $TrackCount = ($iso_output | Select-String  -Pattern "Track Count:\s+" | select -ExpandProperty Line -First 1).split(":")[1].trim()
        $Channels = ($iso_output | Select-String  -Pattern "(?<=Speaker config:\s)\d\sChannel" | select -ExpandProperty Matches | select -ExpandProperty value) -join ',' -replace ' Channel'
        $TrackList = ($iso_output | Select-String  -Pattern "(?<=Title\[\d\]:\s).*" | select -ExpandProperty Matches | select -ExpandProperty value -Unique)

        #Create custom objects for each track
        $TrackList | ForEach-Object -Begin {$i = 1} -process {
  
            [Pscustomobject]@{
                Count    = $i
                Track    = (Get-Culture).TextInfo.ToTitleCase($_.ToLower())
                Artist   = (Get-Culture).TextInfo.ToTitleCase($Artist.ToLower())
                Album    = (Get-Culture).TextInfo.ToTitleCase($Album.ToLower())
                Channels = $Channels
            }
            $i++

        } -End {$i = 1} 
    }
    End
    {
    }
}



function Extract-SACDTrack
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory, 
            ValueFromPipeline,
            ValueFromPipelineByPropertyName, 
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias("FullName")]
        [String]
        $Path,
        
        [String]
        $Destination,        
        
        [ValidateSet('Two', 'Multi')]
        [String]
        $Channels = 'Two',
        
        [ValidateSet('PhilipsDSDIFF', 'PhilipsDSDIFF_EditMaster', 'SonyDSF', 'RAWISO')]
        [String]
        $OutputFormat = 'PhilipsDSDIFF',
               
        [Switch]
        $ConvertDSTtoDSD,     
        
        [Switch]
        $ExportCueSheet,
        
        [Switch]
        $ShowTrackInfo             

    )

    Begin
    {

    }
    Process
    {
      
        if ([string]::IsNullOrEmpty($Destination))
        {
            $dest = Split-Path -Path $Path -Parent
            Push-Location -LiteralPath $dest
            $SACD_New = Split-Path -Path $Path -Parent | Join-Path -ChildPath 'sacd_extract.exe'
        }
        Else
        {
            if (-not (Test-Path -LiteralPath $Destination))
            {
                $null = New-Item -Path $Destination -ItemType Directory -Force
            }
          
            $dest = $Destination
            Push-Location -LiteralPath $Destination
            $SACD_New = Join-Path -Path $Destination -ChildPath 'sacd_extract.exe'
        
        }
        
        # COpy sacd_extract.exe to the output directory.
        Copy-Item -Path $SACD -Destination $SACD_New -Force -ErrorAction Stop
      
      
      
        Switch ($Channels)
        {
            'Two' {$ch = '-2'}
            'Multi' {$ch = '-m'}
            default {$ch = '-2'}
    
        }
      
        Switch ($OutputFormat)
        {
            'PhilipsDSDIFF' {$of = '-p'}
            'PhilipsDSDIFF_EditMaster' {$of = '-e'}
            'SonyDSF' {$of = '-s'}
            'RAWISO' {$of = '-I'}
            default {$of = '-p'}
    
        }
      
          
        $SACD_Args = [arraylist]::new()
        $null = $SACD_Args.Add($ch)
        $null = $SACD_Args.Add($of)

        if ($ConvertDSTtoDSD)
        {
            $null = $SACD_Args.Add('-c')
        }
      
        if ($ExportCueSheet)
        {
            $null = $SACD_Args.Add('-C')
        }
      
        if ($ShowTrackInfo)
        {
            $null = $SACD_Args.Add('-P')
        }   
      
        $null = $SACD_Args.Add("-i`"$path`"")   
      
        
        Write-Verbose ("Source File:`t[{0}]" -f $Path )
        Write-Verbose ("Output Directory:`t[{0}]" -f $dest )
        Write-Verbose ("Commandline:`t[{0}]" -f ($SACD_Args -join ','))
        
        
        # Run the extraction
        &$SACD_New $SACD_Args
      
        # Clean-up. Remove the sacd_extract.exe binary from the output Directory
        Remove-Item -LiteralPath $SACD_New -Force
      
        Pop-Location
      

    }
    End
    {
    }
}
