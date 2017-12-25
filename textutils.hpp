#ifndef TEXTUTILS_HPP
#define TEXTUTILS_HPP

#include <stdio.h>
#include <string>

namespace textutils {

size_t print_hex_column(std::string const & text, size_t columns_per_row=16, size_t offset=0);
void print_hex(std::string const & text);

} // !namespace textutils

#endif // !TEXTUTILS_HPP
