# cpp_helper
This is a vim plugin to automatically create the header files for classes and their corresponding cpp implementation.

For this to work, you need to have the following directory hierarchy:
```
<Project Name>
    |
    +----src
    |     +-----main.cpp <-- This is where you are placing the #include "MyClass.h"
    |     +----- MyClass.cpp  <---- will be created when you type <leader>d while inside MyClass.h
    +----include
           +---- MyClass.h  <--- will automatically be created here after pressing <leader>h with the cursor at "MyClass.h" while editing main.cpp
```
So, you have a dedicated project directory and underneath this will be the "src" directory and "include" directory as shown above. Your
"main.cpp" will be located at the "src" directory. When you edit this "main.cpp" and added the line **#include "MyClass.h"**, you could
place the cursor anywhere in the "MyClass.h" word and then hit <leader>h. This will then create "MyClass.h" header file under the "include"
directory, and then open that file in a split pane, ready for editing. Skeletal contents are automatically created.
    
If you move your cursor in the "MyClass.h" file, press <leader>c to capture the class name in the "c" register. Then, you could visually 
line select a function definition, press <leader>d to define this function in "MyClass.cpp" file. "MyClass.cpp" file is automatically created
under the "src" directory with this action. It create a skeleton function, ready to be filled-up.
  
  At this point, you have 3 panes open in vim: main.cpp, MyClass.h, and MyClass.cpp
