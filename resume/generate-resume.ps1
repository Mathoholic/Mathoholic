# Generate resume PDF from resume.tex using XeLaTeX

Write-Host "Generating resume PDF..." -ForegroundColor Green

$outputFile = "output\Shantanu_Sharma_Resume.pdf"

# Find XeLaTeX or LuaLaTeX
$pdfEngine = ""
foreach ($engine in @("xelatex", "lualatex")) {
    try {
        $null = Get-Command $engine -ErrorAction Stop
        $pdfEngine = $engine
        Write-Host "Using $engine" -ForegroundColor Cyan
        break
    } catch {}
}

if ($pdfEngine -eq "") {
    Write-Host "Error: xelatex or lualatex not found. Install MiKTeX or TeX Live." -ForegroundColor Red
    exit 1
}

# Compile resume.tex directly
& $pdfEngine -interaction=nonstopmode -output-directory=output resume.tex | Out-Null
Copy-Item -Force "output\resume.pdf" $outputFile -ErrorAction SilentlyContinue
Remove-Item "output\resume.log","output\resume.aux","output\resume.out" -Force -ErrorAction SilentlyContinue

if (Test-Path $outputFile) {
    Write-Host "Resume PDF generated: $outputFile" -ForegroundColor Green
} else {
    Write-Host "Error generating PDF" -ForegroundColor Red
}