#pragma once

namespace yy {
    class Parser;
    class location;
}

namespace Primordial {

	class Driver {
	public:
		Driver();
		~Driver();

		int parse();
		void enable_debug();

        private:
                void* lexer;
		yy::location* loc;
		yy::Parser* parser;
        };

} // namespace Primordial
