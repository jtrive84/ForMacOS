## Shared Data Parallel Processing in Python
###### Author: James Triveri


### Setup
The Python multiprocessing library exposes an interface that simplifies distributing tasks to multiple cores. The `multiprocessing.Pool` class provides access to a pool of worker processes to which jobs can be submitted. It supports asynchronous results with timeouts and callbacks and has a parallel map implementation. Leveraging `multiprocessing.Pool` is straightforward. To demonstrate, we will solve [Project Euler Problem #14](https://projecteuler.net/problem=14) with parallel processing. The problem states:

```text
The following iterative sequence is defined for the set of positive integers:

n ->    n/2 (n is even)
n -> 3n + 1 (n is odd)

Using the rule above and starting with 13, we generate the following sequence:

13 -> 40 -> 20 -> 10 -> 5 -> 16 -> 8 -> 4 -> 2 -> 1

It can be seen that this sequence (starting at 13 and finishing at 1) contains 
10 terms. Although it has not been proved yet (Collatz Problem), it is thought 
that all starting numbers finish at 1.

Which starting number, under one million, produces the longest chain?

NOTE: Once the chain starts the terms are allowed to go above one million.
```


To begin, we define two functions: `collatz_test` and `chain_length`. `collatz_test` encapsulates the logic that either divides the input by 2 (if even) or multiplies it by 3 and adds 1 (if odd). `chain_length` returns a tuple consisting of the initial integer along with the length of the collatz chain. The logic after the `if __name__ == "__main__"` guard initializes the shared array and processing pool, and distributes tasks to each worker using `pool.map`:


```python
"""
Convenience functions for Project Euler #14.
"""

def collatz_test(n):
    """
    If n is even, return (n/2), else return (3n+1).
    """
    return((n / 2) if n%2==0 else (3 * n + 1))


def chain_length(n):
    """
    Return the length of the collatz chain along with the input value`n.
    """
    if n<=0: return(None)
    cntr, tstint = 0, n
    while tstint!=1:
        cntr+=1
        tstint = collatz_test(tstint)
    return(n, cntr)


if __name__ == "__main__":

    # Initialize array of values to test.
    arr  = multiprocessing.Array('L', range(1, 1000000))
    pool = multiprocessing.Pool()
    all_lengths = pool.map(chain_length, arr, chunksize=1000)
    pool.close()
    pool.join()

    # Search pool_results for longest chain.
    longest_chain = max((i for i in all_lengths), key=lambda x: x[1])
    

```

When using the multiprocessing library, instances of the `Pool` and `Process` classes can only be initialized after the if `__name__ == "__main__"` guard, and as a consequence `multiprocessing.Pool` cannot be called from within an interactive Python session.

We first declare our sequence of test values as `multiprocessing.Array`, which prevents the same 1,000,000 element sequence from being replicated in each process/worker. Instead, the array will be created once, and all processes will have access to it. The `"L"` typecode comes from Python Standard Library array module, which indicates the datatype of the elements contained in the sequence. We initialize the `multiprocessing.Pool` instance, then call its `map` method, which works similarly to the builtin `map` function, only in parallel. Within `pool.map`, We set `chunksize=1000` due to the following commentary in multiprocessing‘s documentation:

> For very long iterables using a large value for chunksize can make the job complete much faster than using the default value of 1.

Upon execution, we find that **837,799** produces the longest sequence, and it is of length **524**. By distributing the tasks to four cores (Intel i5 - Windows 10 - Python 3.8), the script completes in 25 seconds, whereas the sequential implementation requires approx. 55 seconds. This disparity would only grow in favor of the parallel implementation as the range of evaluation increases from 1M to 5M or 10M.

For more information on the multiprocessing module, be sure to check out the [documentation](https://docs.python.org/3/library/multiprocessing.html#multiprocessing-programming). In addition, the Python Standard Library includes the `concurrent.futures` module, which exposes an even higher-level interface that facilitates both thread and process-based parallelism via Executor objects.
