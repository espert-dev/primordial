#include <iostream>
#include <cstring>
#include "primordial.hpp"

int main(int argc, char *argv[]) {
 	Primordial::Driver drv;
	if (argc > 1 && strcmp(argv[1], "-v") == 0) {
		drv.enable_debug();
	}

	if (drv.parse() == 0) {
		std::cout << "\nPASS\n\n";
	} else {
		std::cout << "\nFAIL\n\n";
	}
}
