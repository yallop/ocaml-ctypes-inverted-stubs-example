This repository shows how to use [ocaml-ctypes][ctypes] to turn OCaml code
into a shared library that can be used from C.  In keeping with the general
philosophy of ocaml-ctypes, this involves writing no C code at all.  The
example here exposes a simple interface to the XML parsing functionality in
the OCaml library [Xmlm][xmlm].

There are two main files involved in building the library:

* [`bindings.ml`](bindings/bindings.ml) uses ocaml-ctypes to define a
  C-compatible interface to Xmlm. The central component in the interface is a
  structure type that holds callbacks for each event that might occur during XML
  parsing. On the C side these callbacks are function pointers; on the OCaml
  side they appear as regular OCaml functions. In addition to the struct
  definition, the `Bindings` module exposes a single function to C, for parsing
  XML from a file.

* [`generate.ml`](stub_generator/generate.ml) is an OCaml program that generates
  C source and header files from the definitions in the `Bindings` module, and
  an OCaml module that can be used to link the generated code with the code in
  `Bindings`. (See [`apply_bindings.ml`](lib/apply_bindings.ml) for the actual
  linking.)

The prerequisites for building the library are OCaml 4.02.2,
[ocaml-ctypes][ctypes] (0.4.0 or later), [Xmlm][xmlm] and [ocamlfind][findlib].
[OPAM][opam] users can install the prerequisites by issuing the following
commands:

```
opam update
opam switch 4.02.2
eval `opam config env`
opam install ctypes-foreign ctypes xmlm
```

This branch makes use of `dune` instead of `make`:

- `dune build` generates `_build/default/dll/libxmlm.so` shared library (or .dll, depending on
  the platform) and the C program `_build/default/test/test.exe` (linked with the shared library).

- `dune runtest` executes `_build/default/test/test.exe` on the sample XML file `test/ocaml.svg`.
  as first argument

[xmlm]: http://erratique.ch/software/xmlm
[ctypes]: https://github.com/ocamllabs/ocaml-ctypes
[findlib]: http://projects.camlcity.org/projects/findlib.html
[opam]: http://opam.ocaml.org/
