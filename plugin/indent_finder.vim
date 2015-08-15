if !exists('g:indent_finder_default_style')
  let g:indent_finder_default_style = "space"
endif
if !exists('g:indent_finder_default_width')
  let g:indent_finder_default_width=4
endif

" global aliases to internal functions, so users can manually trigger a load
fun! g:IndentFinderLoad()
    call s:IndentFinderLoad()
endfun

fun! g:IndentFinderApply()
    call s:IndentFinderApply()
endfun

let s:root_path = expand('<sfile>:p:h:h')
fun! s:IndentFinderLoad()
    let b:indent_finder_result = ""
    let b:indent_finder_error = ""
    let l:filename=expand("%:p")
    if &buftype != "" || !filereadable(l:filename)
        " not a file buffer
        return
    endif

    let l:cmd="python \"". s:root_path . "/indent_finder.py\""
                \. " --vim-output "
                \. " --default-style=".g:indent_finder_default_style
                \. " --default-width=".g:indent_finder_default_width
                \. " ". shellescape(l:filename)
    let l:result =  system(l:cmd)

    " uncomment the following line to see what indent_finder returned
    " echo "Indent Finder result: " . b:indent_finder_result

    if v:shell_error
        echoerr "Indent_finder failed with status " . v:shell_error
        let b:indent_finder_error=l:result
        return
    else
        let b:indent_finder_result=l:result
    endif
    call s:IndentFinderApply()
endfun

fun! s:IndentFinderApply()
    if b:indent_finder_result != ""
        execute b:indent_finder_result
    endif
endfun

augroup IndentFinder
    au!
    au BufReadPost * call <SID>IndentFinderLoad()
augroup End
