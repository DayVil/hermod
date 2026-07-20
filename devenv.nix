{ pkgs, lib, config, inputs, ... }:
let
  isLinux = pkgs.stdenv.isLinux;
  odinPath = if isLinux then (lib.getExe pkgs.odin) else "odin";

  odin_flags = "-file";
  odin_debug_flags = odin_flags + " -debug" + lib.optionalString (!isLinux) " -use-single-module";
in
{
  packages = with pkgs; [
    just
    curl
    binutils
    mbedtls
  ] ++ lib.optionals isLinux [
    git
    valgrind
  ];

  languages.odin.enable = isLinux;

  files."justfile".text = ''
    odin_exe_path := "${odinPath}"

    main_file_path := "." / "examples" / "main" / "main.odin"
    out_path := "." / "out"
    out_bin_path := out_path / "main"

    odin_flags := "${odin_flags}"
    odin_debug_flags := "${odin_debug_flags}"

    default: run

    clean:
      -${lib.getExe pkgs.trash-cli} {{out_path}}
      
    run:
      {{odin_exe_path}} run {{main_file_path}} {{odin_debug_flags}}

    build:
      mkdir -p {{out_path}}
      {{odin_exe_path}} build {{main_file_path}} {{odin_flags}} -strict-style -out:{{out_bin_path}} -reloc-mode:pic -build-mode:exe
      
    build-run: build
      {{out_bin_path}}
  '';
}
