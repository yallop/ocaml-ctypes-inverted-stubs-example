(*
 * Copyright (c) 2014-2015 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)

open Ctypes
open Foreign

(* Define a struct of callbacks (C function pointers) *)
let handlers : [`handlers] structure typ = structure "handlers"
let (--) s f = field handlers s (funptr f)
let on_data      = "on_data"      -- (string @-> returning void)
let on_start_tag = "on_start_tag" -- (string @-> string @-> returning void)
let on_end_tag   = "on_end_tag"   -- (void @-> returning void)
let on_dtd       = "on_dtd"       -- (string @-> returning void) 
let on_error     = "on_error"     -- (int @-> int @-> string @-> returning void)
let () = seal handlers

(* Parse the input, calling each labeled argument when the
   corresponding signal occurs *)
let run ~data ~start_tag ~end_tag ~dtd ~error input =
  let rec loop () =
    if not (Xmlm.eoi input) then
      let () = match Xmlm.input input with
	| `Data s -> data s
	| `Dtd (Some d) -> dtd d
	| `Dtd None -> dtd ""
	| `El_end -> end_tag ()
	| `El_start ((x, y), _) -> start_tag x y
      in loop ()
  in
  try loop ()
  with Xmlm.Error ((l, c), e) ->
    error l c (Xmlm.error_message e)

(* Open the file, pull the function pointers out of the handler
   structure, and call [run]. *)
let parse events filename =
  run
    ~data:(!@(events |-> on_data))
    ~start_tag:(!@(events |-> on_start_tag))
    ~end_tag:(!@(events |-> on_end_tag))
    ~dtd:(!@(events |-> on_dtd))
    ~error:(!@(events |-> on_error))
    (Xmlm.make_input (`Channel (open_in filename)))

module Stubs(I : Cstubs_inverted.INTERNAL) =
struct
  (* Expose the type 'struct handlers' to C. *)
  let () = I.structure handlers

  (* We expose just a single function to C.  The first argument is a (pointer
     to a) struct of callbacks, and the second argument is a string
     representing a filename to parse. *)
  let () = I.internal "parse_xml" (ptr handlers @-> string @-> returning void) parse
end
