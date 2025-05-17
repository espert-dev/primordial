# Primordial

A non-bootstrapped development toolchain.

## CLion

### Syntax highlighting for assembly files (.S)

1. Open the CLion Settings
2. Go to Editor / File Types
3. Select "Assembly language file"
4. Add ".S" (it's case-insensitive) under "File name patterns"

### Debugging via QEMU

Unless you are are on a RISC-V 64 system, you will need QEMU, gdb-multiarch,
and a remote session.

1. Add a new Run/Debug Configuration of type "Remote Debug"
   * Name: Debug via QEMU
   * Debugger: Bundled GDB
   * 'target remote' args: `localhost:1234` (assumes port 1234)

2. In the terminal, use QEMU to run the test or program that you want to debug:
   ```bash
   NO_TEST=1 ./make && qemu-riscv64-static -g 1234 build/cmd/hello/hello
   ```

3. Start debugging from CLion.
