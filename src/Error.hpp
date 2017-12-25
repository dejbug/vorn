#ifndef ERROR_HPP
#define ERROR_HPP

#include <stdexcept>

struct Error : public std::runtime_error {
	Error() : std::runtime_error("") {
	}
};

#endif // !ERROR_HPP
