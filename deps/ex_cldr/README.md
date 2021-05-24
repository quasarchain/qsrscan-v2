# Getting Started with Cldr
![Build Status](http://sweatbox.noexpectations.com.au:8080/buildStatus/icon?job=cldr)
[![Hex.pm](https://img.shields.io/hexpm/v/ex_cldr.svg)](https://hex.pm/packages/ex_cldr)
[![Hex.pm](https://img.shields.io/hexpm/dw/ex_cldr.svg?)](https://hex.pm/packages/ex_cldr)
[![Hex.pm](https://img.shields.io/hexpm/dt/ex_cldr.svg?)](https://hex.pm/packages/ex_cldr)
[![Hex.pm](https://img.shields.io/hexpm/l/ex_cldr.svg)](https://hex.pm/packages/ex_cldr)

## Introduction

`Cldr` is an Elixir library for the [Unicode Consortium's](http://unicode.org) [Common Locale Data Repository (CLDR)](http://cldr.unicode.org).  The intentions of CLDR, and this library, is to simplify the locale specific formatting of numbers, lists, currencies, calendars, units of measure and dates/times.  As of November 2020 and `ex_cldr` Version 2.18.0, `Cldr` is based upon [CLDR version 38.0.0](http://cldr.unicode.org/index/downloads/cldr-38).

The first step is to define a module that will host the desired `Cldr` configuration and the functions that serve as the public API.  This module is referred to in this documentation as a `backend` module. For example:

```elixir
@doc """
Define a backend module that will host our
Cldr configuration and public API.

Most function calls in Cldr will be calls
to functions on this module.
"""
defmodule MyApp.Cldr do
  use Cldr,
    locales: ["en", "fr", "zh", "th"],
    default_locale: "en"

end
```

This strategy means that different configurations can be defined and it also
means that one `Cldr` implementation won't interfer with implementations in other,
potentially dependent, applications.

The functions you are mostly likely to use are:

* `MyApp.Cldr.default_locale/0`
* `MyApp.Cldr.put_locale/1`
* `MyApp.Cldr.get_locale/0`
* `MyApp.Cldr.known_locale_names/0`
* `MyApp.Cldr.Locale.new/1`

To access the raw Cldr data for a locale the `Cldr.Config` module is available.  Note that the functions in `Cldr.Config` are typically used by library authors.  The most useful function is:

* `Cldr.Config.get_locale/2` which returns a map of all the CLDR data known to `Cldr`.  Since this data is read from a file, parsed and then formatted it is a function that should be used with care due to the material performance implications.  `Cldr` uses this function during compilation to build functions that return the relevant data with higher performance and these functions are to be preferred over the use of `Cldr.Config.get_locale/2`.

## Use this package when you have a requirement to...

* Support multiple languages and locales in your application

* Need to support formatting numbers, dates, times, date-times, units and lists in one language or many

* Access the data maintained in the CLDR repository in a functional manner

* Parse an [Accept-Language](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4) http header or a [language tag](https://tools.ietf.org/html/bcp47)

**It is highly likely that you will also want to install one or more of the dependent packages that provide localization and formatting for a particular data domain.  See [Additional Cldr Packages](#additional-cldr-packages) below**.

## Elixir Version Requirements

* [ex_cldr](https://hex.pm/packages/ex_cldr) requires Elixir 1.6 or later.

## Installation

Add `ex_cldr` and the JSON library of your choice as a dependencies to your `mix` project:

```elixir
defp deps do
  [
    {:ex_cldr, "~> 2.0"},
    # Posion or any other compatible json library
    # that implements `encode!/1` and `decode!/1`
    # :jason is recommended
    {:jason, "~> 1.0"}
    # {:poison, "~> 2.1 or ~> 3.0"}
  ]
end
```

then retrieve `ex_cldr` and the JSON library from [hex](https://hex.pm/packages/ex_cldr):
```elixir
mix deps.get
mix deps.compile
```

## Additional Cldr Packages

`ex_cldr` includes only basic functions to maintain the CLDR data repository in an accessible manner and to manage locale definitions.  Additional functionality is available by adding additional packages:

* Number formatting: [ex_cldr_numbers](https://hex.pm/packages/ex_cldr_numbers)
* List formatting: [ex_cldr_lists](https://hex.pm/packages/ex_cldr_lists)
* Unit formatting: [ex_cldr_units](https://hex.pm/packages/ex_cldr_units)
* Date/Time/DateTime formatting: [ex_cldr_dates_times](https://hex.pm/packages/ex_cldr_dates_times)
* Calendars: [ex_cldr_calendars](https://hex.pm/packages/ex_cldr_calendars)
* Calendar formatting: [ex_cldr_calendars_format](https://hex.pm/packages/ex_cldr_calendars_format)
* Printf-like formatting: [ex_cldr_print](https://hex.pm/packages/ex_cldr_print)
* Collation: [ex_cldr_collation](https://hex.pm/packages/ex_cldr_collation)
* ICU Message formatting: [ex_cldr_messages](https://hex.pm/packages/ex_cldr_messages)
* Territories localization and information: [ex_cldr_territories](https://hex.pm/packages/ex_cldr_territories) by @Schultzer
* Languages localization: [ex_cldr_languages](https://hex.pm/packages/ex_cldr_languages) by @lostkobrakai

Each of these packages includes `ex_cldr` as a dependency so configuring any of these additional packages will automatically install `ex_cldr`.

## Configuration

`Cldr` attempts to maximise runtime performance at the expense of additional compile time.  Where possible `Cldr` will create functions to encapsulate data at compile time.  To perform these optimizations for all 541 locales known to Cldr wouldn't be an effective use of your time or your computer's.  Therefore `Cldr` requires that you configure the locales you want to use.

The preferred way to configure `Cldr` is to define the configuration in your backend module. This removes any dependency on your `mix.exs` and therefore simplifies deployment as a release.  However configuration can also be defined in other ways:

### Global configuration.

In `mix.exs` a global configuration can be defined under the `:ex_cldr` key.  Although any valid configuration keys can be used here, only the keys `:json_library`, `:cacertfile` and `default_locale` are considered valid.  Other configuration keys may be used to aid migration from `Cldr` version 1.x but a deprecation message will be printed during compilation.  Here's an example of global configuration:

```elixir
config :ex_cldr,
  default_locale: "en",
  default_backend: MyApp.Cldr,
  json_library: Jason,
  cacertfile: "path/to/cacertfile"
```

Note that the `:json_library` key can only be defined at the global level since it is required during compilation before any backend module is compiled.

On most platforms other than Windows the `:cacertfile` will be automatically detected. Any configured `:cacertfile` will take precedence on all platforms.

**If configuration beyond the keys `:default_locale`, `:cacertfile` or `:json_library` are defined a deprecation warning is printed at compile time noting that configuration should be moved to a backend module.**


### Backend Module Configuration

The preferred configuration method is to define the configuration in the backend module.  The configuration keys are the same so the preferred way to achieve the same configuration as defined in the global example is:

```elixir
defmodule MyApp.Cldr do
  use Cldr,
    default_locale: "en",
    locales: ["fr", "en", "bs", "si", "ak", "th"],
    gettext: MyApp.Gettext,
    data_dir: "./priv/cldr",
    otp_app: :my_app,
    precompile_number_formats: ["¤¤#,##0.##"],
    precompile_transliterations: [{:latn, :arab}, {:thai, :latn}],
    providers: [Cldr.Number],
    generate_docs: true,
    force_locale_download: false
end
```

### Otp App Configuration

In the backend configuration example above the `:otp_app` key has been defined.  This means that configuration for `Cldr` has been defined in `mix.exs` under the key `:my_app` with the sub-key `MyApp.Cldr`.  For example:

```elixir
defmodule MyApp.Cldr do
  use Cldr, otp_app: :my_app
end
```

```elixir
# In mix.exs
config :my_app, MyApp.Cldr,
  default_locale: "en",
  locales: ["fr", "en", "bs", "si", "ak", "th"],
  gettext: MyApp.Gettext,
  data_dir: "./priv/cldr",
  precompile_number_formats: ["¤¤#,##0.##"],
  precompile_transliterations: [{:latn, :arab}, {:thai, :latn}]
```

Multiple backends can be configured under a single `:otp_app` if required.

### Configuration Priority

When building the consolidated configuration the following priority applies:

* Consider the global configuration
* Merge the otp_app configuration over the top of the global configuration
* Merge the backend module configuration over the top

### Backend Configuration Keys

The configuration keys available for `Cldr` are:

 * `default_locale` specifies the default locale to be used for this backend.  The default locale in case no other locale has been set is `"en-001"`.  The default locale calculated as follows:

     * If set by the `:default_locale` key, then this is the priority
     * If no `:default_locale` key, then a configured `Gettext` default locale for this backend is chosen
     * If no `:default_locale` key is specified and no `Gettext` module is configured, or is configured but has no default set, use `Cldr.default_locale/0` which returns either the default locale configurated in `mix.exs` under the `ex_cldr` key or then the system default locale will is currently `en-001`

 * `locales`: Defines what locales will be configured in `Cldr`.  Only these locales will be available and an exception `Cldr.UnknownLocaleError` will be raised if there is an attempt to use an unknown locale.  This is the same behaviour as `Gettext`.  Locales are configured as a list of binaries (strings).  For convenince it is possible to use wildcard matching of locales which is particulalry helpful when there are many regional variances of a single language locale.  For example, there are over 100 regional variants of the "en" locale in CLDR.  A wildcard locale is detected by the presence of `.`, `[`, `*` and `+` in the locale string.  This locale is then matched using the pattern as a `regex` to match against all available locales.  The example below will configure all locales that start with `en-` and the locale `fr`.

```elixir
use Cldr,
  default_locale: "en",
  locales: ["en-*", "fr"]
```

 * There is one additional setting which is `:all` which will configure all 541 locales.  **This is highly discouraged** since it will take many minutes to compile your project and will consume more memory than you really want.  This setting is there to aid in running the test suite.  Really, don't use this setting.

 * `:gettext`: configures `Cldr` to use a `Gettext` module as an additional source of locales you want to configure.  Since `Gettext` uses the Posix locale name format (locales with an '\_' in them) and `Cldr` uses the Unicode format (a '-' as the subtag separator), `Cldr` will transliterate locale names from `Gettext` into the `Cldr` canonical form.

 * `:data_dir`: indicates where downloaded locale files will be stored.  The default is `:code.priv_dir(otp_app)` where `otp_app` is the app defined under the `:otp_app` configuration key.  If that key is not specified then the `:ex_cldr` app is used. It is recommended that an `:otp_app` key is specified in your backend module configuration.

 * `:precompile_number_formats`: provides a means to have user-defined format strings precompiled at application compile time.  This has a performance benefit since precompiled formats execute approximately twice as fast as formats that are not precompiled.

 * `:precompile_transliterations`: defines those transliterations between the digits of two different number systems that will be precompiled.  The is a list of 2-tuples where each tuple is of the form `{from_number_system, to_number_system}` where each number system is expressed as an atom.  The available  number systems is returned by `Cldr.Number.System.systems_with_digits/0`.  The default is the empty list `[]`.

 * `:precompile_date_time_formats`: provides a means to have user-defined date, time and date time format strings precompiled at application compile time.  This has a performance benefit since precompiled formats execute approximately twice as fast as formats that are not precompiled. These formats are used by [ex_cldr_date_times](https://hex.pm/packages/ex_cldr_dates_times).

 * `:precompile_interval_formats`: provides a means to have user-defined interval format strings precompiled at application compile time.  This has a performance benefit since precompiled formats execute approximately twice as fast as formats that are not precompiled. These formats are used by [ex_cldr_date_times](https://hex.pm/packages/ex_cldr_dates_times).

 * `:providers`: a list of modules that provide `Cldr` functionality to be compiled into the backend module. See the [providers](#providers) section below.

 * `:generate_docs` defines whether or not to generate documentation for the modules built as part of the backend.  Since these modules represent the public API for `ex_cldr`, the default is `true`.  Setting this key to `false` (the atom `false`, not a *falsy* value) which prevent the generation of docs for this backend.

 * `:supress_warnings` defines whether warnings are logged when a provider module is configured but not available. It also controls whether warnings are logged when a number format is compiled at runtime. Its purpose is to help identify those formats which might best be added to the `:precompile_number_formats` configuration. The default is `false`. Warning are not logged when set to `true`.

 * `:force_locale_download` determines whether to always download locale files during compilation. Locale data is `ex_cldr` version dependent. When a new version of `ex_cldr` is installed, no locales are installed and therefore locales are downloaded at compilation time as required. This ensures that the right version of the locale data is always associated with the right version of `ex_cldr`. However if locale data is being cached in CI/CD there is some possibility that there can be a version mismatch.  Since reproducable builds are important, setting the `force_locale_download: true` in a backend or in global configuration adds additional certainty. The default setting is `false` thereby retaining compatibility with existing behaviour. The configuration can also be made dependent on `mix` environment as shown in this example:

```elixir
defmodule MyApp.Cldr do
  use Cldr,
    locales: ["en", "fr"],
    default_locale: "en",
    force_locale_download: Mix.env() == :prod
end
```

### Providers

The data maintained by [CLDR](https://cldr.unicode.org) is quite large and not all capabilities are required by all applications.  Hence `Cldr` has additional optional functionality that can be provided through additional `hex` packages. In order to support compile-time additions to a configured `backend`, any package can define a provider that will be called at compile time.

The currently known providers and their `hex` package names are:

  | Hex Package          | Provider Module   | Comment                                     |
  | :------------------- | :---------------- | :------------------------------------------ |
  | ex_cldr_numbers      | Cldr.Number       | Formatting of numbers, currencies           |
  | ex_cldr_lists        | Cldr.List         | Formatting of lists                         |
  | ex_cldr_units        | Cldr.Unit         | Formatting of SI and Imperial units         |
  | ex_cldr_territories  | Cldr.Territory    | Formatting of territory (country) data      |
  | ex_cldr_languages    | Cldr.Language     | Formatting of language information          |
  | ex_cldr_dates_times  | Cldr.DateTime     | Formatting of dates, times & datetimes      |
  | ex_money             | Money             | Operations and formatting of a money type   |
  | ex_messages          | Cldr.Message      | Formatting of ICU-formatted messages        |

Any library author can create a provider module by exposing a function called `cldr_backend_provider/1` that takes a `Cldr.Config` struct as a single parameter.  The function should return an AST that is inserted into the `backend` module being compiled.

Providers are configured on each backend module under the `:providers` key. It must be a list of provider modules.  For example:
```elixir
defmodule MyApp.Cldr do
  use Cldr,
    locales: ["en", "zh"],
    default_locale: "en",
    providers: [Cldr.Number, Cldr.List]
end
```
**If :providers is `nil` (the default), `Cldr` will attempt to configure all of the providers described above if they have been installed as `deps`.  If you don't wish to invoke any providers, use the empty list `[]`.**

## Migrating from Cldr 1.x

1. Create a `backend` module by following the [configuration](#configuration) instructions
2. Delete any duplicated [global configuration](#global-configuration) in any `config.exs` files. Only the keys `:default_locale` and `:json_library` are supported in the global configuration
3. Update any [plugs](#plugs) to configure the desired backend
4. Adjust any API calls from `Cldr.some_function` to `MyApp.Cldr.some_function`.  Or better still, alias your backend module where required.  ie. `alias MyApp.Cldr, as: Cldr`

## Downloading Configured Locales

`Cldr` can be installed from either [github](https://github.com/kipcole9/cldr)
or from [hex](https://hex.pm/packages/ex_cldr).

* If installed from github then all 541 locales are installed when the repo is cloned into your application deps.

* If installed from hex then only the locales "en", "en-001" and "root" are installed.  When you configure additional locales these will be downloaded during application compilation.

## Localizing and Formatting Numbers

The `Cldr.Number` module implemented in the [ex_cldr_numbers](https://hex.pm/packages/ex_cldr_numbers) package provides number formatting.  The public API for number formatting is `MyApp.Cldr.Number.to_string/2`.  Some examples:
```elixir
iex> MyApp.Cldr.Number.to_string 12345
"12,345"

iex> MyApp.Cldr.Number.to_string 12345, locale: "fr"
"12 345"

iex> MyApp.Cldr.Number.to_string 12345, locale: "fr", currency: "USD"
"12 345,00 $US"

iex> MyApp.Cldr.Number.to_string 12345, format: "#E0"
"1.2345E4"

iex(> MyApp.Cldr.Number.to_string 1234, format: :roman
"MCCXXXIV"

iex> MyApp.Cldr.Number.to_string 1234, format: :ordinal
"1,234th"

iex> MyApp.Cldr.Number.to_string 1234, format: :spellout
"one thousand two hundred thirty-four"
```
See `h MyApp.Cldr.Number` and `h MyApp.Cldr.Number.to_string` in `iex` for further information.

## Localizing Lists

The `Cldr.List` module provides list formatting and is implemented in the [ex_cldr_lists](https://hex.pm/packages/ex_cldr_lists) package.  The public API for list formating is `Cldr.List.to_string/2`.  Some examples:
```elixir
iex> MyApp.Cldr.List.to_string(["a", "b", "c"], locale: "en")
"a, b, and c"

iex> MyApp.Cldr.List.to_string(["a", "b", "c"], locale: "en", format: :unit_narrow)
"a b c"

iex> MyApp.Cldr.List.to_string(["a", "b", "c"], locale: "fr")
"a, b et c"
```
See `h MyApp.Cldr.List` and `h MyApp.Cldr.List.to_string` in `iex` for further information.

## Localizing Units

The `Cldr.Unit` module provides unit localization and is implemented in the [ex_cldr_units](https://hex.pm/packages/ex_cldr_units) package.  The public API for unit localization is `Cldr.Unit.to_string/3`. Some examples:
```elixir
iex> MyApp.Cldr.Unit.to_string 123, :gallon
"123 gallons"

iex> MyApp.Cldr.Unit.to_string 1234, :gallon, format: :long
"1 thousand gallons"

iex> MyApp.Cldr.Unit.to_string 1234, :gallon, format: :short
"1K gallons"

iex> MyApp.Cldr.Unit.to_string 1234, :megahertz
"1,234 megahertz"

iex> MyApp.Cldr.Unit.available_units
[:acre, :acre_foot, :ampere, :arc_minute, :arc_second, :astronomical_unit, :bit,
 :bushel, :byte, :calorie, :carat, :celsius, :centiliter, :centimeter, :century,
 :cubic_centimeter, :cubic_foot, :cubic_inch, :cubic_kilometer, :cubic_meter,
 :cubic_mile, :cubic_yard, :cup, :cup_metric, :day, :deciliter, :decimeter,
 :degree, :fahrenheit, :fathom, :fluid_ounce, :foodcalorie, :foot, :furlong,
 :g_force, :gallon, :gallon_imperial, :generic, :gigabit, :gigabyte, :gigahertz,
 :gigawatt, :gram, :hectare, :hectoliter, :hectopascal, :hertz, :horsepower,
 :hour, :inch, ...]
```
See `h MyApp.Cldr.Unit` and `h MyApp.Cldr.Unit.to_string` in `iex` for further information.

## Localizing Dates, Times and DateTimes

Formatting of relative dates and date times is supported in the `Cldr.DateTime.Relative` module implemented in the [ex_cldr_dates_times](https://hex.pm/packages/ex_cldr_dates_times) package.  The public API is `MyApp.Cldr.DateTime.to_string/2` and `MyApp.Cldr.DateTime.Relative.to_string/2`.  Some examples:
```elixir
iex> MyApp.Cldr.Date.to_string Date.utc_today()
{:ok, "Aug 18, 2017"}

iex> MyApp.Cldr.Time.to_string Time.utc_now
{:ok, "11:38:55 AM"}

iex> MyApp.Cldr.DateTime.to_string DateTime.utc_now
{:ok, "Aug 18, 2017, 11:39:08 AM"}

iex> MyApp.Cldr.DateTime.Relative.to_string 1, unit: :day, format: :narrow
{:ok, "tomorrow"}

iex> MyApp.Cldr.DateTime.Relative.to_string(1, unit: :day, locale: "fr")
"demain"

iex> MyApp.Cldr.DateTime.Relative.to_string(1, unit: :day, format: :narrow)
"tomorrow"

iex> MyApp.Cldr.DateTime.Relative.to_string(1234, unit: :year)
"in 1,234 years"

iex> MyApp.Cldr.DateTime.Relative.to_string(1234, unit: :year, locale: "fr")
"dans 1 234 ans"
```
## Gettext Backend Pluralization Support

There is an experimental plurals module for Gettext called `Cldr.Gettext.Plural`.  It is configured in `Gettext` by:
```elixir
    defmodule MyApp.Gettext do
      use Gettext, plural_forms: Cldr.Gettext.Plural
    end
```

`Cldr.Gettext.Plural` will fall back to `Gettext` pluralisation if the locale is not known to `Cldr`.  This module is only compiled if `Gettext` is configured as a dependency in your project.

Note that `Cldr.Gettext.Plural` does not guarantee to return the same `plural index` as `Gettext`'s own pluralization engine which can introduce some compatibility issues if you plan to mix plural engines.

## Plugs

`Cldr` provides two plugs to aid integration into an HTTP workflow.  These two plugs are:

* `Cldr.Plug.AcceptLanguage` which will parse an `accept-language` header and resolve the best matched and configured `Cldr` locale. The result is stored in `conn.private[:cldr_locale]` which is also returned by `Cldr.Plug.AcceptLanguage.get_cldr_locale/1`.

* `Cldr.Plug.SetLocale` which will look for a locale in the several places and then call `Cldr.put_locale/2` and `Gettext.put_locale/2` if configured so to do. Finally, The result is stored in `conn.private[:cldr_locale]` which is then available through `Cldr.Plug.SetLocale.get_cldr_locale/1`. The plug will look for a locale in the following locations depending on the plug configuration:

  * `path_params`
  * `query_params`
  * `body_params`
  * `cookies`
  * `accept-language` header
  * the `session`

See `Cldr.Plug.SetLocale` for a description of how to configure the plug.

In addition, note that when migrating from `ex_cldr` 1.x versions, a backend needs to be configured for both plugs. In the simplest case an example would be:
```elixir
plug Cldr.Plug.SetLocale,
  apps:    [:cldr],
  cldr:    MyApp.Cldr

plug Cldr.Plug.AcceptLanguage,
  cldr_backend: MyApp.Cldr
```

### Using Cldr.Plug.SetLocale without Phoenix

If you are using `Cldr.Plug.SetLocale` without Phoenix and you plan to use `:path_param` to identify the locale of a request then `Cldr.Plug.SetLocale` must be configured *after* `plug :match` and *before* `plug :dispatch`.  For example:
```elixir
defmodule MyRouter do
  use Plug.Router

  plug :match

  plug Cldr.Plug.SetLocale,
    apps: [:cldr, :gettext],
    from: [:path, :query],
    gettext: MyApp.Gettext,
    cldr: MyApp.Cldr

  plug :dispatch

  get "/hello/:locale" do
    send_resp(conn, 200, "world")
  end
end
```

### Using Cldr.Plug.SetLocale with Phoenix

If you are using `Cldr.Plug.SetLocale` with Phoenix and you plan to use the `:path_param` to identify the locale of a request then `Cldr.Plug.SetLocale` must be configured in the router module, *not* in the endpoint module. This is because `conn.path_params` has not yet been populated in the endpoint. For example:
```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug Cldr.Plug.SetLocale,
	    apps: [:cldr, :gettext],
	    from: [:path, :query],
	    gettext: MyApp.Gettext,
	    cldr: MyApp.Cldr
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/:locale", HelloWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

end
```

## About Language Tags and Locale strings

Note that `Cldr` defines locale strings according to the [IETF standard](https://en.wikipedia.org/wiki/IETF_language_tag) as defined in [RFC5646](https://tools.ietf.org/html/rfc5646).  `Cldr` also implements the `u` extension as defined in [RFC6067](https://tools.ietf.org/html/rfc6067) and the `t` extension defined in [RFC6497](https://tools.ietf.org/html/rfc6497). This is also the standard used by [W3C](https://www.w3.org/TR/ltli/).

The IETF standard is slightly different to the [ISO/IEC 15897](http://www.open-std.org/jtc1/sc22/wg20/docs/n610.pdf) standard used by Posix-based systems; primarily in that ISO 15897 uses a "_" separator whereas IETF and W3C use "-".

Locale string are case insensitive but there are common conventions:

* Language codes are lower-cased
* Territory codes are upper-cased
* Script names are capital-cased

### Locale extensions

Unicode defines the [U extension](https://unicode.org/reports/tr35/#Locale_Extension_Key_and_Type_Data) which support defining the requested treatment of CLDR data formats. For example, a locale name
can configure the requested:

* calendar to be used for dates
* collation
* currency
* currency format
* number system
* first day of the week
* 12-hour or 24-hour time
* time zone
* and many other items

For example, the following locale name will request the use of the timezone `Australia/Sydney`,
and request the use of `accounting` format when formatting currencies:
```elixir
iex> MyApp.Cldr.validate_locale "en-AU-u-tz-ausyd-cf-account"
{:ok,
 %Cldr.LanguageTag{
   canonical_locale_name: "en-Latn-AU",
   cldr_locale_name: "en-AU",
   extensions: %{},
   gettext_locale_name: "en",
   language: "en",
   language_subtags: [],
   language_variant: nil,
   locale: %{currency_format: :accounting, timezone: "Australia/Sydney"},
   private_use: [],
   rbnf_locale_name: "en",
   requested_locale_name: "en-AU",
   script: "Latn",
   territory: "AU",
   transform: %{}
 }}
```
The implementation of these extensions is governed by each library in the `ex_cldr` family. As of January 2020, [ex_cldr_numbers version 2.10](https://hex.pm/packages/ex_cldr_numbers/2.10.0) implements the following `U` extension keys:

* `cf` (currency format)
* `cu` (currency)
* `nu` (number system)

Other libraries in the family will progressively implement other extension keys.

### Notes

* A language code is an ISO3166 language code.
* Potentially one or more modifiers separated by `-` (dash), not a `_`. (underscore).  If you configure a `Gettext` module then `Cldr` will transliterate `Gettext`'s `_` into `-` for compatibility.
* Typically the modifier is a territory code.  This is commonly a two-letter uppercase combination.  For example `pt-PT` is the locale referring to Portugese as used in Portugal.
* In `Cldr` a locale name is always a `binary` and never an `atom`.  Internally a locale is parsed and stored as a `Cldr.LanguageTag` struct.
* The locales known to `Cldr` can be retrieved by `Cldr.known_locale_names/1` to get the locales known to this configuration of `Cldr` and `Cldr.all_locale_names/0` to get the locales available in the CLDR data repository.

## Testing

Tests cover the full 566 locales defined in CLDR. Since `Cldr` attempts to maximize the work done at compile time in order to minimize runtime execution, the compilation phase for tests is several minutes.

Tests are run on Elixir 1.6 and later.  `Cldr` will not run on Elixir versions before 1.6.

## Developing ex_cldr

See the file `DEVELOPMENT.md`

