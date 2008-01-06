CC = gcc
CFLAGS = -Wall -fPIC -O2
OCAMLC = ocamlc
OCAMLOPT = ocamlopt

OCAMLOPTFLAGS =

OCAMLABI := $(shell ocamlc -version)
OCAMLLIBDIR := $(shell ocamlc -where)
OCAMLDESTDIR ?= $(OCAMLLIBDIR)

OCAML_TEST_INC = -I `ocamlfind query oUnit`
OCAML_TEST_LIB = `ocamlfind query oUnit`/oUnit.cmxa

LIBS = inotify.cmi inotify.cmxa inotify.cma
PROGRAMS = test.inotify

all: $(LIBS)

bins: $(PROGRAMS)

libs: $(LIBS)

inotify.cmxa: libinotify_stubs.a inotify_stubs.a inotify.cmx
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -a -cclib -linotify_stubs -o $@ inotify.cmx

inotify.cma: libinotify_stubs.a inotify.cmi inotify.cmo
	$(OCAMLC) -a -dllib dllinotify_stubs.so -cclib -linotify_stubs -o $@ inotify.cmo

inotify_stubs.a: inotify_stubs.o
	ocamlmklib -o inotify_stubs $+

libinotify_stubs.a: inotify_stubs.o
	ar rcs $@ $+
	ocamlmklib -o inotify_stubs $+

%.cmo: %.ml
	$(OCAMLC) -c -o $@ $<

%.cmi: %.mli
	$(OCAMLC) -c -o $@ $<

%.cmx: %.ml
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -c -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

.PHONY: install
install: $(LIBS)
	ocamlfind install -destdir $(OCAMLDESTDIR) -ldconf ignore inotify META inotify.cmi inotify.mli inotify.cma inotify.cmxa *.a *.so *.cmx

uninstall:
	ocamlfind remove -destdir $(OCAMLDESTDIR) sqlite3

test.inotify: inotify.cmxa test.inotify.ml
	$(OCAMLOPT) -o $@ unix.cmxa $+

clean:
	-rm -f *.o *.so *.a *.cmo *.cmi *.cma *.cmx *.cmxa $(LIBS) $(PROGRAMS)
