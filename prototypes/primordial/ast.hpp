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

	class TypeName : public Type {
	public:
		~TypeName();
		TypeName(std::string &&name);

		void print(std::ostream &os, int level=0) const override final;

	private:
		std::string name_;
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
