# Generate resume PDF from markdown using Pandoc

Write-Host "Generating professional resume PDF..." -ForegroundColor Green

$outputFile = "output\Shantanu_Sharma_Resume.pdf"

# Check for LaTeX engines
$pdfEngine = ""
$engines = @("xelatex", "lualatex")

foreach ($engine in $engines) {
    try {
        $null = Get-Command $engine -ErrorAction Stop
        $pdfEngine = $engine
        Write-Host "Using $engine for professional typography" -ForegroundColor Cyan
        break
    } catch {
        # Continue to next engine
    }
}

if ($pdfEngine -eq "") {
    $pdfEngine = "C:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe"
    Write-Host "Using wkhtmltopdf with CSS styling" -ForegroundColor Yellow
}

# Generate PDF
if ($pdfEngine -eq "xelatex" -or $pdfEngine -eq "lualatex") {
    # LaTeX generation with metadata
    pandoc resume.md -o $outputFile --pdf-engine=$pdfEngine -V geometry:margin=0.5in -V fontsize=11pt -V colorlinks=true --metadata title="Shantanu Sharma - Resume"
} else {
    # Two-step process: HTML first, then PDF with explicit title
    $tempHtml = "temp-resume.html"
    pandoc resume.md -o $tempHtml --template=templates\simple-template.html --css=resume-style.css --metadata title="Shantanu Sharma - Resume"
    
    # Convert HTML to PDF with explicit title
    & "$pdfEngine" --page-size A4 --margin-top 5mm --margin-bottom 5mm --margin-left 8mm --margin-right 8mm --enable-local-file-access --print-media-type --title "Shantanu Sharma - Resume" $tempHtml $outputFile
    
    # Clean up temp file
    Remove-Item $tempHtml -Force
}

# Check result
if ($LASTEXITCODE -eq 0) {
    Write-Host "Resume PDF generated successfully: $outputFile" -ForegroundColor Green
    Write-Host "PDF Engine used: $pdfEngine" -ForegroundColor Cyan
} else {
    Write-Host "Error generating PDF" -ForegroundColor Red
}