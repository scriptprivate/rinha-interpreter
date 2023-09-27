# rinha-interpreter

Perl Tree-Walking Interpreter for Rinha de Compilers (or Interpreters). 

## Structure of the Rinha Interpreter Project

The Rinha interpreter project is divided into three main parts: `Kinds`, `Interpreter`, and `Main`.

### Kinds (kinds.pm)

The `Kinds` module contains definitions of data structures and functions related to representing different types of nodes (terms) that can be found in the abstract syntax tree (AST) of the Rinha language. It defines data structures to represent nodes such as files, `let` statements, text values, integers, binary operators, functions, function calls, and more.

Additionally, this module defines functions for creating and manipulating these data structures, such as functions to create `File`, `Let`, `Str`, `Bool`, `Int` nodes, binary operators, and others. It also defines a set of binary operators to perform mathematical and logical operations on data terms.

### Interpreter (interpreter.pm)

The `Interpreter` module is responsible for interpreting the AST (abstract syntax tree) generated from the Rinha language source code. It contains functions to identify the type of node in the AST and execute corresponding actions for these nodes.

- The `cache` function is used as a decorator to implement result caching for functions to optimize performance.
- The `identify_type` function takes an AST node and identifies the node's type by creating a corresponding data structure defined in the `Kinds` module.
- The `read_node` function is responsible for traversing the AST and executing operations specified by the AST nodes, maintaining a context for local variables, and returning the results of operations.

### Main (main.pl)

The `main.pl` script serves as the entry point of the interpreter.

- It defines the variable `$filepath` with the path to the JSON file containing the Rinha AST.
- It calls the `process_file` function from the `Interpreter` module, passing the file path as an argument to initiate the interpretation process.
