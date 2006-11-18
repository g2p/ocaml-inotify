(* unit testing inotify *)

open Printf

let _ =
	if Array.length Sys.argv < 2 then (
		eprintf "usage: %s <path>\n" Sys.argv.(0);
		exit 1
	);

	let fd = Inotify.init () in
	let wd = Inotify.add_watch fd Sys.argv.(1) [ Inotify.All ] in

	let string_of_event ev =
		let wd,mask,cookie,s = ev in
		let mask = String.concat ":" (List.map Inotify.string_of_event mask) in
		let s = match s with Some s -> s | None -> "\"\"" in
		sprintf "wd [%u] mask[%s] cookie[%ld] %s" wd mask cookie s
		in

	let nb = ref 0 in
	while true
	do
		let _, _, _ = Unix.select [ fd ] [] [] (-1.) in
		let evs = Inotify.read fd in
		List.iter (fun ev ->
			printf "[%d] %s\n%!" !nb (string_of_event ev)) evs;
		incr nb
	done;

	Unix.close fd
