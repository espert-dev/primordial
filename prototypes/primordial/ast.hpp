#pragma once

#include <memory>
#include <string>
#include <vector>

namespace AST {

	class Node {
	public:
		virtual ~Node();
		virtual void print(std::ostream &os, int level=0) const = 0;
	};

	class Type : public Node {};
	class Expression : public Node {};

	using TypeList = std::vector<std::unique_ptr<Type>>;
	using ExpressionList = std::vector<std::unique_ptr<Expression>>;

	class TypeName : public Type {
	public:
		TypeName(std::string &&name);
		void print(std::ostream &os, int level=0) const override final;

	private:
		std::string name_;
	};

	class QualifiedTypeName : public Type {
	public:
		QualifiedTypeName(std::unique_ptr<Type> &&parent, std::string &&name);
		void print(std::ostream &os, int level=0) const override final;

	private:
		std::unique_ptr<Type> parent_;
		std::string name_;
	};

	class TypeInstantiation : public Type {
	public:
		TypeInstantiation(
			std::unique_ptr<Type> &&generic_type,
			TypeList &&args
		);
		void print(std::ostream &os, int level=0) const override final;

	private:
		std::unique_ptr<Type> generic_type_;
		TypeList args_;
	};

	class ArrayType : public Type {
	public:
		ArrayType(
			std::unique_ptr<Type> &&item_type,
			std::unique_ptr<Expression> &&size
		);
		void print(std::ostream &os, int level=0) const override final;

	private:
		std::unique_ptr<Type> item_type_;
		std::unique_ptr<Expression> size_;
	};

	class SliceType : public Type {
	public:
		SliceType(std::unique_ptr<Type> &&item_type);
		void print(std::ostream &os, int level=0) const override final;

	private:
		std::unique_ptr<Type> item_type_;
	};

	class PointerType : public Type {
	public:
		PointerType() = default; // TODO replace
		void print(std::ostream &os, int level=0) const override final;

	private:
		// TODO
	};

	class ReferenceType : public Type {
	public:
		ReferenceType() = default; // TODO replace
		void print(std::ostream &os, int level=0) const override final;

	private:
		// TODO
	};

	class FunctionType : public Type {
	public:
		FunctionType() = default; // TODO replace
		void print(std::ostream &os, int level=0) const override final;

	private:
		// TODO
	};

	class StructType : public Type {
	public:
		StructType() = default; // TODO replace
		void print(std::ostream &os, int level=0) const override final;

	private:
		// TODO
	};

	class UnionType : public Type {
	public:
		UnionType() = default; // TODO replace
		void print(std::ostream &os, int level=0) const override final;

	private:
		// TODO
	};

	class InterfaceType : public Type {
	public:
		InterfaceType() = default; // TODO replace
		void print(std::ostream &os, int level=0) const override final;

	private:
		// TODO
	};

	class Import : public Node {
	public:
		Import(); // Bison requires an empty constructor.
		Import(Import const &other);
		Import(std::string &&path);
		Import(std::string &&path, std::string &&alias);

		void print(std::ostream &os, int level=0) const override final;

		~Import();

	private:
		std::string path_;
		std::string alias_;
	};

	class File : public Node {
	public:
		File(
			std::string const &package_name,
			std::vector<Import> &&imports
		);
		~File();

		void print(std::ostream &os, int level=0) const override final;

	private:
		std::string name_;
		std::vector<Import> imports_;
	};

} // namespace Primordial
