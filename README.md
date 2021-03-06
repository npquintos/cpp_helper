# cpp_helper
This is a vim plugin to automatically create the header files for classes and their corresponding cpp implementation.

For this to work, you need to have the following directory hierarchy:
```
<Project Name>
    |
    +----src
    |     +-----main.cpp <-- This is where you are placing the #include "MyClass.hpp"
    |     +----- MyClass.cpp  <---- will be created when you type <leader>d while inside MyClass.hpp
    +----include
           +---- MyClass.hpp  <--- will automatically be created here after pressing <leader>h with the cursor at "MyClass.hpp" while editing main.cpp
```
So, you have a dedicated project directory and underneath this will be the "src" directory and "include" directory as shown above. Your
"main.cpp" will be located at the "src" directory. When you edit this "main.cpp" and added the line **#include "MyClass.hpp"**, you could
place the cursor anywhere in the "MyClass.hpp" word and then hit \<leader\>h. This will then create "MyClass.hpp" header file under the "include"
directory, and then open that file in a split pane, ready for editing. Skeletal contents are automatically created.
    
If you move your cursor in the "MyClass.hpp" file, press \<leader\>c to capture the class name in the "c" register. Then, you could visually 
line select a function definition, press \<leader\>d to define this function in "MyClass.cpp" file. "MyClass.cpp" file is automatically created
under the "src" directory with this action. It create a skeleton function, ready to be filled-up.
  
  At this point, you have 3 panes open in vim: main.cpp, MyClass.hpp, and MyClass.cpp

To Summarize:
1.  Edit **main.cpp** (which should be inside the **src** directory) and add the entry **#include "MyClass.hpp"**
2.  Place cursor anywhere inside **MyClass.hpp** then press \<leader\>h --> this will create **MyClass.hpp** file in the **include** directory and open that header file.
3.  Move your cursor to the header file, press **\<leader\>c** to capture the class name, and then, highlight any lines (including line comments preceeding the function declaration), then press **\<leader\>c** --> this will create the **MyClass.cpp** function implementation under the **src** directory and open it. **MyClass.cpp** will contain skeleton function definitions for the highlighted lines in MyClass.hpp.
