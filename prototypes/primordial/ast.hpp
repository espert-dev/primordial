#pragma once

#include <memory>
#include <string>
#include <vector>

namespace AST {

	class Node {
	public:
		virtual ~Node() {};
	};

	class Import : public Node {
	public:
		Import();
		Import(Import const &other);
		Import(std::string const &path);
		Import(std::string const &path, std::string const &alias);
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

	private:
		std::string name_;
		std::vector<Import> imports_;
	};

} // namespace Primordial
