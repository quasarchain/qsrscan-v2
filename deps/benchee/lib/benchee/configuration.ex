defmodule Benchee.Configuration do
  @moduledoc """
  Functions to handle the configuration of Benchee, exposes `init/1` function.
  """

  alias Benchee.{
    Suite,
    Configuration,
    Conversion.Duration,
    Conversion.Scale,
    Utility.DeepConvert,
    Formatters.Console
  }

  defstruct parallel: 1,
            time: 5,
            warmup: 2,
            memory_time: 0,
            pre_check: false,
            formatters: [Console],
            print: %{
              benchmarking: true,
              configuration: true,
              fast_warning: true
            },
            inputs: nil,
            save: false,
            load: false,
            # formatters should end up here but known once are still picked up at
            # the top level for now
            formatter_options: %{
              console: %{
                comparison: true,
                extended_statistics: false
              }
            },
            unit_scaling: :best,
            # If you/your plugin/whatever needs it your data can go here
            assigns: %{},
            before_each: nil,
            after_each: nil,
            before_scenario: nil,
            after_scenario: nil

  @type t :: %__MODULE__{
          parallel: integer,
          time: number,
          warmup: number,
          memory_time: number,
          pre_check: boolean,
          formatters: [(Suite.t() -> Suite.t())],
          print: map,
          inputs: %{Suite.key() => any} | nil,
          save: map | false,
          load: String.t() | [String.t()] | false,
          formatter_options: map,
          unit_scaling: Scale.scaling_strategy(),
          assigns: map,
          before_each: fun | nil,
          after_each: fun | nil,
          before_scenario: fun | nil,
          after_scenario: fun | nil
        }

  @type user_configuration :: map | keyword
  @time_keys [:time, :warmup, :memory_time]

  @doc """
  Returns the initial benchmark configuration for Benchee, composed of defaults
  and an optional custom configuration.

  Configuration times are given in seconds, but are converted to microseconds
  internally.

  Possible options:

    * `warmup` - the time in seconds for which a benchmarking job should be run
    without measuring times before "real" measurements start. This simulates a
    _"warm"_ running system. Defaults to 2.
    * `time` - the time in seconds for how long each individual benchmarking job
    should be run for measuring the execution times (run time performance).
    Defaults to 5.
    * `memory_time` - the time in seconds for how long memory measurements
    should be conducted. Defaults to 0 (turned off).
    * `inputs` - a map from descriptive input names to some different input,
    your benchmarking jobs will then be run with each of these inputs. For this
    to work your benchmarking function gets the current input passed in as an
    argument into the function. Defaults to `nil`, aka no input specified and
    functions are called without an argument.
    * `formatters` - list of formatters either as module implementing the
    formatter behaviour or formatter functions. They are run when using
    `Benchee.run/2`. Functions need to accept one argument (which is the
    benchmarking suite with all data) and then use that to produce output. Used
    for plugins. Defaults to the builtin console formatter
    `Benchee.Formatters.Console`.
    * `pre_check` - whether or not to run each job with each input - including all
    given before or after scenario or each hooks - before the benchmarks are
    measured to ensure that your code executes without error. This can save time
    while developing your suites. Defaults to `false`.
    * `parallel`   - each the function of each job will be executed in
    `parallel` number processes. If `parallel` is `4` then 4 processes will be
    spawned that all execute the _same_ function for the given time. When these
    finish/the time is up 4 new processes will be spawned for the next
    job/function. This gives you more data in the same time, but also puts a
    load on the system interfering with benchmark results. For more on the pros
    and cons of parallel benchmarking [check the
    wiki](https://github.com/PragTob/benchee/wiki/Parallel-Benchmarking).
    Defaults to 1 (no parallel execution).
    * `save` - specify a `path` where to store the results of the current
    benchmarking suite, tagged with the specified `tag`.
    * `load` - load saved suit or suits to compare your current benchmarks
    against. Can be a string or a list of strings or patterns.
    * `print` - a map from atoms to `true` or `false` to configure if the
    output identified by the atom will be printed. All options are enabled by
    default (true). Options are:
      * `:benchmarking`  - print when Benchee starts benchmarking a new job
      (Benchmarking name ..)
      * `:configuration` - a summary of configured benchmarking options
      including estimated total run time is printed before benchmarking starts
      * `:fast_warning`  - warnings are displayed if functions are executed
      too fast leading to inaccurate measures
    * `console` - options for the built-in console formatter:
      * `:comparison`   - if the comparison of the different benchmarking jobs
      (x times slower than) is shown (true/false). Enabled by default.
      * `extended_statistics` - display more statistics, aka `minimum`,
      `maximum`, `sample_size` and `mode`. Disabled by default.
    * `:unit_scaling` - the strategy for choosing a unit for durations and
    counts. May or may not be implemented by a given formatter (The console
    formatter implements it). When scaling a value, Benchee finds the "best fit"
    unit (the largest unit for which the result is at least 1). For example,
    1_200_000 scales to `1.2 M`, while `800_000` scales to `800 K`. The
    `unit_scaling` strategy determines how Benchee chooses the best fit unit for
    an entire list of values, when the individual values in the list may have
    different best fit units. There are four strategies, defaulting to `:best`:
      * `:best`     - the most frequent best fit unit will be used, a tie
      will result in the larger unit being selected.
      * `:largest`  - the largest best fit unit will be used (i.e. thousand
      and seconds if values are large enough).
      * `:smallest` - the smallest best fit unit will be used (i.e.
      millisecond and one)
      * `:none`     - no unit scaling will occur. Durations will be displayed
      in microseconds, and counts will be displayed in ones (this is
      equivalent to the behaviour Benchee had pre 0.5.0)
    * `:before_scenario`/`after_scenario`/`before_each`/`after_each` - read up on them in the hooks section in the README

  ## Examples

      iex> Benchee.init
      %Benchee.Suite{
        configuration:
          %Benchee.Configuration{
            parallel: 1,
            time: 5_000_000,
            warmup: 2_000_000,
            inputs: nil,
            save: false,
            load: false,
            formatters: [Benchee.Formatters.Console],
            print: %{
              benchmarking: true,
              fast_warning: true,
              configuration: true
            },
            formatter_options: %{
              console: %{comparison: true, extended_statistics: false}
            },
            unit_scaling: :best,
            assigns: %{},
            before_each: nil,
            after_each: nil,
            before_scenario: nil,
            after_scenario: nil
          },
        system: nil,
        scenarios: []
      }

      iex> Benchee.init time: 1, warmup: 0.2
      %Benchee.Suite{
        configuration:
          %Benchee.Configuration{
            parallel: 1,
            time: 1_000_000,
            warmup: 200_000.0,
            inputs: nil,
            save: false,
            load: false,
            formatters: [Benchee.Formatters.Console],
            print: %{
              benchmarking: true,
              fast_warning: true,
              configuration: true
            },
            formatter_options: %{
              console: %{comparison: true, extended_statistics: false}
            },
            unit_scaling: :best,
            assigns: %{},
            before_each: nil,
            after_each: nil,
            before_scenario: nil,
            after_scenario: nil
          },
        system: nil,
        scenarios: []
      }

      iex> Benchee.init %{time: 1, warmup: 0.2}
      %Benchee.Suite{
        configuration:
          %Benchee.Configuration{
            parallel: 1,
            time: 1_000_000,
            warmup: 200_000.0,
            inputs: nil,
            save: false,
            load: false,
            formatters: [Benchee.Formatters.Console],
            print: %{
              benchmarking: true,
              fast_warning: true,
              configuration: true
            },
            formatter_options: %{
              console: %{comparison: true, extended_statistics: false}
            },
            unit_scaling: :best,
            assigns: %{},
            before_each: nil,
            after_each: nil,
            before_scenario: nil,
            after_scenario: nil
          },
        system: nil,
        scenarios: []
      }

      iex> Benchee.init(
      ...>   parallel: 2,
      ...>   time: 1,
      ...>   warmup: 0.2,
      ...>   formatters: [&IO.puts/2],
      ...>   print: [fast_warning: false],
      ...>   console: [comparison: false],
      ...>   inputs: %{"Small" => 5, "Big" => 9999},
      ...>   formatter_options: [some: "option"],
      ...>   unit_scaling: :smallest)
      %Benchee.Suite{
        configuration:
          %Benchee.Configuration{
            parallel: 2,
            time: 1_000_000,
            warmup: 200_000.0,
            inputs: %{"Small" => 5, "Big" => 9999},
            save: false,
            load: false,
            formatters: [&IO.puts/2],
            print: %{
              benchmarking: true,
              fast_warning: false,
              configuration: true
            },
            formatter_options: %{
              console: %{comparison: false, extended_statistics: false},
              some: "option"
            },
            unit_scaling: :smallest,
            assigns: %{},
            before_each: nil,
            after_each: nil,
            before_scenario: nil,
            after_scenario: nil
          },
        system: nil,
        scenarios: []
      }
  """
  @spec init(user_configuration) :: Suite.t()
  def init(config \\ %{}) do
    :ok = :timer.start()

    config =
      config
      |> standardized_user_configuration
      |> merge_with_defaults
      |> convert_time_to_micro_s
      |> update_measure_memory
      |> save_option_conversion

    %Suite{configuration: config}
  end

  defp standardized_user_configuration(config) do
    config
    |> DeepConvert.to_map()
    |> translate_formatter_keys
    |> force_string_input_keys
  end

  # backwards compatible translation of formatter keys to go into
  # formatter_options now
  @formatter_keys [:console, :csv, :json, :html]
  defp translate_formatter_keys(config) do
    {formatter_options, config} = Map.split(config, @formatter_keys)
    DeepMerge.deep_merge(%{formatter_options: formatter_options}, config)
  end

  defp force_string_input_keys(config = %{inputs: inputs}) do
    standardized_inputs =
      for {name, value} <- inputs, into: %{} do
        {to_string(name), value}
      end

    %{config | inputs: standardized_inputs}
  end

  defp force_string_input_keys(config), do: config

  defp merge_with_defaults(user_config) do
    DeepMerge.deep_merge(%Configuration{}, user_config)
  end

  defp convert_time_to_micro_s(config) do
    Enum.reduce(@time_keys, config, fn key, new_config ->
      {_, new_config} =
        Map.get_and_update!(new_config, key, fn seconds ->
          {seconds, Duration.microseconds({seconds, :second})}
        end)

      new_config
    end)
  end

  defp update_measure_memory(config = %{memory_time: memory_time}) do
    otp_version = List.to_integer(:erlang.system_info(:otp_release))

    if (memory_time > 0) and otp_version <= 18 do
      print_memory_measure_warning()
      Map.put(config, :memory_time, 0)
    else
      config
    end
  end

  defp print_memory_measure_warning do
    IO.puts("""

      Measuring memory consumption is only available on OTP 19 or greater.
      If you would like to benchmark memory consumption, please upgrade to a
      newer verion of OTP.

    """)
  end

  defp save_option_conversion(config = %{save: false}) do
    config
  end

  defp save_option_conversion(config = %{save: save_values}) do
    save_options = Map.merge(save_defaults(), save_values)

    tagged_save_options = %{
      tag: save_options.tag,
      path: save_options.path
    }

    %__MODULE__{
      config
      | formatters: config.formatters ++ [Benchee.Formatters.TaggedSave],
        formatter_options: Map.put(config.formatter_options, :tagged_save, tagged_save_options)
    }
  end

  defp save_defaults do
    now = DateTime.utc_now()

    %{
      tag: "#{now.year}-#{now.month}-#{now.day}--#{now.hour}-#{now.minute}-#{now.second}-utc",
      path: "benchmark.benchee"
    }
  end
end

defimpl DeepMerge.Resolver, for: Benchee.Configuration do
  def resolve(_original, override = %{__struct__: Benchee.Configuration}, _) do
    override
  end

  def resolve(original, override, resolver) when is_map(override) do
    merged = Map.merge(original, override, resolver)
    struct!(Benchee.Configuration, Map.to_list(merged))
  end
end
