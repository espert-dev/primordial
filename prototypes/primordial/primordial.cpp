#include "primordial.hpp"
#include "scanner.hpp"
#include "parser.hpp"
#include "ast.hpp"

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

	void Driver::set_result(std::unique_ptr<AST::File> &&file) {
		result_ = std::move(file);
	}

	auto Driver::result() -> std::unique_ptr<AST::File> {
		return std::move(result_);
	}

	void Driver::enable_debug() {
		parser->set_debug_level(1);
	}

} // namespace Primordial
