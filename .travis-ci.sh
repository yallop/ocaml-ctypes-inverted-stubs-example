wget https://raw.githubusercontent.com/ocaml/ocaml-travisci-skeleton/master/.travis-ocaml.sh
sh .travis-ocaml.sh

eval `opam config env`

opam install --yes depext
opam depext ctypes-foreign
opam install --yes ctypes-foreign ctypes xmlm
make
make test
