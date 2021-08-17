Function Get-FastDirSize ($Directory) {
  
    $Size = ((robocopy.exe $Directory \localhostC$nul /L /XJ /R:0 /W:1 /NP /E /BYTES /nfl /ndl /njh /MT:64)[-4]`
                -replace '\D+(\d+).*','$1') /1MB -as [int]

    [pscustomobject]@{Directory="$Directory";Size="$Size"}

}