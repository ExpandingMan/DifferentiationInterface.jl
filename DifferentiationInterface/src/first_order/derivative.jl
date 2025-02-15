## Docstrings

"""
    prepare_derivative(f,     backend, x) -> extras
    prepare_derivative(f!, y, backend, x) -> extras

Create an `extras` object that can be given to [`derivative`](@ref) and its variants.

!!! warning
    If the function changes in any way, the result of preparation will be invalidated, and you will need to run it again.
    For in-place functions, `y` is mutated by `f!` during preparation.
"""
function prepare_derivative end

"""
    value_and_derivative(f,     [extras,] backend, x) -> (y, der)
    value_and_derivative(f!, y, [extras,] backend, x) -> (y, der)

Compute the value and the derivative of the function `f` at point `x`.

$(document_preparation("derivative"))
"""
function value_and_derivative end

"""
    value_and_derivative!(f,     der, [extras,] backend, x) -> (y, der)
    value_and_derivative!(f!, y, der, [extras,] backend, x) -> (y, der)

Compute the value and the derivative of the function `f` at point `x`, overwriting `der`.

$(document_preparation("derivative"))
"""
function value_and_derivative! end

"""
    derivative(f,     [extras,] backend, x) -> der
    derivative(f!, y, [extras,] backend, x) -> der

Compute the derivative of the function `f` at point `x`.

$(document_preparation("derivative"))
"""
function derivative end

"""
    derivative!(f,     der, [extras,] backend, x) -> der
    derivative!(f!, y, der, [extras,] backend, x) -> der

Compute the derivative of the function `f` at point `x`, overwriting `der`.

$(document_preparation("derivative"))
"""
function derivative! end

## Preparation

struct PushforwardDerivativeExtras{E<:PushforwardExtras} <: DerivativeExtras
    pushforward_extras::E
end

function prepare_derivative(
    f::F, backend::AbstractADType, x, contexts::Vararg{Context,C}
) where {F,C}
    pushforward_extras = prepare_pushforward(f, backend, x, Tangents(one(x)), contexts...)
    return PushforwardDerivativeExtras(pushforward_extras)
end

function prepare_derivative(
    f!::F, y, backend::AbstractADType, x, contexts::Vararg{Context,C}
) where {F,C}
    pushforward_extras = prepare_pushforward(
        f!, y, backend, x, Tangents(one(x)), contexts...
    )
    return PushforwardDerivativeExtras(pushforward_extras)
end

## One argument

function value_and_derivative(
    f::F,
    extras::PushforwardDerivativeExtras,
    backend::AbstractADType,
    x,
    contexts::Vararg{Context,C},
) where {F,C}
    y, ty = value_and_pushforward(
        f, extras.pushforward_extras, backend, x, Tangents(one(x)), contexts...
    )
    return y, only(ty)
end

function value_and_derivative!(
    f::F,
    der,
    extras::PushforwardDerivativeExtras,
    backend::AbstractADType,
    x,
    contexts::Vararg{Context,C},
) where {F,C}
    y, _ = value_and_pushforward!(
        f,
        Tangents(der),
        extras.pushforward_extras,
        backend,
        x,
        Tangents(one(x)),
        contexts...,
    )
    return y, der
end

function derivative(
    f::F,
    extras::PushforwardDerivativeExtras,
    backend::AbstractADType,
    x,
    contexts::Vararg{Context,C},
) where {F,C}
    ty = pushforward(
        f, extras.pushforward_extras, backend, x, Tangents(one(x)), contexts...
    )
    return only(ty)
end

function derivative!(
    f::F,
    der,
    extras::PushforwardDerivativeExtras,
    backend::AbstractADType,
    x,
    contexts::Vararg{Context,C},
) where {F,C}
    pushforward!(
        f,
        Tangents(der),
        extras.pushforward_extras,
        backend,
        x,
        Tangents(one(x)),
        contexts...,
    )
    return der
end

## Two arguments

function value_and_derivative(
    f!::F,
    y,
    extras::PushforwardDerivativeExtras,
    backend::AbstractADType,
    x,
    contexts::Vararg{Context,C},
) where {F,C}
    y, ty = value_and_pushforward(
        f!, y, extras.pushforward_extras, backend, x, Tangents(one(x)), contexts...
    )
    return y, only(ty)
end

function value_and_derivative!(
    f!::F,
    y,
    der,
    extras::PushforwardDerivativeExtras,
    backend::AbstractADType,
    x,
    contexts::Vararg{Context,C},
) where {F,C}
    y, _ = value_and_pushforward!(
        f!,
        y,
        Tangents(der),
        extras.pushforward_extras,
        backend,
        x,
        Tangents(one(x)),
        contexts...,
    )
    return y, der
end

function derivative(
    f!::F,
    y,
    extras::PushforwardDerivativeExtras,
    backend::AbstractADType,
    x,
    contexts::Vararg{Context,C},
) where {F,C}
    ty = pushforward(
        f!, y, extras.pushforward_extras, backend, x, Tangents(one(x)), contexts...
    )
    return only(ty)
end

function derivative!(
    f!::F,
    y,
    der,
    extras::PushforwardDerivativeExtras,
    backend::AbstractADType,
    x,
    contexts::Vararg{Context,C},
) where {F,C}
    pushforward!(
        f!,
        y,
        Tangents(der),
        extras.pushforward_extras,
        backend,
        x,
        Tangents(one(x)),
        contexts...,
    )
    return der
end
