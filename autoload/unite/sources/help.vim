" help source for unite.vim
" Version:     0.0.3
" Last Change: 15 Nov 2010
" Author:      tsukkee <takayuki0510 at gmail.com>
" Licence:     The MIT License {{{
"     Permission is hereby granted, free of charge, to any person obtaining a copy
"     of this software and associated documentation files (the "Software"), to deal
"     in the Software without restriction, including without limitation the rights
"     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
"     copies of the Software, and to permit persons to whom the Software is
"     furnished to do so, subject to the following conditions:
"
"     The above copyright notice and this permission notice shall be included in
"     all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
"     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
"     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
"     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
"     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
"     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
"     THE SOFTWARE.
" }}}

" define source
function! unite#sources#help#define()
    return s:source
endfunction


" cache
let s:cache = []
function! unite#sources#help#refresh()
    let s:cache = []
endfunction

" source
let s:source = {
\   'name': 'help',
\   'max_candidates': 50,
\   'required_pattern_length': 1,
\   'action_table': {},
\   'default_action': {'common': 'execute'}
\}
function! s:source.gather_candidates(args, context)
    let should_refresh = a:context.is_redraw
    let lang_filter = []
    for arg in a:args
        if arg == '!'
            let should_refresh = 1
        endif

        if arg =~ '[a-z]\{2\}'
            call add(lang_filter, arg)
        endif
    endfor

    if should_refresh
        call unite#sources#help#refresh()
    endif

    if empty(s:cache)
        for tagfile in split(globpath(&runtimepath, 'doc/{tags,tags-*}'), "\n")
            if !filereadable(tagfile) | continue | endif

            let lang = matchstr(tagfile, 'tags-\zs[a-z]\{2\}')
            let place = fnamemodify(expand(tagfile), ':p:h:h:t')

            for line in readfile(tagfile)
                let name = split(line, "\t")[0]
                let word = name . '@' . (!empty(lang) ? lang : 'en')
                let abbr = printf(
                      \ "%s%s (in %s)", name, !empty(lang) ? '@' . lang : '', place)

                " if not comment line
                if stridx(name, "!") != 0
                    call add(s:cache, {
                    \   'word':   word,
                    \   'abbr':   abbr,
                    \   'kind':   'common',
                    \   'source': 'help',
                    \   'action__command': 'help ' . word,
                    \   'source__lang'   : !empty(lang) ? lang : 'en'
                    \})
                endif
            endfor
        endfor
    endif

    return filter(copy(s:cache),
    \   'empty(lang_filter) || index(lang_filter, v:val.source__lang) != -1')
endfunction


" action
let s:action_table = {}

let s:action_table.execute = {
\   'description': 'lookup help'
\}
function! s:action_table.execute.func(candidate)
    let save_ignorecase = &ignorecase
    set noignorecase
    execute a:candidate.action__command
    let &ignorecase = save_ignorecase
endfunction

let s:action_table.tabopen = {
\   'description': 'open help in a new tab'
\}
function! s:action_table.tabopen.func(candidate)
    let save_ignorecase = &ignorecase
    set noignorecase
    execute 'tab' a:candidate.action__command
    let &ignorecase = save_ignorecase
endfunction

let s:source.action_table.common = s:action_table

