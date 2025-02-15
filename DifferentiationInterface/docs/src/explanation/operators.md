# Operators

!!! tip
    If there are some concepts you do not understand, take a look at the book [_The Elements of Differentiable Programming_](https://arxiv.org/abs/2403.14606) (Blondel and Roulet, 2024).

## List of operators

Given a function `f(x) = y`, there are several differentiation operators available. The terminology depends on:

- the type and shape of the input `x`
- the type and shape of the output `y`
- the order of differentiation

Below we list and describe all the operators we support.

!!! warning
    The package is thoroughly tested with inputs and outputs of the following types: `Float64`, `Vector{Float64}` and `Matrix{Float64}`.
    We also expect it to work on most kinds of `Number` and `AbstractArray` variables.
    Beyond that, you are in uncharted territory.
    We voluntarily keep the type annotations minimal, so that passing more complex objects or custom structs _might work in some cases_, but we make no guarantees about that yet.

### High-level operators

These operators are computed using only the input `x`.

| operator                    | order | input `x`       | output `y`      | operator result type | operator result shape    |
| :-------------------------- | :---- | :-------------- | :-------------- | :------------------- | :----------------------- |
| [`derivative`](@ref)        | 1     | `Number`        | `Any`           | similar to `y`       | `size(y)`                |
| [`second_derivative`](@ref) | 2     | `Number`        | `Any`           | similar to `y`       | `size(y)`                |
| [`gradient`](@ref)          | 1     | `Any`           | `Number`        | similar to `x`       | `size(x)`                |
| [`jacobian`](@ref)          | 1     | `AbstractArray` | `AbstractArray` | `AbstractMatrix`     | `(length(y), length(x))` |
| [`hessian`](@ref)           | 2     | `AbstractArray` | `Number`        | `AbstractMatrix`     | `(length(x), length(x))` |

### Low-level operators

These operators are computed using the input `x` and another argument `t` of type [`Tangents`](@ref), which contains one or more tangents.
You can think of tangents as perturbations propagated through the function; they live either in the same space as `x` or in the same space as `y`.

| operator                    | order | input `x` | output `y` | element type of `t` | operator result type | operator result shape |
| :-------------------------- | :---- | :-------- | :--------- | :------------------ | :------------------- | :-------------------- |
| [`pushforward`](@ref) (JVP) | 1     | `Any`     | `Any`      | similar to `x`      | similar to `y`       | `size(y)`             |
| [`pullback`](@ref) (VJP)    | 1     | `Any`     | `Any`      | similar to `y`      | similar to `x`       | `size(x)`             |
| [`hvp`](@ref)               | 2     | `Any`     | `Number`   | similar to `x`      | similar to `x`       | `size(x)`             |

## Variants

Several variants of each operator are defined:

- out-of-place operators return a new derivative object
- in-place operators mutate the provided derivative object

| out-of-place                | in-place                     | out-of-place + primal                            | in-place + primal                                 |
| :-------------------------- | :--------------------------- | :----------------------------------------------- | :------------------------------------------------ |
| [`derivative`](@ref)        | [`derivative!`](@ref)        | [`value_and_derivative`](@ref)                   | [`value_and_derivative!`](@ref)                   |
| [`second_derivative`](@ref) | [`second_derivative!`](@ref) | [`value_derivative_and_second_derivative`](@ref) | [`value_derivative_and_second_derivative!`](@ref) |
| [`gradient`](@ref)          | [`gradient!`](@ref)          | [`value_and_gradient`](@ref)                     | [`value_and_gradient!`](@ref)                     |
| [`hessian`](@ref)           | [`hessian!`](@ref)           | [`value_gradient_and_hessian`](@ref)             | [`value_gradient_and_hessian!`](@ref)             |
| [`jacobian`](@ref)          | [`jacobian!`](@ref)          | [`value_and_jacobian`](@ref)                     | [`value_and_jacobian!`](@ref)                     |
| [`pushforward`](@ref)       | [`pushforward!`](@ref)       | [`value_and_pushforward`](@ref)                  | [`value_and_pushforward!`](@ref)                  |
| [`pullback`](@ref)          | [`pullback!`](@ref)          | [`value_and_pullback`](@ref)                     | [`value_and_pullback!`](@ref)                     |
| [`hvp`](@ref)               | [`hvp!`](@ref)               | -                                                | -                                                 |

## Mutation and signatures

Two kinds of functions are supported:

- out-of-place functions `f(x) = y`
- in-place functions `f!(y, x) = nothing`

!!! warning
    In-place functions only work with [`pushforward`](@ref), [`pullback`](@ref), [`derivative`](@ref) and [`jacobian`](@ref).
    The other operators [`hvp`](@ref), [`gradient`](@ref) and [`hessian`](@ref) require scalar outputs, so it makes no sense to mutate the number `y`.

This results in various operator signatures (the necessary arguments and their order):

| function signature        | out-of-place operator (returns `result`) | in-place  operator (mutates `result`) |
| :------------------------ | :--------------------------------------- | :------------------------------------ |
| out-of-place function `f` | `op(f, backend, x, [t])`                 | `op!(f, result, backend, x, [t])`     |
| in-place function `f!`    | `op(f!, y, backend, x, [t])`             | `op!(f!, y, result, backend, x, [t])` |

!!! warning
    The positional arguments between `f`/`f!` and `backend` are always mutated, regardless of the bang `!` in the operator name.
    In particular, for in-place functions `f!(y, x)`, every variant of every operator will mutate `y`.

## Preparation

### Principle

In many cases, AD can be accelerated if the function has been called at least once (e.g. to record a tape) or if some cache objects are pre-allocated.
This preparation procedure is backend-specific, but we expose a common syntax to achieve it.

| operator            | preparation (different point)       | preparation (same point)                 |
| :------------------ | :---------------------------------- | :--------------------------------------- |
| `derivative`        | [`prepare_derivative`](@ref)        | -                                        |
| `gradient`          | [`prepare_gradient`](@ref)          | -                                        |
| `jacobian`          | [`prepare_jacobian`](@ref)          | -                                        |
| `second_derivative` | [`prepare_second_derivative`](@ref) | -                                        |
| `hessian`           | [`prepare_hessian`](@ref)           | -                                        |
| `pushforward`       | [`prepare_pushforward`](@ref)       | [`prepare_pushforward_same_point`](@ref) |
| `pullback`          | [`prepare_pullback`](@ref)          | [`prepare_pullback_same_point`](@ref)    |
| `hvp`               | [`prepare_hvp`](@ref)               | [`prepare_hvp_same_point`](@ref)         |

In addition, the preparation syntax depends on the number of arguments accepted by the function.

| function signature    | preparation signature                |
| :-------------------- | :----------------------------------- |
| out-of-place function | `prepare_op(f, backend, x, [t])`     |
| in-place function     | `prepare_op(f!, y, backend, x, [t])` |

Preparation creates an object called `extras` which contains the the necessary information to speed up an operator and its variants.
The idea is that you prepare only once, which can be costly, but then call the operator several times while reusing the same `extras`.

```julia
op(f, backend, x, [t])  # slow because it includes preparation
op(f, extras, backend, x, [t])  # fast because it skips preparation
```

!!! warning
    The `extras` object is the last argument before `backend` and it is always mutated, regardless of the bang `!` in the operator name.

### Reusing preparation

Deciding whether it is safe to reuse the results of preparation is not easy.
Here are the general rules that we strive to implement:

For different-point preparation, the output `extras` of `prepare_op(f, b, x, [t])` can be reused in `op(f, extras, b, other_x, [other_t])`, provided that:

- the inputs `x` and `other_x` have similar types and equal shapes
- the tangents in `t` and `other_t` have similar types and equal shapes

For same-point preparation, the output `extras` of `prepare_op_same_point(f, b, x, [t])` can be reused in `op(f, extras, b, x, other_t)`, provided that:

- the input `x` remains the same
- the tangents in `t` and `other_t` have similar types and equal shapes

!!! warning
    These rules hold for the majority of backends, but there are some exceptions.