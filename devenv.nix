{ pkgs, lib, config, inputs, ... }:

{
  packages = with pkgs; [
    git
    just
  ];

  languages.odin.enable = true;

  files."justfile".text = ''
    odin_exe_path := "${lib.getExe pkgs.odin}"

    main_file_path := "." / "main.odin"
    out_path := "." / "out"
    out_bin_path := out_path / "main"

    odin_flags := "-file -debug"

    default: run

    clean:
      -${lib.getExe pkgs.trash-cli} {{out_path}}
      
    run:
      {{odin_exe_path}} run {{main_file_path}} {{odin_flags}}

    build:
      mkdir -p {{out_path}}
      {{odin_exe_path}} build {{main_file_path}} {{odin_flags}} -strict-style -out:{{out_bin_path}} -reloc-mode:pic -build-mode:exe
      
    build-run: build
      {{out_bin_path}}
  '';
}
