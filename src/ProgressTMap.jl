module ProgressTMap

using ChunkSplitters
using ProgressLogging

export progress_tmap

"""
    progress_pmap(fn, vector[; name = ""])

Spreads a mapped computation evenly across all available threads and
displays a progress bar.
"""
function progress_tmap(fn, vector; name = "")
  n = Threads.nthreads()
  # Split the input vector into chunks for parallel processing
  index_chunks = chunks(vector; n = n)
  # Create a reference to store the results
  output = Ref{Vector}()

  @withprogress name = name begin
    # Create an atomic counter to keep track of completed threads
    thread_counter = Threads.Atomic{Int}(0)

    # Create a lock to synchronize access to the progress bar
    lk = ReentrantLock()

    # Create a task with @spawn for each time chunk
    tasks = map(index_chunks) do index_chunk
      Threads.@spawn begin
        inner = fn.(vector[index_chunk])
        Threads.atomic_add!(thread_counter, 1)
        # Acquire the lock to update the progress bar synchronously
        lock(lk) do
          @logprogress thread_counter[] / n
        end
        return inner
      end
    end
    # Fetch the results from all the tasks and store them in the output reference
    output[] = fetch.(tasks)
  end

  # Stack the output chunks to a single array
  return vcat(output[]...)
end

end
