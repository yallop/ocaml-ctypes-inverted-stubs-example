This repository shows how to use [ocaml-ctypes][ctypes] to turn OCaml code
into a shared library that can be used from C.  In keeping with the general
philosophy of ocaml-ctypes, this involves writing no C code at all.  The
example here exposes a simple interface to the XML parsing functionality in
the OCaml library [Xmlm][xmlm].

There are two main files involved in building the library:

* [`bindings.ml`](lib/bindings.ml) uses ocaml-ctypes to define a C-compatible interface to Xmlm.  The central component in the interface is a structure type that holds callbacks for each event that might occur during XML parsing.  On the C side these callbacks are function pointers; on the OCaml side they appear as regular OCaml functions.  In addition to the struct definition, the `Bindings` module exposes a single function to C, for parsing XML from a file.

* [`generate.ml`](stub_generator/generate.ml) is an OCaml program that generates C source and header files from the definitions in the `Bindings` module, and an OCaml module that can be used to link the generated code with the code in `Bindings`.  (See [`apply_bindings.ml`](lib/apply_bindings.ml) for the actual linking.)

The prerequisites for building the library are OCaml 4.02.2, [ocaml-ctypes][ctypes] (0.4.0 or later), [Xmlm][xmlm] and [ocamlfind][findlib].  [OPAM][opam] users can install the prerequisites by issuing the following commands:

```
opam update
opam switch 4.02.2
eval `opam config env`
opam install ctypes-foreign ctypes xmlm
```

When you type `make` the following things will happen:

1. The stub generator executable will be built from [`bindings.ml`](lib/bindings.ml) and [`generate.ml`](stub_generator/generate.ml).
2. The stub generator will be run to produce a C header `xmlm.h`, a C source file `xmlm.c`, and an OCaml module `xmlm_bindings.ml`.
3. The shared library will be built from the freshly-generated `xmlm.c` and `xmlm_bindings.ml`, together with [`bindings.ml`](lib/bindings.ml) and [`apply_bindings.ml`](lib/apply_bindings.ml).

Typing `make test` causes the following additional steps to take place:

4. A test program, written in C, will be built by compiling [test.c](test/test.c) and linking it with the shared library.
5. The test program will be run on the sample XML file [ocaml.svg](test/ocaml.svg)

[Dune](https://github.com/ocaml/dune) can also be used instead of make:
- `dune runtest` builds and run the test
- `dune build` builds the shared object (libxmlm.so or libxmlm.dll)

#### Build status:

AppVeyor: [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/fj1l12iwd4mix51x/branch/master?svg=true)](https://ci.appveyor.com/project/yallop/ocaml-ctypes-inverted-stubs-example/branch/master)  
Travis: [![Travis build Status](https://travis-ci.org/yallop/ocaml-ctypes-inverted-stubs-example.svg?branch=master)](https://travis-ci.org/yallop/ocaml-ctypes-inverted-stubs-example)  

[xmlm]: http://erratique.ch/software/xmlm
[ctypes]: https://github.com/ocamllabs/ocaml-ctypes
[findlib]: http://projects.camlcity.org/projects/findlib.html
[opam]: http://opam.ocaml.org/
