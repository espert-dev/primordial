#include "ast.hpp"

namespace AST {

	void indent(std::ostream &os, int level) {
		for (int i = 0; i < level; ++i) {
			os << '\t';
		}
	}

	Node::~Node() = default;

	File::File(
		std::string const &name,
		std::vector<Import> &&imports
	) : name_(name), imports_(imports) {}

	File::~File() = default;

	void File::print(std::ostream &os, int level) const {
		indent(os, level);
		os << "package " << name_ << "\n\n";

		if (imports_.size() == 1) {
			imports_.at(0).print(os, level);
			os << "\n";
		} else if (imports_.size() > 1) {
			for (auto import : imports_) {
				import.print(os, level);
			}

			os << "\n";
		}
	}

	Import::Import() = default;

	Import::Import(Import const &other) = default;

	Import::Import(std::string &&path) : path_(path) {}

	Import::Import(std::string &&path, std::string &&alias)
		: path_(path), alias_(alias) {
	}

	void Import::print(std::ostream &os, int level) const {
		indent(os, level);
		os << "import ";

		if (!alias_.empty()) {
			os << alias_ << " ";
		}

		os << path_ << "\n";
	}

	Import::~Import() {}

} // namespace AST
