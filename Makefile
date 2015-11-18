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

OSTYPE:=$(shell ocamlfind ocamlc -config | awk '/^os_type:/ {print $$2}')
EXTDLL:=$(shell ocamlfind ocamlc -config | awk '/^ext_dll:/ {print $$2}')
CC:= $(shell ocamlfind ocamlc -config | awk '/^bytecomp_c_compiler/ {for(i=2;i<=NF;i++) printf "%s " ,$$i}')

ifeq ($(OSTYPE),$(filter $(OSTYPE),Win32 Cygwin))
EXTEXE=.exe
else
EXTEXE=
endif

GENERATOR=$(BUILDDIR)/generate$(EXTEXE)

all: sharedlib

sharedlib: $(BUILDDIR)/libxmlm$(EXTDLL)


ifeq ($(OSTYPE),$(filter $(OSTYPE),Win32 Cygwin))
$(BUILDDIR)/libxmlm$(EXTDLL): $(LIBFILES)
	ocamlfind opt -o $@ -linkpkg -output-obj -verbose -package $(PACKAGES) $^
else
$(BUILDDIR)/libxmlm$(EXTDLL): $(LIBFILES)
	ocamlfind opt -o $@ -linkpkg -output-obj -runtime-variant _pic -verbose -package $(PACKAGES) $^
endif

stubs: $(GENERATED)

$(GENERATED): $(GENERATOR)
	$(GENERATOR) $(BUILDDIR)/generated

$(BUILDDIR)/%.o: %.c
	$(CC) -c -o $@ -fPIC -I $(shell ocamlfind query ctypes) -I $(OCAMLDIR) -I $(OCAMLDIR)/../ctypes $<

$(BUILDDIR)/%.cmx: %.ml
	ocamlfind opt -c -o $@ -I $(BUILDDIR)/generated -I $(BUILDDIR)/lib -package $(PACKAGES) $<

$(GENERATOR): $(GENERATOR_FILES)
	ocamlfind opt -o $@ -linkpkg -package $(PACKAGES) $^

clean:
	rm -rf $(BUILDDIR)

test: all
	$(MAKE) -C $@
ifeq ($(OSTYPE),Win32)
	PATH="$(BUILDDIR):$(PATH)" _build/test/test.native test/ocaml.svg
else
	LD_LIBRARY_PATH=$(BUILDDIR) _build/test/test.native test/ocaml.svg
endif

.PHONY: test
