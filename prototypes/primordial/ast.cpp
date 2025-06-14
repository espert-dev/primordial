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
		int level,
		std::vector<std::unique_ptr<T>> const &v
	) {
		bool first = true;
		for (auto const &node : v) {
			if (!first) {
				os << ", ";
			}

			node->print(os, level);
			first = false;
		}
	}

	Node::~Node() = default;

	TypeName::TypeName(std::string &&name) : name_(std::move(name)) {}

	void TypeName::print(std::ostream &os, int level) const {
		os << name_;
	}

	QualifiedTypeName::QualifiedTypeName(
		std::string &&package,
		std::string &&name
	) : package_(std::move(package)), name_(std::move(name)) {}

	void QualifiedTypeName::print(std::ostream &os, int level) const {
		os << package_ << "." << name_;
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

	RawSliceType::RawSliceType(std::unique_ptr<Type> &&item_type)
	: item_type_(std::move(item_type)) {}

	void RawSliceType::print(std::ostream &os, int level) const {
		item_type_->print(os, level);
		os << "[_]";
	}

	PointerType::PointerType(std::unique_ptr<Type> &&item_type)
	: item_type_(std::move(item_type)) {}

	void PointerType::print(std::ostream &os, int level) const {
		item_type_->print(os, level);
		os << "?";
	}

	FunctionType::FunctionType(AST::TypeList &&inputs)
	: inputs_(std::move(inputs)) {}

	FunctionType::FunctionType(AST::TypeList &&inputs, AST::TypeList &&outputs)
	: inputs_(std::move(inputs)), outputs_(std::move(outputs)) {}

	void FunctionType::print(std::ostream &os, int level) const {
		os << "func (";
		print_list(os, level, inputs_);
		os << ") -> (";
		print_list(os, level, outputs_);
		os << ")";
	}

	Field::Field() = default;

	Field::Field(std::unique_ptr<Type> &&type)	: type_(std::move(type)) {}

	Field::Field(std::string &&name, std::unique_ptr<Type> &&type)
	: name_(std::move(name)), type_(std::move(type)) {}

	void Field::print(std::ostream &os, int level) const {
		indent(os, level);
		if (!is_embedding()) {
			os << name_ << ' ';
		}

		type_->print(os, level);
	}

	bool Field::is_embedding() const {
		return name_.empty();
	}

	StructType::StructType(FieldList &&fields) : fields_(std::move(fields)) {}

	void StructType::print(std::ostream &os, int level) const {
		os << "struct {\n";

		for (auto const &field : fields_) {
			field.print(os, level+1);
		}

		os << "}\n";
	}

	UnionType::UnionType(FieldList &&fields) : fields_(std::move(fields)) {}

	void UnionType::print(std::ostream &os, int level) const {
		os << "union {\n";

		for (auto const &field : fields_) {
			field.print(os, level+1);
		}

		os << "}\n";
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
		print_list(os, level, args_);
		os << "]";
	}

	File::File(
		std::string &&name,
		std::vector<Import> &&imports
	) : name_(std::move(name)), imports_(imports) {}

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
	: path_(std::move(path)), alias_(std::move(alias)) {}

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
