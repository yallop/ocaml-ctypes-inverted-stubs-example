BUILDDIR=_build
VPATH=$(BUILDDIR)
OCAMLDIR=$(shell ocamlopt -where)
$(shell mkdir -p $(BUILDDIR) $(BUILDDIR)/lib $(BUILDDIR)/stub_generator $(BUILDDIR)/test $(BUILDDIR)/generated)
PACKAGES=xmlm,ctypes.stubs,ctypes.foreign

# The files used to build the stub generator.
GENERATOR_FILES=$(BUILDDIR)/lib/bindings.cmx		\
                $(BUILDDIR)/stub_generator/generate.cmx

# The files from which we'll build a shared library.
LIBFILES=$(BUILDDIR)/lib/bindings.cmx			\
         $(BUILDDIR)/generated/xmlm_bindings.cmx	\
         $(BUILDDIR)/lib/apply_bindings.cmx		\
         $(BUILDDIR)/generated/xmlm.o

# The files that we'll generate
GENERATED=$(BUILDDIR)/generated/xmlm.h \
          $(BUILDDIR)/generated/xmlm.c \
          $(BUILDDIR)/generated/xmlm_bindings.ml

GENERATOR=$(BUILDDIR)/generate

all: sharedlib

sharedlib: $(BUILDDIR)/libxmlm.so

$(BUILDDIR)/libxmlm.so: $(LIBFILES)
	ocamlfind opt -o $@ -linkpkg -output-obj -package $(PACKAGES) $^

stubs: $(GENERATED)

$(GENERATED): $(GENERATOR)
	$(BUILDDIR)/generate $(BUILDDIR)/generated

$(BUILDDIR)/%.o: %.c
	gcc -c -o $@ -fPIC -I $(OCAMLDIR)/../ctypes $<

$(BUILDDIR)/%.cmx: %.ml
	ocamlfind opt -c -o $@ -I $(BUILDDIR)/generated -I $(BUILDDIR)/lib -package $(PACKAGES) $<

$(GENERATOR): $(GENERATOR_FILES)
	ocamlfind opt -o $@ -linkpkg -package $(PACKAGES) $^

clean:
	rm -rf $(BUILDDIR)

test: all
	$(MAKE) -C $@
	LD_LIBRARY_PATH=$(BUILDDIR) _build/test/test.native test/ocaml.svg

.PHONY: test
