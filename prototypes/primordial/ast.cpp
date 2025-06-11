#include "ast.hpp"

namespace AST {

	File::File(
		std::string const &name,
		std::vector<Import> &&imports
	) : name_(name), imports_(imports) {}

	File::~File() {}

	Import::Import() {}

	Import::Import(AST::Import const &other)
		: path_(other.path_), alias_(other.alias_) {
	}

	Import::Import(std::string const &path) : path_(path) {}

	Import::Import(std::string const &path, std::string const &alias)
		: path_(path), alias_(alias) {
	}

	Import::~Import() {}

} // namespace AST
