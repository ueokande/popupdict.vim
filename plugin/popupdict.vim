let s:save_cpo = &cpoptions
set cpoptions&vim

scriptencoding utf-8

" if exists('g:loaded_popupdict')
"     finish
" endif
let g:loaded_popupdict = 1

let g:popup_width = 60
let g:popupdict_enabled = 1

let s:lines = readfile(expand("<sfile>:h") . "/dict.json")
let s:dictionary = json_decode(s:lines[0])
let s:lines = readfile(expand("<sfile>:h") . "/verbs.json")
let s:verbs = json_decode(s:lines[0])

function! s:get_means(word)
  let simple = get(s:verbs, a:word)
  if simple == a:word
    let ja = get(s:dictionary, a:word)
    if ja == '0'
      return []
    endif
    return [[a:word, ja]]
  endif

  let ja_orig = get(s:dictionary, a:word)
  let ja_simple = get(s:dictionary, simple)
  if ja_orig != '0' && ja_simple != '0'
    return [[a:word, ja_orig], [simple, ja_simple]]
  elseif ja_orig != '0'
    return [[a:word, ja_orig]]
  elseif ja_simple != '0'
    return [[simple, ja_simple]]
  endif
  return []
endfunction

function! s:show_popup_dict()
  if !g:popupdict_enabled
    return
  endif
  popupc

  let en = tolower(expand("<cword>"))
  let means = s:get_means(en)
  if len(means) == 0
    return
  endif

  let texts = []
  for pair in means
    call add(texts, pair[0])
    call add(texts, pair[1])
    call add(texts, "")
  endfor
  if texts[-1] == ""
    let texts = texts[:len(texts)-2]
  endif

  let col = getpos('.')[2]
  let winw = winwidth(0)
  if col + g:popup_width + 1 > winw
    let col = winw - g:popup_width - 1
  endif

  let winid = popup_create(texts, {
        \ "line": "cursor+1",
        \ "col": col,
        \ "pos":"topleft",
        \ "maxwidth": g:popup_width,
        \ "border": [1, 1, 1, 1],
        \ 'borderchars': [' ',' ',' ',' ',' ',' ',' ',' '],
        \ "moved": "word",
        \ })
  call winbufnr(winid)
endfunction

autocmd CursorMoved * call s:show_popup_dict()

let &cpoptions = s:save_cpo
unlet s:save_cpo
