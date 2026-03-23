import Lake
open System Lake DSL

package hale where
  version := v!"0.1.0"

require «doc-gen4» from git
  "https://github.com/leanprover/doc-gen4" @ "main"

/-- Compile ffi/network.c into an object file. -/
target network.o pkg : FilePath := do
  let oFile := pkg.buildDir / "ffi" / "network.o"
  let srcJob ← inputTextFile <| pkg.dir / "ffi" / "network.c"
  let weakArgs := #["-I", (← getLeanIncludeDir).toString]
  buildO oFile srcJob weakArgs (traceArgs := #["-O2", "-fPIC"]) (extraDepTrace := getLeanTrace)

/-- Bundle the FFI object into a static library that Lake links automatically. -/
extern_lib haleffi pkg := do
  let networkObj ← network.o.fetch
  buildStaticLib (pkg.staticLibDir / nameToStaticLib "haleffi") #[networkObj]

@[default_target]
lean_lib Hale where
  needs := #[haleffi]

lean_exe hale where
  root := `Main

lean_lib Tests where
  globs := #[.submodules `Tests]
  needs := #[haleffi]

lean_exe «hale-tests» where
  root := `Tests.Main
