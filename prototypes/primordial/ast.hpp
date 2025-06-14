#pragma once

#include <memory>
#include <string>
#include <vector>

namespace AST {

	class Node {
	public:
		virtual ~Node();
		virtual void print(std::ostream &os, int level) const = 0;
	};

	class Type : public Node {};
	class Expression : public Node {};

	using TypeList = std::vector<std::unique_ptr<Type>>;
	using ExpressionList = std::vector<std::unique_ptr<Expression>>;

	class TypeName : public Type {
	public:
		TypeName(std::string &&name);
		void print(std::ostream &os, int level) const override final;

	private:
		std::string name_;
	};

	class QualifiedTypeName : public Type {
	public:
		QualifiedTypeName(std::string &&package, std::string &&name);
		void print(std::ostream &os, int level) const override final;

	private:
		std::string package_;
		std::string name_;
	};

	class TypeInstantiation : public Type {
	public:
		TypeInstantiation(
			std::unique_ptr<Type> &&generic_type,
			TypeList &&args
		);
		void print(std::ostream &os, int level) const override final;

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
		void print(std::ostream &os, int level) const override final;

	private:
		std::unique_ptr<Type> item_type_;
		std::unique_ptr<Expression> size_;
	};

	class SliceType : public Type {
	public:
		SliceType(std::unique_ptr<Type> &&item_type);
		void print(std::ostream &os, int level) const override final;

	private:
		std::unique_ptr<Type> item_type_;
	};

	class RawSliceType : public Type {
	public:
		RawSliceType(std::unique_ptr<Type> &&item_type);
		void print(std::ostream &os, int level) const override final;

	private:
		std::unique_ptr<Type> item_type_;
	};

	class PointerType : public Type {
	public:
		PointerType(std::unique_ptr<Type> &&item_type);
		void print(std::ostream &os, int level) const override final;

	private:
		std::unique_ptr<Type> item_type_;
	};

	class FunctionType : public Type {
	public:
		FunctionType(TypeList &&inputs);
		FunctionType(TypeList &&inputs,TypeList &&outputs);
		void print(std::ostream &os, int level) const override final;

	private:
		TypeList inputs_;
		TypeList outputs_;
	};

	class Field : public Node {
	public:
		Field(); // only for Bison
		Field(Field &&other);
		Field& operator=(Field &&other);

		Field(std::unique_ptr<Type> &&type);
		Field(std::string &&name, std::unique_ptr<Type> &&type);
		void print(std::ostream &os, int level) const override final;
		bool is_embedding() const;

	private:
		std::string name_;
		std::unique_ptr<Type> type_;
	};

	using FieldList = std::vector<Field>;

	class StructType : public Type {
	public:
		StructType(FieldList &&fields);
		void print(std::ostream &os, int level) const override final;

	private:
		FieldList fields_;
	};

	class UnionType : public Type {
	public:
		UnionType(FieldList &&fields);
		void print(std::ostream &os, int level) const override final;

	private:
		FieldList fields_;
	};

	class InterfaceType : public Type {
	public:
		InterfaceType() = default; // TODO replace
		void print(std::ostream &os, int level) const override final;

	private:
		// TODO
	};

	class Import : public Node {
	public:
		Import(); // Bison requires an empty constructor.
		Import(Import &&other);
		Import& operator=(Import &&other);

		Import(std::string &&path);
		Import(std::string &&path, std::string &&alias);

		void print(std::ostream &os, int level) const override final;

		~Import();

	private:
		std::string path_;
		std::string alias_;
	};

	class File : public Node {
	public:
		File(
			std::string &&package_name,
			std::vector<Import> &&imports
		);
		~File();

		void print(std::ostream &os, int level) const override final;

	private:
		std::string name_;
		std::vector<Import> imports_;
	};

} // namespace Primordial
