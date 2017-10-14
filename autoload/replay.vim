" Copyright 2016-present Greg Hurrell. All rights reserved.
" Licensed under the terms of the MIT license.

let s:registers={}
let s:last_register=''
let s:is_recording=0

function! s:StoreAndCheckRegisters() abort
  let l:last_register=0
  for l:register in g:ReplayNamedRegisters
    let l:contents=getreg(l:register, 1, 1)
    if has_key(s:registers, l:register)
      \ && s:registers[l:register] != l:contents
      \ && !l:last_register
      let s:last_register=l:register
      let l:last_register=1
    endif
    let s:registers[l:register] = l:contents
  endfor
endfunction

" Function called whenever we stop and start recording a macro.
function! replay#spy_on_registers() abort
  let s:is_recording=!s:is_recording
  call s:StoreAndCheckRegisters()
  return 'q'
endfunction

" Function called when user presses <CR> to repeat last macro.
function! replay#repeat_last_macro() abort
  try
    if s:is_recording | return | endif
    if s:last_register == '' | let s:last_register = 'q' | endif
    call feedkeys('@' . s:last_register, 'n')
  catch /E132/ " Function call depth is higher than 'maxfuncdepth'
    echomsg "Hit 'maxfuncdepth'."
  endtry
endfunction

" Function called when user presses @<named_register> to play a macro.
function! replay#play_macro(register) abort
  call feedkeys('@' . a:register, 'n')
  if !s:is_recording
    let s:last_register=a:register
  end
endfunction
