#include "ast.hpp"

namespace AST {

	void indent(std::ostream &os, int level) {
		for (int i = 0; i < level; ++i) {
			os << '\t';
		}
	}

	template <typename T>
	void print_list(
		std::ostream &os,
		std::vector<std::unique_ptr<T>> const &v
	) {
		bool first = true;
		for (auto const &node : v) {
			if (!first) {
				os << ", ";
			}

			node->print(os);
			first = false;
		}
	}

	Node::~Node() = default;

	TypeName::TypeName(std::string &&name) : name_(name) {}

	void TypeName::print(std::ostream &os, int level) const {
		os << name_;
	}

	QualifiedTypeName::QualifiedTypeName(
		std::unique_ptr<Type> &&parent,
		std::string &&name
	) : parent_(std::move(parent)), name_(std::move(name)) {}

	void QualifiedTypeName::print(std::ostream &os, int level) const {
		parent_->print(os, level);
		os << "." << name_;
	}

	ArrayType::ArrayType(
		std::unique_ptr<Type> &&item_type,
		std::unique_ptr<Expression> &&size
	) : item_type_(std::move(item_type)), size_(std::move(size)) {}

	void ArrayType::print(std::ostream &os, int level) const {
		item_type_->print(os, level);
		os << "[";
		size_->print(os, level);
		os << "]";
	}

	SliceType::SliceType(std::unique_ptr<Type> &&item_type)
	: item_type_(std::move(item_type)) {}

	void SliceType::print(std::ostream &os, int level) const {
		item_type_->print(os, level);
		os << "[]";
	}

	PointerType::PointerType(std::unique_ptr<Type> &&item_type)
	: item_type_(std::move(item_type)) {}

	void PointerType::print(std::ostream &os, int level) const {
		item_type_->print(os, level);
		os << "?";
	}

	void FunctionType::print(std::ostream &os, int level) const {
		// TODO
	}

	void StructType::print(std::ostream &os, int level) const {
		// TODO
	}

	void UnionType::print(std::ostream &os, int level) const {
		// TODO
	}

	void InterfaceType::print(std::ostream &os, int level) const {
		// TODO
	}

	TypeInstantiation::TypeInstantiation(
			std::unique_ptr<Type> &&generic_type,
			std::vector<std::unique_ptr<Type>> &&args
	) : generic_type_(std::move(generic_type)), args_(std::move(args)) {}

	void TypeInstantiation::print(std::ostream &os, int level) const {
		generic_type_->print(os, level);
		os << "[";
		print_list(os, args_);
		os << "]";
	}

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
