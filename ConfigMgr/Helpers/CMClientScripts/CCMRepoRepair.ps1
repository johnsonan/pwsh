&cmd.exe /c net stop winmgmt /y
&cmd.exe /c winmgmt /resetrepository
&cmd.exe /c net start winmgmt /y
&cmd.exe /c C:\Windows\CCM\ccmrepair.exe