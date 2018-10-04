open Mirage_kv

let path = Alcotest.testable Path.pp Path.equal

let path_v () =
  let check s =  Alcotest.(check string) s s Path.(to_string @@ v s) in
  check "/foo/bar";
  check "/foo";
  check "/";
  check "foo/bar";
  check ""

let path_add_seg () =
  let check t e =
    let f = t ^ "/" ^ e in
    let vt = Path.v t in
    Alcotest.(check string) f f Path.(to_string @@ vt / e);
    Alcotest.(check path) f vt Path.(parent @@ vt / e);
    Alcotest.(check string) f e Path.(basename @@ vt / e)
  in
  check ""         "bar";
  check "/"        "foo";
  check "/foo"     "bar";
  check "/foo/bar" "toto"

let path_append () =
  let check x y =
    let f = x ^ "/" ^ y in
    let vf = Path.v f in
    Alcotest.(check path) f vf Path.(v x // v y);
    Alcotest.(check string) x Path.(basename vf) Path.(basename @@ v y)
  in
  check ""         "foo/bar";
  check "/foo"     "bar";
  check "/foo/bar" "toto/foox/ko"

let () = Alcotest.run "mirage-kv" [
    "path", [
      "Path.v"      , `Quick, path_v;
      "Path.add_seg", `Quick, path_add_seg;
      "Path.append" , `Quick, path_append;
    ]
  ]
