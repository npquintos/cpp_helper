set splitright
" map <silent> <leader>h :call CreateHeader()<cr><cr>
" map <silent> <leader>d :call CreateCode()<cr><cr>
" map <silent> <leader>c :call ExtractClass()<cr>

" When programming in C++, you always have to do something like
" std::cout << "string" << std::endl;
" typing ;p will give you
" std::cout << "<cursor here>" << std::endl;
map <leader>p astd::cout << "xxx" << std::endl;<ESC>?xxx<CR>cw
imap <leader>p <ESC>astd::cout << "xxx" << std::endl;<ESC>?xxx<CR>cw

" It is also uncommon that you have something like
" std::cout << "string<cursor anywhere here>" << std::endl;
" and your cursor is in the string portion, and you want to
" add variables to be printed as well after it. Using
" ;a will result to
" std::cout << "string" << <cursor here>  << std::endl;
map <Leader>a /std<CR>ixxx << <ESC>?xxx<CR>cw
imap <Leader>a <ESC>/std<CR>ixxx << <ESC>?xxx<CR>cw

" Best practice for for loop
imap <Leader>f for(const auto &value: container) {
}<ESC>?container<CR>cw

" Will create header files for header name under the cursor
function! CreateHeader()
    let mycurf=expand("<cfile>")
    let g:bliss_class = substitute(mycurf, ".h", "", "")
    if empty(glob('../include/'.mycurf))
        let l:contents = [ 
                \ '#ifndef __' . g:bliss_class . '__h',
                \ '#define __' . g:bliss_class . '__h',
                \ 'namespace qbliss {',
                \ '',
                \ 'class ' . g:bliss_class . ' {',
                \ '    private:',
                \ '',
                \ '    public:',
                \ '        // Default constructor',
                \ '        ' . g:bliss_class . '();',
                \ '        // Parameterized constructor',
                \ '        ' . g:bliss_class . '();',
                \ '        // Getter',
                \ '        T GetValue() const;',
                \ '        // Setter',
                \ '        void SetValue(T value);',
                \ '        // Copy Constructor',
                \ '        ' . g:bliss_class . '(const '.g:bliss_class.' &rhs);',
                \ '        // Move Constructor',
                \ '        ' . g:bliss_class . '('.g:bliss_class.' &&rhs);',
                \ '        // Copy assignment',
                \ '        ' . g:bliss_class . ' &operator=(const '.g:bliss_class.' &rhs);',
                \ '        // Move assignment',
                \ '        ' . g:bliss_class . ' &operator=('.g:bliss_class.' &&rhs);',
                \ '        // Destructor',
                \ '        virtual ~' . g:bliss_class . '();',
                \ '        // Increment by 1 and return reference',
                \ '        //' . g:bliss_class . ' &operator++();',
                \ '        // Increment by 1 and return object',
                \ '        //' . g:bliss_class . ' operator++();',
                \ '        // Equality Comparison',
                \ '        //bool operator==(const '.g:bliss_class.' &rhs) const;',
                \ '        // Addition',
                \ '        //const '.g:bliss_class.' operator+(const '.g:bliss_class.' &rhs) const;',
                \ '        // Subtraction',
                \ '        //const '.g:bliss_class.' operator-(const '.g:bliss_class.' &rhs) const;',
                \ '        // Compound Increment',
                \ '        //'.g:bliss_class.' &operator+=(const '.g:bliss_class.' &rhs);',
                \ '        // Compound Decrement',
                \ '        //'.g:bliss_class.' &operator-=(const '.g:bliss_class.' &rhs);',
                \ '        // Compound multiply',
                \ '        //'.g:bliss_class.' &operator*=(const '.g:bliss_class.' &rhs);',
                \ '        // Compound divide',
                \ '        //'.g:bliss_class.' &operator/=(const '.g:bliss_class.' &rhs);',
                \ '        // Function operator',
                \ '        //void operator()();',
                \ '',
                \ '};',
                \ '',
                \ '} // end of namespace qbliss',
                \ '#endif // __' . g:bliss_class . '__h'
            \]
        call writefile(l:contents, '../include/'.mycurf)
    endif
    if bufwinnr('../include/'.mycurf) < 0
        execute("vsp ../include/".mycurf)
        normal! <C-h>
    endif
endfunction

function! ExtractClass()
    let curpos = getpos('.')
    execute "normal! ?class\<cr>w\"cye"
    let g:bliss_class = Strip(@c)
    call setpos('.', curpos)
endfunction

" Will create the file that implements the methods in a class
function! CreateCode() range
    let l:lines = []
    for linenum in range(a:firstline, a:lastline)
        let l:line = getline(linenum)
        call add(l:lines, Strip(l:line))
    endfor
    let l:fin = "../src/" . g:bliss_class. ".cpp"
    if !empty(glob(l:fin))
        let l:oldFile = readfile(l:fin)
    else
        let l:oldFile = ['#include "'.g:bliss_class.'.h"', 'namespace qbliss {', '', '} // namespace qbliss']
    endif
    let l:newFile = l:oldFile[:-3]
    let l:old_func_headings = GetFuncHeadings(l:oldFile)
    for l:line in l:lines
        if LineIsInList(l:old_func_headings, l:line)
            continue
        endif
        if l:line =~ '^\s*//'
            call add(l:newFile, '')
            call add(l:newFile, l:line)
            continue
        endif
        let l:fd =  FunctionDef(l:line)
        if len(l:fd) != 0
            let l:newFile = l:newFile + l:fd
        endif
    endfor
    call add(l:newFile, '')
    call add(l:newFile, l:oldFile[-1])
    call writefile(l:newFile, l:fin)
    if bufwinnr('../src/'.l:fin) < 0
        execute("sp ../src/".l:fin)
        normal! <C-k>/todo<cr>
    endif
endfunction

function! LineIsInList(lineList, line)
    if len(a:lineList) != 0
        let l:line = substitute(a:line, '\~'.g:bliss_class, '\\~'.g:bliss_class, '')
        let l:line = substitute(a:line, 'operator\*=(', 'operator\\*=(', '')
        for l:row in a:lineList
            if l:row =~ l:line
                return 1
            endif
        endfor
    endif
    return 0
endfunction

" Extract all function definitions from a cpp file and
" translate them into function declarations. If you have
" something like
" int Date::day() {
"    return d;
" }
" it will be extracted as 'int day();'
" #include and namespace lines are ignored.
function! GetFuncHeadings(lines)
    let l:result = []
    for l:line in a:lines
        if l:line =~? '^\s\+'
            continue
        endif
        if l:line =~? '^#.\+'
            continue
        endif
        if l:line =~? '^}'
            continue
        endif
        if l:line =~? '^namespace'
            continue
        endif
        if l:line =~? '^$'
            continue
        endif
        call add(l:result, CleanLine(l:line))
    endfor
    return l:result
endfunction

" convert int& Cat::move(float v) const {
" into int& move(float v) const;
" or Date::Date(int yy, int mm, int dd): y{yy}, m{mm}, d{dd} {
" into Date(int yy, int mm, int dd);
function! CleanLine(line)
    let l:clean1 = substitute(Strip(a:line), g:bliss_class.'::', '', '')
    let l:clean2 = split(l:clean1, ':')
    if len(l:clean2) == 2
        return l:clean2[0].';'
    else
        return substitute(l:clean1, ' {', ';', '')
    endif
endfunction

function! Strip(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

" convert int& move(float v) const; which is a method of class Cat into
" int& Cat::move(float v) const {
" }
function!  FunctionDef(line)
    let l:result = []
    let ll = split(Strip(a:line), 'operator')
    if len(ll) == 2
        let l:temp = ll[0].g:bliss_class.'::operator'.ll[1].' {'
    else 
        let ll = split(Strip(a:line), '(')
        if len(ll) != 2
            return ['']
        endif
        let l:first = split(ll[0])
        if len(l:first[:-2]) == 0
            let l:temp = g:bliss_class.'::'.l:first[-1].'('.ll[1].' {'
        else
            let l:temp = join(l:first[:-2], ' ').' '.g:bliss_class.'::'.l:first[-1].'('.ll[1].' {'
        endif
    endif
    call add(l:result, substitute(l:temp, ';', '', ''))
    if l:temp =~ 'operator=(const '
        call add(l:result, '    if (this == &rhs)')
        call add(l:result, '        return *this;')
        call add(l:result, '')
        call add(l:result, '    // deallocate, allocate new space, copy values')
        call add(l:result, '')
        call add(l:result, '    return *this')
    elseif l:temp =~ 'operator=('.g:bliss_class
        call add(l:result, '    if (this == &rhs)')
        call add(l:result, '        return *this;')
        call add(l:result, '')
        call add(l:result, '    // deallocate, allocate new space, copy values')
        call add(l:result, '')
        call add(l:result, '    return *this')
    elseif l:temp =~ '\~'.g:bliss_class
        call add(l:result, '    // deallocate resources')
        call add(l:result, '    delete ptr;')
    elseif l:temp =~ 'operator==(const '
        call add(l:result, '    // compare and return bool result')
    elseif l:temp =~ 'operator!=(const '
        call add(l:result, '    return !(*this == rhs);')
    elseif l:temp =~ 'operator+(const '
        call add(l:result, '    '.g:bliss_class.' result = *this;')
        call add(l:result, '    result += rhs;')
        call add(l:result, '    return result;')
    elseif l:temp =~ 'operator-(const '
        call add(l:result, '    '.g:bliss_class.' result = *this;')
        call add(l:result, '    result -= rhs;')
        call add(l:result, '    return result;')
    elseif l:temp =~ 'operator\*(const '
        call add(l:result, '    '.g:bliss_class.' result = *this;')
        call add(l:result, '    result *= rhs;')
        call add(l:result, '    return result;')
    elseif l:temp =~ 'operator\/(const '
        call add(l:result, '    '.g:bliss_class.' result = *this;')
        call add(l:result, '    result /= rhs;')
        call add(l:result, '    return result;')
    elseif l:temp =~ 'operator+=(const '
        call add(l:result, '    // do compound addition work')
        call add(l:result, '')
        call add(l:result, '    return *this;')
    elseif l:temp =~ 'operator-=(const '
        call add(l:result, '    // do compound subtraction work')
        call add(l:result, '')
        call add(l:result, '    return *this;')
    elseif l:temp =~ 'operator\*=(const '
        call add(l:result, '    // do compound multiplication work')
        call add(l:result, '')
        call add(l:result, '    return *this;')
    elseif l:temp =~ 'operator\/=(const '
        call add(l:result, '    // do compound division work')
        call add(l:result, '')
        call add(l:result, '    return *this;')
    elseif l:temp =~ 'operator++('
        call add(l:result, '    // implement your increment operation')
        call add(l:result, '')
        call add(l:result, '    return *this;')
    else
        call add(l:result, '    // todo')
    endif
    call add(l:result, "}")
    return l:result
endfunction
