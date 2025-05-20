" Navigate between source under test and test files
" Last Change:	2025-04-28
" Maintainer:	Adam McKee <adam.be.g84d@gmail.com>
" Repository:   https://github.com/eighty4/testnav.vim

if exists("g:loaded_testnav") || v:version < 700 || &cp
  finish
endif
let g:loaded_testnav = 1

"if !hasmapto('<Plug>TestNav;')
"  map <unique> <Leader>tn <Plug>TestNav;
"endif

let s:found_lookups = {}

function s:TestNavEmptyCache()
  let l:s = "Removed " . len(s:found_lookups) . " cached lookups"
  call empty(s:found_lookups)
  echo l:s
endfunction

function s:TestNavViewCache()
  let l:printed = []
  for k in keys(s:found_lookups)
    if index(l:printed, k) == -1
      let v = s:found_lookups[k]
      echo k
      echo " <-> " . v
      call add(l:printed, v)
    endif
  endfor
endfunction

function s:TestNav()
  let l:buf_name = nvim_buf_get_name(0)

  if has_key(s:found_lookups, l:buf_name)
    let l:lookup = s:found_lookups[l:buf_name]
    if filereadable(lookup)
      execute "edit " . lookup
      return
    else
      call remove(s:found_lookups, l:buf_name)
      call remove(s:found_lookups, lookup)
    endif
  endif

  if s:TryLookups(s:JS(l:buf_name)) == 1
    return
  endif

  echo "No source <-> test nav found."
endfunction

function s:TryLookups(lookups)
  if !empty(a:lookups)
    for lookup in a:lookups
      if filereadable(lookup)
        let l:buf_name = nvim_buf_get_name(0)
        let s:found_lookups[l:buf_name] = lookup
        let s:found_lookups[lookup] = l:buf_name
        execute "edit " . lookup
        return 1
      endif
    endfor
  endif
  return 0
endfunction

function s:JS(buf_name)
  let l:buf_ext = v:null
  if a:buf_name=~".ts$"
    let l:buf_ext = "ts"
    let l:lookup_exts = ["ts", "js", "mjs", "cjs"]
  elseif a:buf_name=~".tsx$"
    let l:buf_ext = "tsx"
    let l:lookup_exts = ["tsx", "jsx"]
  elseif a:buf_name=~".js$"
    let l:buf_ext = "js"
    let l:lookup_exts = ["js", "mjs", "cjs", "ts"]
  elseif a:buf_name=~".jsx$"
    let l:buf_ext = "jsx"
    let l:lookup_exts = ["jsx", "tsx"] 
  elseif a:buf_name=~".mjs$"
    let l:buf_ext = "mjs"
    let l:lookup_exts = ["mjs", "js", "ts", "cjs"]
  elseif a:buf_name=~".cjs$"
    let l:buf_ext = "cjs"
    let l:lookup_exts = ["cjs", "js", "ts", "mjs"]
  endif
  if l:buf_ext is v:null
    return v:null
  endif

  if a:buf_name=~".spec." .. l:buf_ext .. "$"
    let l:buf_pat = ".spec." .. l:buf_ext
    return s:MatrixBufName(a:buf_name, "spec." .. l:buf_ext, l:lookup_exts)
  elseif a:buf_name=~".test." .. l:buf_ext .. "$"
    return s:MatrixBufName(a:buf_name, "test." .. l:buf_ext, l:lookup_exts)
  else
    let l:lookup_test_exts = map(copy(l:lookup_exts), '".spec." .. v:val')
                \ + map(l:lookup_exts, '".test." .. v:val')
    return s:MatrixBufName(a:buf_name, "." .. l:buf_ext, l:lookup_test_exts)
  endif
endfunction

function s:MatrixBufName(buf_name, m, rn)
  return map(a:rn, 'substitute(a:buf_name, a:m, v:val, "")')
endfunction

if !exists(":TestNav")
  command -nargs=0 TestNav :call s:TestNav()
endif

if !exists(":TestNavEmptyCache")
  command -nargs=0 TestNavEmptyCache :call s:TestNavEmptyCache()
endif

if !exists(":TestNavViewCache")
  command -nargs=0 TestNavViewCache :call s:TestNavViewCache()
endif
