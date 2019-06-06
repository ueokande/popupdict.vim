let s:save_cpo = &cpoptions
set cpoptions&vim

scriptencoding utf-8

" if exists('g:loaded_popupdict')
"     finish
" endif
" let g:loaded_popupdict = 1

" let s:lines = readfile(expand('plugin/dict.json'))
let s:lines = readfile(expand('plugin/dict.json'))
let s:dictionary = json_decode(s:lines[0])

let s:lines = readfile(expand('plugin/verbs.json'))
let s:verbs = json_decode(s:lines[0])

let s:popup_width = 60

function! s:show_popup_dict()
  popupc

  let en = tolower(expand("<cword>"))
  let simple = get(s:verbs, en)
  if simple == '0'
    let simple = en
  endif

  let ja = get(s:dictionary, simple)
  if ja == '0'
    return
  endif

  let col = getpos('.')[2]
  let winw = winwidth(0)
  if col + s:popup_width + 1 > winw
    let col = winw - s:popup_width - 1
  endif

  let winid = popup_create(ja, {
        \ "line": "cursor+1",
        \ "col": col,
        \ "pos":"topleft",
        \ "maxwidth": s:popup_width,
        \ "border": [1, 1, 1, 1],
        \ "moved": "word",
        \ })
  call winbufnr(winid)
endfunction

autocmd CursorMoved * call s:show_popup_dict()

let &cpoptions = s:save_cpo
unlet s:save_cpo
