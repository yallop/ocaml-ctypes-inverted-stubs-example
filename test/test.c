#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <caml/callback.h>

#include "xmlm.h"

int depth = 0;

/* Define callbacks for the various XML events that the parser can report.
   In this simple example we'll ignore everything except start and end tags.
 */

void on_data(char *_) { }

void on_start_tag(char *namespace, char *tag)
{
  printf("%*s%s%s%s\n",
         depth * 3, "",
         namespace,
         strlen(namespace) != 0 ? ":" : "",
         tag);
  depth += 1;
}

void on_end_tag(void) { depth -= 1; }

void on_dtd(char *_) { }

void on_error(int l, int c, char *p)
{
  fprintf(stderr, "error: %s at <%d:%d>\n", p, l, c);
  exit(EXIT_FAILURE);
} 

int main(int argc, char **argv)
{
  struct handlers h = {
    on_data,
    on_start_tag,
    on_end_tag,
    on_dtd,
    on_error
  };
  char *filename = argc < 2 ? "/dev/stdin" : argv[1];

  /* Initialize the OCaml runtime before calling the library. */
  char *caml_argv[1] = { NULL };
  caml_startup(caml_argv);

  /* Call xmlm via the exported C function */
  parse_xml(&h, filename);
  return EXIT_SUCCESS;
}
