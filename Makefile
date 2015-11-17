BUILDDIR=_build
VPATH=$(BUILDDIR)
OCAMLDIR=$(shell ocamlopt -where)
$(shell mkdir -p $(BUILDDIR) $(BUILDDIR)/lib $(BUILDDIR)/stub_generator $(BUILDDIR)/test $(BUILDDIR)/generated)
PACKAGES=xmlm,ctypes.stubs,ctypes.foreign

# The files used to build the stub generator.
GENERATOR_FILES=$(BUILDDIR)/lib/bindings.cmx		\
                $(BUILDDIR)/stub_generator/generate.cmx

EXTOBJ=$(shell ocamlc -config | grep ext_obj | cut -d' ' -f2)
EXTDLL=$(shell ocamlc -config | grep ext_dll | cut -d' ' -f2)
CC=$(shell ocamlopt -config | grep native_c_compiler | cut -d' ' -f 2-)

ifeq ($(shell ocamlc -config | grep os_type | cut -d' ' -f2), Win32)
EXE=.exe
NATIVEXE=.exe
LD_LIBRARY_PATH=PATH
else
NATIVEXE=.native
RUNTIMEVARIANT=-runtime-variant _pic
LD_LIBRARY_PATH=LD_LIBRARY_PATH
endif

# The files from which we'll build a shared library.
LIBFILES=$(BUILDDIR)/lib/bindings.cmx			\
         $(BUILDDIR)/generated/xmlm_bindings.cmx	\
         $(BUILDDIR)/lib/apply_bindings.cmx		\
         $(BUILDDIR)/generated/xmlm$(EXTOBJ)

# The files that we'll generate
GENERATED=$(BUILDDIR)/generated/xmlm.h \
          $(BUILDDIR)/generated/xmlm.c \
          $(BUILDDIR)/generated/xmlm_bindings.ml

GENERATOR=$(BUILDDIR)/generate${EXE}

all: sharedlib

sharedlib: $(BUILDDIR)/libxmlm${EXTDLL}

$(BUILDDIR)/libxmlm$(EXTDLL): $(LIBFILES)
	ocamlfind opt -o $@ -linkpkg -output-obj $(RUNTIMEVARIANT) -verbose -package $(PACKAGES) $^

stubs: $(GENERATED)

$(GENERATED): $(GENERATOR)
	$(GENERATOR) $(BUILDDIR)/generated

$(BUILDDIR)/%$(EXTOBJ): %.c
	$(CC) -c -o $@ -fPIC -I $(shell ocamlfind query ctypes) -I $(OCAMLDIR) -I $(OCAMLDIR)/../ctypes $<

$(BUILDDIR)/%.cmx: %.ml
	ocamlfind opt -c -o $@ -I $(BUILDDIR)/generated -I $(BUILDDIR)/lib -package $(PACKAGES) $<

$(GENERATOR): $(GENERATOR_FILES)
	ocamlfind opt -o $@ -linkpkg -package $(PACKAGES) $^

clean:
	rm -rf $(BUILDDIR)

test: all
	$(MAKE) -C $@
	$(LD_LIBRARY_PATH)=$(BUILDDIR) _build/test/test${NATIVEXE} test/ocaml.svg

.PHONY: test
