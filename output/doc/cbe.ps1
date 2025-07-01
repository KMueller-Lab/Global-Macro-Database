foreach ($file in Get-ChildItem -Filter "*.tex") {
    $basename = $file.BaseName
    if ($basename -match '^[s-z]') {
        Write-Host "Processing $basename..."

        lualatex -interaction=batchmode -halt-on-error "$basename.tex"
        bibtex "$basename"
        lualatex -interaction=batchmode -halt-on-error "$basename.tex"
        lualatex -interaction=batchmode -halt-on-error "$basename.tex"

        Write-Host "Completed $basename"
        Write-Host "------------------------"
    }
}