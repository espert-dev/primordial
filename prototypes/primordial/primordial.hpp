#pragma once

#include <memory>
#include "ast.hpp"

namespace yy {
    class Parser;
    class location;
}

namespace Primordial {

	class Driver {
	public:
		Driver();
		~Driver();

		int parse();
		void enable_debug();
		auto result() -> std::unique_ptr<AST::File>;
		void set_result(std::unique_ptr<AST::File> &&file);

	private:
		void* lexer;
		yy::location* loc;
		yy::Parser* parser;
		std::unique_ptr<AST::File> result_;
	};

} // namespace Primordial
