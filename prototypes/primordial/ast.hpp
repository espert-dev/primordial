#pragma once

#include <memory>
#include <string>
#include <vector>

namespace AST {

	class Node {
	public:
		virtual ~Node() {};
		virtual void print(std::ostream &os, int level=0) const = 0;
	};

	class Import : public Node {
	public:
		Import();
		Import(Import const &other);
		Import(std::string const &path);
		Import(std::string const &path, std::string const &alias);

		void print(std::ostream &os, int level=0) const override;

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

		void print(std::ostream &os, int level=0) const override;

	private:
		std::string name_;
		std::vector<Import> imports_;
	};

} // namespace Primordial
