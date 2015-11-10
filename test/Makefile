BUILDDIR=../_build/test
$(shell mkdir -p $(BUILDDIR))
OCAMLDIR=$(shell ocamlopt -where)
CC=gcc
LD=gcc

all: $(BUILDDIR)/test.native

clean:
	rm -rf $(BUILDDIR)

$(BUILDDIR)/test.native: $(BUILDDIR)/test.o
	$(LD) -o $@ $< -L$(BUILDDIR)/.. -lxmlm

$(BUILDDIR)/test.o: test.c
	$(CC) -c -o $@ -I $(OCAMLDIR) -I $(BUILDDIR)/../generated  $<

.PHONY: all clean
