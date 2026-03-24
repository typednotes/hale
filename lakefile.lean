import Lake
open System Lake DSL

package hale where
  version := v!"0.1.0"

require «doc-gen4» from git
  "https://github.com/leanprover/doc-gen4" @ "main"

/-- Query `pkg-config` for the given package and flag mode. Returns an empty array on failure. -/
private def pkgConfig (pkg : String) (mode : String) : IO (Array String) := do
  let out ← IO.Process.output { cmd := "pkg-config", args := #[mode, pkg] }
  if out.exitCode == 0 then
    return out.stdout.trimAscii.toString.splitOn " " |>.filter (· != "") |>.toArray
  return #[]

/-- Compile ffi/network.c into an object file. -/
target network.o pkg : FilePath := do
  let oFile := pkg.buildDir / "ffi" / "network.o"
  let srcJob ← inputTextFile <| pkg.dir / "ffi" / "network.c"
  let weakArgs := #["-I", (← getLeanIncludeDir).toString]
  buildO oFile srcJob weakArgs (traceArgs := #["-O2", "-fPIC"]) (extraDepTrace := getLeanTrace)

/-- Compile ffi/tls.c into an object file (requires OpenSSL headers). -/
target tls.o pkg : FilePath := do
  let oFile := pkg.buildDir / "ffi" / "tls.o"
  let srcJob ← inputTextFile <| pkg.dir / "ffi" / "tls.c"
  let sslCflags ← pkgConfig "openssl" "--cflags"
  let weakArgs := #["-I", (← getLeanIncludeDir).toString] ++ sslCflags
  buildO oFile srcJob weakArgs (traceArgs := #["-O2", "-fPIC"]) (extraDepTrace := getLeanTrace)

/-- Bundle the FFI objects into a static library that Lake links automatically. -/
extern_lib haleffi pkg := do
  let networkObj ← network.o.fetch
  let tlsObj ← tls.o.fetch
  buildStaticLib (pkg.staticLibDir / nameToStaticLib "haleffi") #[networkObj, tlsObj]

@[default_target]
lean_lib Hale where
  needs := #[haleffi]
  moreLinkArgs := run_io (pkgConfig "openssl" "--libs")

lean_exe hale where
  root := `Main

lean_lib Tests where
  globs := #[.submodules `Tests]
  needs := #[haleffi]

@[test_driver]
lean_exe «hale-tests» where
  root := `Tests.Main

-- Examples (run with: lake exe <name>)

lean_exe «echo-server» where
  root := `Examples.Echo
