wget https://raw.githubusercontent.com/ocaml/ocaml-travisci-skeleton/master/.travis-ocaml.sh
sh .travis-ocaml.sh

eval `opam config env`

opam pin add --yes -n $(pwd)
opam install --yes depext
opam depext ctypes-inverted-stubs-example
opam install --build-test --yes --verbose ctypes-inverted-stubs-example
