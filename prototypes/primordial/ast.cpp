#include <stdexcept>
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

	auto binary_operator_string(BinaryOperator op) -> std::string const & {
		// Use static strings to minimise allocations.
		// Use blocks to scope static variables to their point of use.
		switch (op) {
			case BinaryOperator::LOGICAL_OR: {
				static std::string const logical_or("||");
				return logical_or;
			}
			case BinaryOperator::LOGICAL_AND: {
				static std::string const logical_and("&&");
				return logical_and;
			}
			case BinaryOperator::EQ: {
				static std::string const eq("==");
				return eq;
			}
			case BinaryOperator::NE: {
				static std::string const ne("!=");
				return ne;
			}
			case BinaryOperator::LE: {
				static std::string const le("<=");
				return le;
			}
			case BinaryOperator::GE: {
				static std::string const ge(">=");
				return ge;
			}
			case BinaryOperator::LT: {
				static std::string const lt("<");
				return lt;
			}
			case BinaryOperator::GT: {
				static std::string const gt(">");
				return gt;
			}
			case BinaryOperator::ADD: {
				static std::string const add("+");
				return add;
			}
			case BinaryOperator::SUB: {
				static std::string const sub("-");
				return sub;
			}
			case BinaryOperator::BITWISE_OR: {
				static std::string const bitwise_or("|");
				return bitwise_or;
			}
			case BinaryOperator::BITWISE_XOR: {
				static std::string const bitwise_xor("^");
				return bitwise_xor;
			}
			case BinaryOperator::MUL: {
				static std::string const mul("*");
				return mul;
			}
			case BinaryOperator::DIV: {
				static std::string const div("/");
				return div;
			}
			case BinaryOperator::REM: {
				static std::string const rem("%");
				return rem;
			}
			case BinaryOperator::BITWISE_AND: {
				static std::string const bitwise_and("&");
				return bitwise_and;
			}
			case BinaryOperator::BITWISE_CLEAR: {
				static std::string const bitwise_clear("&^");
				return bitwise_clear;
			}
			case BinaryOperator::LEFT_SHIFT: {
				static std::string const left_shift("<<");
				return left_shift;
			}
			case BinaryOperator::RIGHT_SHIFT: {
				static std::string const right_shift(">>");
				return right_shift;
			}
		}

		throw std::invalid_argument("unknown binary operator");
	}

	auto unary_operator_string(UnaryOperator op) {
		// Use static strings to minimise allocations.
		// Use blocks to scope static variables to their point of use.
		switch (op) {
			case UnaryOperator::NEG: {
				static std::string const neg("-");
				return neg;
			}
			case UnaryOperator::BITWISE_NOT: {
				static std::string const bitwise_not("~");
				return bitwise_not;
			}
			case UnaryOperator::LOGICAL_NOT: {
				static std::string const logical_not("!");
				return logical_not;
			}
			case UnaryOperator::ADDRESS_OF: {
				static std::string const address_of("@");
				return address_of;
			}
		}

		throw std::invalid_argument("unknown binary operator");
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

	Field::Field(Field &&other) = default;

	Field& Field::operator=(Field &&other)= default;

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

	BinaryExpression::BinaryExpression(
		AST::BinaryOperator op,
		std::unique_ptr<AST::Expression> &&lhs,
		std::unique_ptr<AST::Expression> &&rhs
	) : operator_(op), lhs_(std::move(lhs)), rhs_(std::move(rhs)) {}

	void BinaryExpression::print(std::ostream &os, int level) const {
		os << "(";
		lhs_->print(os, level);
		os << ") " << binary_operator_string(operator_) << " (";
		rhs_->print(os, level);
		os << ")";
	}

	UnaryExpression::UnaryExpression(
		AST::UnaryOperator op,
		std::unique_ptr<Expression> &&arg
	) : operator_(op), arg_(std::move(arg)) {}

	void UnaryExpression::print(std::ostream &os, int level) const {
		os << unary_operator_string(operator_) << ' ';
		arg_->print(os, level);
	}

	BooleanLiteral::BooleanLiteral(bool value) : value_(value) {}

	void BooleanLiteral::print(std::ostream &os, int level) const {
		if (value_) {
			os << "true";
		} else {
			os << "false";
		}
	}

	StringLiteral::StringLiteral(std::string &&value)
	: value_(std::move(value)) {}

	void StringLiteral::print(std::ostream &os, int level) const {
		os << value_;
	}

	NumericLiteral::NumericLiteral(std::string &&value)
	: value_(std::move(value)) {}

	void NumericLiteral::print(std::ostream &os, int level) const {
		os << value_;
	}

	ArrayAccess::ArrayAccess(
		std::unique_ptr <Expression> &&array,
		std::unique_ptr <Expression> index
	) : array_(std::move(array)), index_(std::move(index)) {}

	void ArrayAccess::print(std::ostream &os, int level) const {
		array_->print(os, level);
		os << '[';
		index_->print(os, level);
		os << ']';
	}

	FieldAccess::FieldAccess(
		std::unique_ptr<Expression> &&record,
		std::string &&field
	) : record_(std::move(record)), field_(std::move(field)) {}

	void FieldAccess::print(std::ostream &os, int level) const {
		record_->print(os, level);
		os << '.' << field_;
	}

	PackageAccess::PackageAccess(std::string &&package, std::string &&name)
	: package_(std::move(package)), name_(std::move(name)) {}

	void PackageAccess::print(std::ostream &os, int level) const {
		os << package_ << '.' << name_;
	}

	PointerDereference::PointerDereference(std::unique_ptr<Expression> &&ptr)
	: ptr_(std::move(ptr)) {}

	void PointerDereference::print(std::ostream &os, int level) const {
		ptr_->print(os, level);
		os << '.';
	}

	TypeCast::TypeCast(
		std::unique_ptr<Type> &&type,
		std::unique_ptr<Expression> &&expr
	) : type_(std::move(type_)), expr_(std::move(expr)) {}

	void TypeCast::print(std::ostream &os, int level) const {
		type_->print(os, level);
		os << '(';
		expr_->print(os, level);
		os << ')';
	}

	File::File(
		std::string &&name,
		std::vector<Import> &&imports
	) : name_(std::move(name)), imports_(std::move(imports)) {}

	File::~File() = default;

	void File::print(std::ostream &os, int level) const {
		indent(os, level);
		os << "package " << name_ << "\n\n";

		if (imports_.size() == 1) {
			imports_.at(0).print(os, level);
			os << "\n";
		} else if (imports_.size() > 1) {
			for (auto const &import : imports_) {
				import.print(os, level);
			}

			os << "\n";
		}
	}

	Import::Import() = default;

	Import::Import(Import &&other) = default;

	Import& Import::operator=(Import &&other) = default;

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
