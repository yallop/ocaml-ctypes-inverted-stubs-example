(*
 * Copyright (c) 2014 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)

(** Apply the Stubs functor to the generated bindings to link the generated
    code into the library. *)
include Bindings.Stubs(Xmlm_bindings)
