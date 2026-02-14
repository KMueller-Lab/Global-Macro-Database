* ==============================================================================
* GLOBAL MACRO DATABASE
* by Karsten Müller, Chenzi Xu, Mohamed Lehbib, Ziliang Chen
* ==============================================================================
*
* COMPILE .TEX FILES TO PDF (Fast Parallel Version)
* 
* This runs the parallel LaTeX compilation with proper bibliography processing:
* lualatex → bibtex → lualatex → lualatex
* 
* Created: 2025-01-08
* 
* Author:
* Mohamed Lehbib
* National University of Singapore
* 	
* ==============================================================================


display as txt "==============================================================="
display as txt "FAST PARALLEL LATEX COMPILATION"
display as txt "==============================================================="
display as txt ""

* Verify we're in the correct directory
capture confirm file "compile_tex_parallel.sh"
if _rc != 0 {
    display as error "Error: Not in project root directory"
    display as error "compile_tex_parallel.sh not found"
    display as error "Please run from: Global-Macro-Database-Internal/"
    exit 601
}

* Count .tex files first
capture quietly shell find output/doc -name "*.tex" > temp_tex_count.txt
if _rc != 0 {
    display as error "Error: Cannot access output/doc directory"
    display as error "Make sure output/doc exists and contains .tex files"
    exit 601
}
* Count tex files safely
file open texcount using "temp_tex_count.txt", read
local tex_files = 0
file read texcount line
while r(eof) == 0 {
    if `"`line'"' != "" {
        local tex_files = `tex_files' + 1
    }
    file read texcount line
}
file close texcount

* Clean up temp file
capture rm "temp_tex_count.txt"

if `tex_files' == 0 {
    display as error "No .tex files found in output/doc/"
    display as error "Please generate documentation first"
    exit 601
}

display as txt "Found `tex_files' .tex files to compile"
display as txt ""

display as txt "Starting parallel compilation with bibliography processing..."
display as txt "Process: lualatex → bibtex → lualatex → lualatex"  
display as txt "This will take a few minutes..."
display as txt ""

* Run the compilation based on OS
display as txt "Operating System: `c(os)'"
display as txt ""

* Initialize return code
local shell_rc = 999

if "`c(os)'" == "Unix" {
    display as txt "Running parallel compilation script..."
    shell ./compile_tex_parallel.sh
    local shell_rc = _rc
}
else if "`c(os)'" == "MacOSX" {
    display as txt "Running parallel compilation script..."  
    shell ./compile_tex_parallel.sh
    local shell_rc = _rc
}
else {
    display as error "Windows not supported for automated compilation"
    display as error "Please run ./compile_tex_parallel.sh manually"
    exit 198
}

* Report results
display as txt ""
if `shell_rc' == 0 {
    display as txt "=============================================="
    display as txt "  COMPILATION COMPLETED!"
    display as txt "=============================================="
    display as txt "• Processed `tex_files' .tex files in parallel"
    display as txt "• Check tex_compilation_logs/ for detailed results"
    display as txt "• PDF files available in output/doc/"
    
    * Try to give more detailed feedback
    capture quietly shell grep -c "SUCCESS:" tex_compilation_logs/batch_*.log | head -1 > temp_success_count.txt
    if _rc == 0 {
        display as txt " Most files compiled successfully (check logs for details)"
    }
    capture rm "temp_success_count.txt"
    
    display as txt ""
}
else {
    display as error "✗ Compilation script failed (exit code: `shell_rc')"
    display as error "• This usually indicates a system or PATH issue"
    display as error "• Check tex_compilation_logs/ for detailed error information"
    display as error "• Try running ./compile_tex_parallel.sh directly"
    display as txt ""
}

display as txt "Fast parallel LaTeX compilation finished."
display as txt "Run again if you make changes to .tex files."
