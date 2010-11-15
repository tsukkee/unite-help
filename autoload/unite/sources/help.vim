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
\   'max_candidates': 30,
\   'action_table': {},
\   'default_action': {'word': 'lookup'}
\}
function! s:source.gather_candidates(args, context)
    if empty(s:cache)
        let tagfiles = split(globpath(&runtimepath, 'doc/{tags,tags-*}'), "\n")
        for tagfile in tagfiles
            if !filereadable(tagfile) | continue | endif

            for line in readfile(tagfile)
                let name = split(line, "\t")[0]

                " if not comment line
                if stridx(name, "!") != 0
                    call add(s:cache, {
                    \   'word':     name,
                    \   'abbr':     name,
                    \   'kind':     'word',
                    \   'source':   'help',
                    \   'action__word':      name,
                    \   'action__is_insert': 0
                    \})
                endif
            endfor
        endfor
    endif

    let is_insert = {'action__is_insert', a:context.is_insert}
    call map(s:cache, 'extend(v:val, is_insert)')

    return s:cache
endfunction


" action
let s:action_table = {}

let s:action_table.lookup = {
\   'description': 'lookup help'
\}
function! s:action_table.lookup.func(candidate)
    execute "help" a:candidate.word
endfunction

let s:action_table.tabopen = {
\   'description': 'open help in a new tab'
\}
function! s:action_table.tabopen.func(candidate)
    execute "tab help" a:candidate.word
endfunction

let s:source.action_table.word = s:action_table

