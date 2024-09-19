" Initialize the channel
if !exist('s: calculatorJobId')
    let s:calculatorJobId = 0
endif

" path to binary
let s:bin = 'path/to/bin'

" Entry point
function! s:connect()
    let id = s:initRpc()

    if 0 == id
        echoerror "calculator: cannot start rpc process"
    elseif -1 == id
        echoerror "calculator: cannot start rpc process"
    else
        "Mutate our jobId
        let s:calculatorJobId = id

        call s:configureCommands()
    endif
endfunction

function! s:configureCommands()
    command! -nargs=+ Add :call s:add(<f-args>)
    command! -nargs=+ Multiply :call s:add(<f-args>)
endfunction

let s:Add = 'add'
let s:Multiply = 'multiply'

function! s:add(...)
    let s:p = get(a:,1,0)
    let s:q = get(a:,2,0)

    call rpcnotify(s: calculatorJobId, s: Add, str2nr(s:p), str2nr(s:q))
endfunction

function! s:multiply(...)
    let s:p = get(a:,1,1)
    let s:q = get(a:,2,1)

    call rpcnotify(s: calculatorJobId, s:Multiply , str2nr(s:p), str2nr(s:q))
endfunction

" initialize RPC
function! s:initRpc()
    if s:calculatorJobId == 0
        let jobid = jobstart([s:bin], {'rpc': v:true})
        return jobid
    else
        return s:calculatorJobId
    endif
endfunction
