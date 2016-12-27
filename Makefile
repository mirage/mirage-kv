all:
	ocaml pkg/pkg.ml build -n mirage-kv -q
	ocaml pkg/pkg.ml build -n mirage-kv-lwt -q

clean:
	ocaml pkg/pkg.ml clean -n mirage-kv -q
	ocaml pkg/pkg.ml clean -n mirage-kv-lwt -q
