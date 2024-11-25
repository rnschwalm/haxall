//
// Copyright (c) 2024, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   25 Nov 2024  Brian Frank  Creation
//

using util
using xeto
using xeto::Lib
using xetoEnv
using xetoc
using haystack
using haystack::Dict
using haystack::Ref
using hx

**
** FidelityTest
**
class FidelityTest : AbstractAxonTest
{
  @HxRuntimeTest
  Void test()
  {
    ns := initNamespace(["ph", "ph.points", "hx.test.xeto"])

    verifyFidelity(ns, "bool",  true, true, true)
    verifyFidelity(ns, "int",   123, n(123), 123f)
    verifyFidelity(ns, "float", 72f, n(72f), 72f)
    verifyFidelity(ns, "number", n(90, "kW"), n(90, "kW"), "90kW")
    verifyFidelity(ns, "str", "hello", "hello", "hello")
    verifyFidelity(ns, "uri", `file.txt`, `file.txt`, "file.txt")
    verifyFidelity(ns, "date", Date("2024-11-25"), Date("2024-11-25"), "2024-11-25")
    verifyFidelity(ns, "time", Time("14:30:00"), Time("14:30:00"), "14:30:00")
    verifyFidelity(ns, "dateTime", DateTime("2024-11-25T10:24:35-05:00 New_York"), DateTime("2024-11-25T10:24:35-05:00 New_York"), "2024-11-25T10:24:35-05:00 New_York")
    verifyFidelity(ns, "span", Span("2024-11-25"), Span("2024-11-25"), "2024-11-25")

    verifyFidelity(ns, "tz", TimeZone("Chicago"), "Chicago")
    verifyFidelity(ns, "unit", Unit("ft"), "ft")
    verifyFidelity(ns, "unitQuantity", UnitQuantity.electricCurrentDensity, "electricCurrentDensity")
    verifyFidelity(ns, "spanMode", SpanMode.yesterday, "yesterday")
    verifyFidelity(ns, "version", Version("4.0.9"), "4.0.9")

return  // TODO
    verifyFidelity(ns, "scalarA", Scalar("hx.test.xeto::ScalarA", "alpha"), "alpha")
    verifyFidelity(ns, "scalarB", Scalar("hx.test.xeto::ScalarB", "bravo"), "bravo")
  }

  Void verifyFidelity(LibNamespace ns, Str slot, Obj full, Obj hay, Obj json := hay)
  {
    spec := ns.spec("hx.test.xeto::Fidelity")
    a    := ns.instance("hx.test.xeto::fidelityA")
    b    := ns.instance("hx.test.xeto::fidelityB")

    // spec def val
    v := spec.slot(slot).meta["val"]
    if (debug) echo(">>>> $slot")
    if (debug) echo("   > sd = $v [$v.typeof]")
    verifyValEq(v, full)

    // instantiate spec
    v = ((Dict)ns.instantiate(spec)).get(slot)
    if (debug) echo("   > if = $v [$v.typeof]")
    verifyValEq(v, full)

    // instance A
    v = a.get(slot)
    if (debug) echo("   > af = $v [$v.typeof]")
    verifyValEq(v, full)

    // instance B
    v = b.get(slot)
    if (debug) echo("   > bf = $v [$v.typeof]")
    verifyValEq(v, full)

    // instantiate spec via haystack fidelity
    v = ((Dict)ns.instantiate(spec, Etc.dict1("haystack", m))).get(slot)
    if (debug) echo("   > ih = $v [$v.typeof]")
    verifyValEq(v, hay)

    // instance A piped to toHaystack
    v = XetoUtil.toHaystack(a).trap(slot)
    if (debug) echo("   > ah = $v [$v.typeof]")
    verifyValEq(v, hay)

    // Axon instantiate
    Dict axonI := eval("""spec("hx.test.xeto::Fidelity").instantiate""")
    v = axonI[slot]
    if (debug) echo("   > xi = $v [$v.typeof]")
    verifyValEq(v, hay)

    // Axon instance
    Dict axonA := eval("""instance("hx.test.xeto::fidelityA")""")
    v = axonA[slot]
    if (debug) echo("   > xa = $v [$v.typeof]")
    verifyValEq(v, hay)

    // Axon instances
    Dict axonB := eval("""instances().find(x => x->id.toStr == "hx.test.xeto::fidelityB")""")
    v = axonB[slot]
    if (debug) echo("   > xb = $v [$v.typeof]")
    verifyValEq(v, hay)
  }

  const Bool debug := true
}

