# riscv-configstring-parser
Example Flex and Bison parser for RISC-V Configuration Strings from Privileged Spec v1.9. This is just a starting point for projects that require parsing of RISC-V Configuration Strings.

### How to use
        make
        ./main <configstringfile>
```main``` will parse the input file containing a RISC-V Configuration String, and then it will print it out in a normalized format. If no file is passed as an input to ```main```, it will use the file ```platform.rvcs``` as a default input.
