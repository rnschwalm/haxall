//
// Copyright (c) 2024, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//  4 Apr 2024   Brian Frank  Creation
//

using concurrent
using util
using xeto
using haystack::UnknownLibErr

**
** FileRepo is a file system based repo that uses the the Fantom path to
** find zip versions in "lib/xeto/" and sourceversion in "src/xeto/".
**
const class FileRepo : LibRepo
{
  new make(File[] path := Env.cur.path)
  {
    this.path = path
    rescan
  }

  const Log log := Log.get("xeto")

  const File[] path

  internal FileRepoScan scan() { scanRef.val }
  private const AtomicRef scanRef := AtomicRef()

  override Str toStr() { "$typeof.qname ($scan.ts.toLocale)" }

  override This rescan()
  {
    scanRef.val = FileRepoScanner(log, path).scan
    return this
  }

  override Str[] libs()
  {
    scan.list
  }

  override LibVersion[]? versions(Str name, Bool checked := true)
  {
    versions := scan.map.get(name)
    if (versions != null) return versions
    if (checked) throw UnknownLibErr(name)
    return null
  }

  override LibVersion? latest(Str name, Bool checked := true)
  {
    versions := versions(name, checked)
    if (versions != null) return versions.last
    if (checked) throw UnknownLibErr(name)
    return null
  }

  override LibVersion? version(Str name, Version version, Bool checked := true)
  {
    versions := versions(name, checked)
    if (versions != null)
    {
      index := versions.binaryFind |x| { version <=> x.version }
      if (index >= 0) return versions[index]
    }
    if (checked) throw UnknownLibErr("$name-$version")
    return null
  }

  override LibVersion[] solveDepends(LibVersion[] libs)
  {
    if (libs.isEmpty) throw Err("No libs specified")
    if (libs.size == 1 && libs.first.name == "sys") return LibVersion[libs.first]
    throw Err("TODO")
  }
}

