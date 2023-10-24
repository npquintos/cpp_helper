#include <cstring>
#include <iostream>
#include <vector>
#include <exception>
#include <string_view>

class Qstring {
    // Usage:
    // for (auto word : Qstring(word_to_split).split(delimeter_word) {
    //      std::cout << word << std::endl
    // }
    // word_to_split could be C-style string, std::string, std::string_view
    // delimeter word could be C-style string, std::string_view
   
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
            if (prev_index == index) {
                split_words.push_back(std::basic_string_view(v_word_start+prev_index, 0));
            }
            else {
                split_words.push_back(std::basic_string_view(v_word_start+prev_index, index-prev_index));
            }
            return split_words;
        };
};

