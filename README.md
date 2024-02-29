# ProgressTMap

[![Build Status](https://github.com/OliverDudgeon/ProgressTMap.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/OliverDudgeon/ProgressTMap.jl/actions/workflows/CI.yml?query=branch%3Amaster)

ProgressTMap provides a map function that will spread the workload evenly across all available threads. Via [ProgressLogging.jl](https://github.com/JuliaLogging/ProgressLogging.jl), progress events are emitted as each thread completes its task. These events can be displayed in the VSCode status bar via the [Julia VSCode extension](https://github.com/julia-vscode/julia-vscode/) or as a progress bar in the Julia REPL via the [TerminalLoggers.jl](https://github.com/JuliaLogging/TerminalLoggers.jl) package.

## Installation

To install ProgressTMap, you can use the Julia package manager. Open the Julia REPL and run the following:

```julia
using Pkg
Pkg.add("ProgressTMap.jl")
```

## Example

Say we have a costly function `f` that we want to compute using all available threads on our machine. Luckily evaluations of `f` are independent of each other, so we can don't have any requirement on the of calls of `f`. Using this package, we can multithread this computation as follows.

```julia
using ProgressTMap

f(t) = sleep(t)  # example slow function

ts = 1:100
mapped_result = progress_tmap(f, ts; name="Sleeping")
```

## How it works
The function divides the input into `n` even chunks, where `n` is the number of threads the julia worker is started with (`Threads.nthreads()`). This is done with the [ChunkSplitters.jl](https://github.com/JuliaFolds2/ChunkSplitters.jl) package. [^1] For each chunk, a new `Task` is spawned, on which the function is broadcasted over the chunk. The results of each task are then combined at the end and returned.


[^1]: I hope to expose more options on how the workload is chunked in a later version
