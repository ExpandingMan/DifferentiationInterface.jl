"""
    DifferentiationInterface

An interface to various automatic differentiation backends in Julia.

# Exports

$(EXPORTS)
"""
module DifferentiationInterface

using ADTypes:
    AbstractADType, AbstractForwardMode, AbstractReverseMode, AbstractFiniteDifferencesMode
using DocStringExtensions
using FillArrays: OneElement
using LinearAlgebra: dot

include("mode.jl")
include("utils.jl")

include("pushforward.jl")
include("pullback.jl")
include("zero.jl")

include("derivative.jl")
include("multiderivative.jl")
include("gradient.jl")
include("jacobian.jl")

include("second_order.jl")
include("second_derivative.jl")
include("hessian_vector_product.jl")
include("hessian.jl")

include("prepare.jl")

# submodules
include("DifferentiationTest.jl")

export SecondOrder

export value_and_pushforward!, value_and_pushforward
export value_and_pullback!, value_and_pullback

export value_and_derivative
export value_and_multiderivative!, value_and_multiderivative
export value_and_gradient!, value_and_gradient
export value_and_jacobian!, value_and_jacobian

export gradient_and_hessian_vector_product!, gradient_and_hessian_vector_product
export hessian_vector_product!, hessian_vector_product

export value_derivative_and_second_derivative
export value_gradient_and_hessian!, value_gradient_and_hessian

export pushforward!, pushforward
export pullback!, pullback

export derivative
export multiderivative!, multiderivative
export gradient!, gradient
export jacobian!, jacobian

export second_derivative
export hessian!, hessian

export prepare_pushforward
export prepare_pullback

export prepare_derivative
export prepare_multiderivative
export prepare_gradient
export prepare_jacobian

export prepare_second_derivative
export prepare_hessian

function __init__()
    Base.Experimental.register_error_hint(MethodError) do io, exc, argtypes, kwargs
        f_name = string(exc.f)
        if (
            f_name == "mode" ||
            contains(f_name, "pushforward") ||
            contains(f_name, "pullback") ||
            contains(f_name, "derivative") ||
            contains(f_name, "gradient") ||
            contains(f_name, "jacobian") ||
            contains(f_name, "hessian")
        )
            for T in argtypes
                if T <: AbstractADType
                    print(
                        io,
                        """\n
                        HINT: To use `DifferentiationInterface` with backend `$T`, you need to load the corresponding package extension.
                        """,
                    )
                    return nothing
                end
            end
        end
    end
end

end # module
