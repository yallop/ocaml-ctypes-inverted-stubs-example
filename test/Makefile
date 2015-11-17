BUILDDIR=../_build/test
$(shell mkdir -p $(BUILDDIR))
OCAMLDIR=$(shell ocamlopt -where | sed -e 's/\r//')
CC=$(shell ocamlopt -config | grep native_c_compiler | cut -d' ' -f 2- )
LD=$(CC)

ifeq ($(shell ocamlc -config | grep os_type | cut -d' ' -f2), Win32)
NATIVEXE=.exe
else
NATIVEXE=.native
endif

EXTOBJ=$(shell ocamlc -config | grep ext_obj | cut -d' ' -f2)

all: $(BUILDDIR)/test$(NATIVEXE)

clean:
	rm -rf $(BUILDDIR)

$(BUILDDIR)/test$(NATIVEXE): $(BUILDDIR)/test$(EXTOBJ)
	$(LD) -o $@ $< -L$(BUILDDIR)/.. -lxmlm

$(BUILDDIR)/test$(EXTOBJ): test.c
	echo $(CC)
	$(CC) -c -o $@ -I $(OCAMLDIR) -I $(BUILDDIR)/../generated  $<

.PHONY: all clean
