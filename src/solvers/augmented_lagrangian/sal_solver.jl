
@with_kw mutable struct ALStats{T}
    iterations::Int = 0
    iterations_total::Int = 0
    iterations_inner::Vector{Int} = zeros(Int,0)
    cost::Vector{T} = zeros(0)
    c_max::Vector{T} = zeros(0)
    penalty_max::Vector{T} = zeros(0)
end

function reset!(stats::ALStats, L=0)
    stats.iterations = 0
    stats.iterations_total = 0
    stats.iterations_inner = zeros(Int,L)
    stats.cost = zeros(L)
    stats.c_max = zeros(L)
    stats.penalty_max = zeros(L)
end

struct StaticALSolver{T,S<:AbstractSolver} <: AbstractSolver{T}
    opts::AugmentedLagrangianSolverOptions{T}
    stats::ALStats{T}
    stats_uncon::Vector{STATS} where STATS
    solver_uncon::S
end

StaticALSolver(prob::Problem{T},
    opts::AugmentedLagrangianSolverOptions{T}=AugmentedLagrangianSolverOptions{T}()) where T =
    AbstractSolver(prob,opts)

"""$(TYPEDSIGNATURES)
Form an augmented Lagrangian cost function from a Problem and AugmentedLagrangianSolver.
    Does not allocate new memory for the internal arrays, but points to the arrays in the solver.
"""
function AbstractSolver(prob::StaticProblem{T,D}, opts::AugmentedLagrangianSolverOptions{T}) where {T<:AbstractFloat,D<:DynamicsType}
    # Init solver statistics
    stats = ALStats{T}()

    solver_uncon = AbstractSolver(prob, opts.opts_uncon)
    StaticALSolver(opts,stats,stats_uncon,solver_uncon)
end



struct StaticALObjective{T} <: AbstractObjective
    cost::Vector{<:CostFunction}
    constraints::ConstraintSet{T}
end
