#include <stdio.h>
#include "include/split.hpp"
#include <iostream>
#include <string>
#include <vector>
#include <cstring>

int main()
{
    std::vector<std::string> s{std::string("abcdFirstabcdSecondabcdThirdabcd"), std::string("FirstabcdSecondabcdThirdabcd"), std::string("abcdFirstabcdSecondabcdThird"), std::string("FirstabcdSecondabcdThird"), std::string("abc")};
    std::cout << "Using std::string --  ########" << std::endl;
    for (auto line : s) {
        std::cout << "####### "<< line << " ########" << std::endl;
        for (auto word : Qstring(line).split("abcd")) {
             std::cout << ">" << word << "<" << std::endl;
        }
    }

    std::cout << "Using std::string --  and string_view for delimeter" << std::endl;
    std::string_view delim{"abcd"};
    for (auto line : s) {
        std::cout << "####### "<< line << " ########" << std::endl;
        for (auto word : Qstring(line).split(delim)) {
             std::cout << ">" << word << "<" << std::endl;
        }
    }
    
    const char *test = "abcdFirstabcdSecondabcdThirdabcd";
    std::cout << "Using C-string -- " << test << " ########" << std::endl;
    for (auto word : Qstring(test).split("abcd")) {
             std::cout << ">" << word << "<" << std::endl;
    }
}
