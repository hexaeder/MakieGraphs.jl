module MakieGraphs

using AbstractPlotting
using GraphPlot
using LightGraphs
using Random

export NetworkPlot

@recipe(NetworkPlot, graph) do scene
    Attributes(
        nodecolor = :red,
        nodesize = 20,
        marker = Circle,
        edgecolor = :black,
        edgewidth = 2.5,
        seed = 39,
        c = 0.5
    )
end

function AbstractPlotting.plot!(np::NetworkPlot)
    graph = np[:graph]

    edges = Node(Point2f0[])
    nodes = Node(Point2f0[])

    function update_graph(new_graph, new_seed, new_c)
        empty!(edges[])
        empty!(nodes[])

        rng = MersenneTwister(new_seed)
        g = new_graph
        xpos, ypos = spring_layout(g, 2. * rand(rng, nv(g)) .- 1.0, 2 .* rand(rng, nv(g)) .- 1.0; C=new_c)

        for (x, y) in zip(xpos, ypos)
            push!(nodes[], Point2f0(x, -y))
        end
        for e in LightGraphs.edges(g)
            push!(edges[], nodes[][e.src])
            push!(edges[], nodes[][e.dst])
        end
        # trigger the changes
        edges[] = edges[]
        nodes[] = nodes[]
    end

    AbstractPlotting.Observables.onany(update_graph, graph, np.seed, np.c)

    update_graph(graph[], np.seed[], np.c[])

    linesegments!(np, edges,
                  color=np.edgecolor,
                  linewidth=np.edgewidth)
    scatter!(np, nodes,
             color=np.nodecolor,
             marker=np.marker,
             markersize=np.nodesize)
    np
end

end
