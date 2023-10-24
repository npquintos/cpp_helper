#include <cstring>
#include <iostream>
#include <vector>
#include <exception>
#include <string_view>

class Qstring {
    // Usage:
    // auto xsplit = Qstring(line).split(delimeter);
    // for (auto word : xsplit) {
    //      std::cout << word << std::endl
    // }
    // if 'word' is to be split, 'ptr' below will
    // hold the starting indexes of the start of
    // the word. 'word' will then be modified to
    // be delimited with \0. For example, say you have
    // this word and you want to split with 'abcd' as
    // delimiter, similar to word.split('abcd') in python
    // for splitting -> "abcdFirstabcdSecondabcdThirdabcd"
    //                   01234567890123456789012345678901
    //                              1         2         3
    //                   ^   ^        ^         ^        ^
    //                   |   |        |         |        |
    // ptr --------------+---+--------+---------+--------+
    //                 s+0,0
    //                     s+4,5
    // modified word ->"\0bcdFirst\0bcdSecond\0bcdThird\0bcd"
    std::string_view v_word;
    public:
        Qstring(const char *xword) {
            v_word = std::string_view(xword, strlen(xword));
        };
        Qstring(const std::string &xword): v_word{std::string_view(xword)} {
        };

        std::vector<std::string_view> split(const char *delim) {
            return v_split(std::basic_string_view(delim, strlen(delim)));
        };

        std::vector<std::string_view> split(const std::string_view &delim) {
            return v_split(delim);
        };

        std::vector<std::string_view> v_split(const std::string_view &delim) {
            int index = 0; // tracks where we are in the line to split
            std::vector<std::string_view> split_words;
            auto pdelim0 = delim.begin();
            const int delim_length = delim.length();
            int match = 0;
            const auto v_word_start = v_word.begin();
            int prev_index = 0;
            for (auto line_char : v_word) {
                // std::cout << line_char << *(pdelim0+match)<< " ";
                ++index;
                if (line_char == *(pdelim0+match)) {
                    ++match;
                    if (match == delim_length) {
                        split_words.push_back(std::basic_string_view(v_word_start+prev_index, index-prev_index-delim_length));
                        prev_index = index;
                        match = 0;
                    }
                }
                else {
                    match = 0;
                }
            }
            // std::cout << index << " " << prev_index << " " << delim_length;
            if (prev_index == index) {
                split_words.push_back(std::basic_string_view(v_word_start+prev_index, 0));
            }
            else {
                split_words.push_back(std::basic_string_view(v_word_start+prev_index, index-prev_index));
            }
            return split_words;
        };
};

