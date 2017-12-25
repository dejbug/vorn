#include "textutils.hpp"

size_t textutils::print_hex_column(std::string const & text, size_t columns_per_row, size_t offset) {

	size_t i = offset;
	for (size_t col=0; col<columns_per_row; ++col, ++i) {
		if (col > 0 && col % 4 == 0) printf(" :");
		if (i >= text.size()) printf("   ");
		else printf(" %02X", text[i] & 0xFF);
	}
	printf(" | \n");
	return i;
}

void textutils::print_hex(std::string const & text) {
	size_t const columns_per_row = 16;
	size_t const full_rows = text.size() / columns_per_row;
	bool const has_partial_last_row = text.size() % columns_per_row;
	size_t const rows = full_rows + (has_partial_last_row ? 1 : 0);

	size_t offset = 0;
	for (size_t row=0; row<rows; ++row) {
		printf(" %08x |", offset);
		offset = print_hex_column(text, columns_per_row, offset);
	}
}
