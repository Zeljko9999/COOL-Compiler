#ifndef SEMANT_H_
#define SEMANT_H_

#include <assert.h>
#include <iostream>  
#include "cool-tree.h"
#include "stringtab.h"
#include "symtab.h"
#include "list.h"

#define TRUE 1
#define FALSE 0

class ClassTable;
typedef ClassTable *ClassTableP;
typedef SymbolTable<Symbol, tree_node>& Table;

// This is a structure that may be used to contain the semantic
// information such as the inheritance graph.  You may use it or not as
// you like: it is only here to provide a container for the supplied
// methods.

class ClassTable {
private:
  int semant_errors;
  void install_basic_classes();
  ostream& error_stream;

public:
  ClassTable(Classes);
  int errors() { return semant_errors; }
  ostream& semant_error();
  ostream& semant_error(Class_ c);
  ostream& semant_error(Symbol filename, tree_node *t);
  SymbolTable<Symbol, tree_node> class_symtable; // use tree_node as value cuz all nodes derives from it.
  void semant_class(class__class* current_class);
  void semant_class_attr(class__class* current_class);
  void semant_attr(class__class* current_class,attr_class* attr);
  void semant_method(class__class* current_class,method_class* method);

};


#endif