$env:UserName
$path = "\\SRV-AD-0422\" + $env:UserName + "$"
New-PSDrive -Name "Z" -Root $path -Persist -PSProvider "FileSystem"