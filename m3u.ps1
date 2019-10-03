Function getMetaDataProperties() {
    param($filter)
    $properties = @{}
    $first = (Get-ChildItem -Recurse -Include $filter | Select-Object -First 1)
    If($first) {
        $firstFolder = Split-Path($first.FullName)
        $objShell = New-Object -ComObject Shell.Application
        $objFolder = $objShell.namespace($firstFolder)
        $n = 0
        For($n = 0; $n -Lt 500; $n++) {
            $property = $objFolder.GetDetailsOf($first, $n)
            If($property) {
                $properties[$property] = $n
            }
        }
    }
    If(!$properties.count) { $properties = $null }
    Return $properties
}
Function getMetaDataValues() {
    Param($file, $properties)
    $values = @{}
    If(Test-Path -LiteralPath $file -PathType Leaf) {
        $item = (Get-ChildItem -LiteralPath $file | Select-Object -First 1)
        If($item -And $properties) {
            $objShell = New-Object -ComObject Shell.Application
            $itemFolder = Split-Path($item.FullName)
            $shellFolder = $objShell.namespace($itemFolder)
            $file = Split-Path($file) -Leaf
            $shellFile = $shellFolder.ParseName($file)
            ForEach($key in $properties.Keys) {
                $values[$key] = $shellFolder.GetDetailsOf($shellFile, $properties.$key)
            }
        }
    }
    If($values.count -Eq 0) { $values = $null }
    Return $values
}

$allProperties = getMetaDataProperties '*.mp3'
$extinfProperties = @{
    'Length' = $allProperties['Length']
    'Album artist' = $allProperties['Album artist']
    'Title' = $allProperties['Title']
}

If($args[0] -is [int]) {
    # List mp3 files created some number of days ago or later:
    $daysAgo = (Get-Date).AddDays(-$args[0])
    $items = Get-ChildItem -Recurse -Include *.mp3 | Where-Object { $_.CreationTime -gt $daysAgo }
}
ElseIf($args[0] -is [string]) {
    # List mp3 files where the full path/name match a string:
    $searchString = $args[0]
    $items = Get-ChildItem -Recurse -Include *.mp3 | Where-Object { [Regex]::Escape($_.FullName) -match "$searchString" }
}
Else {
    # No search criterion; list all mp3 files.
    $items = Get-ChildItem -Recurse -Include *.mp3
}

ForEach($item in $items) {
    $values = getMetaDataValues $item.FullName $extinfProperties
    If($values) {
        $multiplier = 3600
        $pieces = $values['Length'] -Split ':'
        $seconds = 0
        ForEach($piece in $pieces) {
            $seconds += [int]$piece * $multiplier
            $multiplier /= 60
        }
        $artist = $values['Album artist']
        $title = $values['Title']
    }
    Else {
        $seconds = '?'
        $artist = '?'
        $title = '?'
    }
    Write-Host "#EXTINF:$seconds,$artist - $title"
    Write-Host $item.FullName
}
