#include "primordial.hpp"
#include "scanner.hpp"
#include "parser.hpp"

namespace Primordial {

	Driver::Driver() {
		yylex_init(&lexer);
		loc = new yy::location();
		parser = new yy::Parser(lexer, *loc, *this);
	}

	Driver::~Driver() {
		yylex_destroy(lexer);
		delete loc;
		delete parser;
	}

	int Driver::parse() {
		return parser->parse();
	}

	void Driver::enable_debug() {
		parser->set_debug_level(1);
	}

} // namespace Primordial
