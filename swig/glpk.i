%module rglpk

%{
#include "glpk.h"
%}

%include "carrays.i"

%array_functions(int, intArray)
%array_functions(double, doubleArray)

%include "glpk.h"



